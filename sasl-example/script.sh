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

# Copy root CA to host machine
docker cp broker:/CA/ca-cert .

# Build and run client
docker build -t client -f ./ClientDockerfile .
docker run -t -d --network kafka-network --hostname client --name client client

# Clean up
rm ca-cert

# Wait until server is up
sleep 5

## Creates a test topic
docker exec -it broker /bin/bash /kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test