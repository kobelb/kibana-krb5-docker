#! /bin/bash

set -e

docker build -t kdc ./
docker run -d -p 88:88 -p 88:88/udp --name kdc kdc:latest
docker cp kdc:/root/es.keytab ./

echo "type changeme when prompted for the password"
kinit dev

cd $GIT_HOME/kibana
ES_JAVA_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf" yarn es snapshot \
    --license trial \
    -E xpack.security.authc.token.enabled=true \
    -E xpack.security.authc.realms.kerberos.kerb1.keytab.path=$GIT_HOME/kibana-krb5-docker/es.keytab
