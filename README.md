/etc/hosts
--------
127.0.0.1	kerberos.test.elastic.co


Docker commands
--------
REALM_NAME=TEST.ELASTIC.CO
docker build -t kdc ./
docker run -d -p 88:88 -p 88:88/udp --name kdc kdc:latest
docker cp kdc:/root/es.keytab ./
docker stop kdc
docker rm kdc


Generate those keytabs
--------
docker exec kdc kadmin.local -q "addprinc -pw changeme HTTP/es@TEST.ELASTIC.CO"
docker exec kdc kadmin.local -q "ktadd -k /root/es.keytab HTTP/es@TEST.ELASTIC.CO"
docker cp kdc:/root/es.keytab ./

kadmin.local -q "addprinc -pw changeme dev@TEST.ELASTIC.CO"
kadmin.local -q "ktadd /root/dev.keytab dev@TEST.ELASTIC.CO"

Start Elasticsearch
---------
ES_JAVA_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf" yarn es snapshot \
    --license trial \
    -E xpack.security.authc.token.enabled=true \
    -E xpack.security.authc.realms.kerberos.kerb1.keytab.path=/Users/kobelb/Projects/elastic/kibana-krb5-docker/es.keytab

Get the key for dev
---------
kinit dev@TEST.ELASTIC.CO -k -t /Users/kobelb/Projects/elastic/kibana-krb5-docker/dev.keytab

