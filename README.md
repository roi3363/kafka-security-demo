# Securing Kafka Cluster Example

### Setup
Running the examples is fairly easy. 
1. Clone the repository and cd into it.
2. Choose one of the following examples: 
    * `$ cd ssl-example`
    * `$ cd sasl-example`
3. Run `$ ./script.sh`
4. Once the script has finished, you can  
    * *Start a producer*: `$ docker exec -it client /bin/bash bin/kafka-console-producer.sh --bootstrap-server broker:9093 --topic test --producer.config config/producer.properties`
    * *Start a consumer*: `$ docker exec -it client /bin/bash bin/kafka-console-consumer.sh --bootstrap-server broker:9093 --topic test --from-beginning --consumer.config config/consumer.properties`
    
### Clean up 
* `$ docker rm zookeeper broker client -f && docker network rm kafka-network`