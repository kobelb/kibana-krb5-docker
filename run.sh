#! /bin/bash

set -e

# Build the container
docker build -t kdc ./

# Start the container up
docker run -d -p 88:88 -p 88:88/udp --name kdc kdc:latest

# Copy the keytabs we need
docker cp kdc:/root/es.keytab ./
docker cp kdc:/root/dev.keytab ./

# Get the ticket-granting-ticket for the dev user
kinit -k -t ./dev.keytab dev@TEST.ELASTIC.CO 

# Start up Elaticsearch
cd $GIT_HOME/kibana
ES_JAVA_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf" yarn es snapshot \
    --license trial \
    -E xpack.security.authc.token.enabled=true \
    -E xpack.security.authc.realms.kerberos.kerb1.keytab.path=$GIT_HOME/kibana-krb5-docker/es.keytab
