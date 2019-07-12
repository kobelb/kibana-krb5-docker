#! /bin/bash

curl -XPOST http://localhost:9200/_security/role/kibana_sample_data -H 'Content-Type: application/json' -u elastic:changeme -d '{
  "indices": [
    {
      "names": ["kibana*"],
      "privileges": ["read", "view_index_metadata"]
    }
  ]
}'

curl -XPOST http://localhost:9200/_security/role_mapping/krb5 -H 'Content-Type: application/json' -u elastic:changeme -d '{
  "roles": [ "kibana_user", "kibana_sample_data" ],
  "enabled": true,
  "rules": { "field" : { "realm.name" : "kerb1" } }
}'
