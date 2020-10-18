#!/usr/bin/env bash

# Preparation
docker rm zookeeper broker client -f
docker network rm kafka-network
docker network create kafka-network

# Build and run Zookeeper
docker build -t zookeeper -f ./ZookeeperDockerfile .
docker run -t -d --network kafka-network --hostname zookeeper --name zookeeper zookeeper

# Build and run broker
docker build -t broker -f ./BrokerDockerfile .
docker run -t -d --network kafka-network --hostname broker --name broker broker

# Build and run client
docker build -t client -f ./ClientDockerfile .
docker run -t -d --network kafka-network --hostname client --name client client

## Copy client cert to CA machine and sign it
docker cp client:/ssl/client-cert-unsigned .
docker exec -i broker sh -c 'cat > /CA/client-cert-unsigned' < client-cert-unsigned
docker exec -i broker openssl x509 -req -CA /CA/ca-cert -CAkey /CA/ca-key -in /CA/client-cert-unsigned -out /CA/client-cert-signed -days 365 -CAcreateserial -passin pass:"123456"

# Copy back to client
docker cp broker:/CA/client-cert-signed .
docker exec -i client sh -c 'cat > /ssl/client-cert-signed' < client-cert-signed

# Copy root CA to client
docker cp broker:/CA/ca-cert .
docker exec -i client sh -c 'cat > /ssl/ca-cert' < ca-cert

# Adding signed cert and root CA to client keystore and truststore
docker exec -i client keytool -keystore /ssl/client.truststore.jks -alias ca-root -import -file /ssl/ca-cert -storepass "123456" -keypass "123456" -noprompt
docker exec -i client keytool -keystore /ssl/client.keystore.jks -alias ca-root -import -file /ssl/ca-cert -storepass "123456" -keypass "123456" -noprompt
docker exec -i client keytool -keystore /ssl/client.keystore.jks -alias kafka-client -import -file /ssl/client-cert-signed -storepass "123456" -keypass "123456" -noprompt

# Clean up
docker exec -i broker rm /CA/client-cert-signed /CA/client-cert-unsigned
docker exec -i client rm /ssl/client-cert-signed /ssl/client-cert-unsigned /ssl/ca-cert
rm ca-cert client-cert-signed client-cert-unsigned

# Creates a test topic
docker exec -it broker /bin/bash /kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test

