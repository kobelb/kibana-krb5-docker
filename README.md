/etc/hosts
--------
```
127.0.0.1	kerberos.test.elastic.co
```

/etc/krb5.conf
--------
```
[libdefaults]
	default_realm = TEST.ELASTIC.CO

[realms]
	TEST.ELASTIC.CO = {
		admin_server = kerberos.test.elastic.co
		kdc = kerberos.test.elastic.co
		default_principal_flags = +preauth
	}

[domain_realm]
	localhost = TEST.ELASTIC.CO
```

Docker commands
--------
```
REALM_NAME=TEST.ELASTIC.CO
docker build -t kdc ./
docker run -d -p 88:88 -p 88:88/udp --name kdc kdc:latest
docker cp kdc:/root/es.keytab ./
docker cp kdc:/root/dev.keytab ./
docker stop kdc
docker rm kdc
```


Generate those keytabs
--------
```
docker exec kdc kadmin.local -q "addprinc -pw changeme HTTP/localhost@TEST.ELASTIC.CO"
docker exec kdc kadmin.local -q "ktadd -k /root/es.keytab HTTP/localhost@TEST.ELASTIC.CO"
docker cp kdc:/root/es.keytab ./

docker exec kdc kadmin.local -q "addprinc -pw changeme dev@TEST.ELASTIC.CO"
docker exec kdc kadmin.local -q "ktadd /root/dev.keytab dev@TEST.ELASTIC.CO"
docker cp kdc:/root/dev.keytab ./
```

Start Elasticsearch
---------
```
ES_JAVA_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf" yarn es snapshot \
    --license trial \
    -E xpack.security.authc.token.enabled=true \
    -E xpack.security.authc.realms.kerberos.kerb1.keytab.path=$GIT_HOME/kibana-krb5-docker/es.keytab
```

Set up role mappings
---------
```
POST {{es}}/_security/role_mapping/krb5
Content-Type: application/json
Authorization: Basic elastic changeme

{
  "roles": [ "superuser" ],
  "enabled": true,
  "rules": { "field" : { "realm.name" : "kerb1" } }
}
```

Get the key for dev
---------
```
kinit -k -t ./dev.keytab dev@TEST.ELASTIC.CO 
```
