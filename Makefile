
cassandra-dl:
	git clone https://github.com/apache/cassandra

store:
	openssl x509 -outform der -in ca.pem -out tmp_ca.der
	keytool -import -alias cassandra -keystore cass_truststore.jks -file tmp_ca.der
	rm tmp_ca.der

shell:
	cqlsh --cqlshrc=cqlshrc --ssl

stress:
	./cassandra/tools/bin/cassandra-stress user profile=autoGen.yaml n=100000 ops\(insert=200\) -node $(SVC_URI) -transport ssl-protocol=TLSv1.2 truststore=cass_truststore.jks truststore-password=$(SSL_TS_PWD) -mode native cql3 user=$(SVC_USER) password=$(SVC_PWD) -port native=$(SVC_PORT)

stress-write:
	./cassandra/tools/bin/cassandra-stress write n=100000 -node ${SVC_URI} -transport ssl-protocol=TLSv1.2 truststore=cass_truststore.jks truststore-password=${SSL_TS_PWD} -mode native cql3 user=avnadmin password=${SVC_PWD} port=24947 -schema "replication(strategy=NetworkTopologyStrategy,aiven=3)" -port native=${SVC_PORT}

deploy-migration:
	avn service create -t cassandra -p startup-8 -c migrate_sstableloader=true cass-target-cg --cloud google-europe-west4 -c cassandra_version=4

get-schema-src:
	/usr/cassandra4/bin/cqlsh --cqlshrc=cqlshrc --ssl -e "DESCRIBE KEYSPACE test_keyspace" > src-schema.cql

set-schema-target:
	/usr/cassandra4/bin/cqlsh --cqlshrc=cqlshrc-target --ssl -f src-schema.cql
