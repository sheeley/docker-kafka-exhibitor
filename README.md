Kafka & Exhibitor in Docker
===

This repository provides everything you need to run Kafka in Docker. This is based on spotify/kafka but upgraded to kafka 0.8.2.1 and defaults the ADVERTISED_HOST and ADVERTISED_PORT to the local docker0 IP for easy internal linking

Why?
---
The main hurdle of running Kafka in Docker is that it depends on Zookeeper.
Compared to other Kafka docker images, this one runs both Zookeeper and Kafka
in the same container. This means:

* No dependency on an external Zookeeper host, or linking to another container
* Zookeeper and Kafka are configured to work together out of the box
* Exhibitor is included so you can use Curator for connections

Run
---

```bash
docker run -p 2181:2181 -p 9092:9092 -p 8181:8181 --env ADVERTISED_HOST=`boot2docker ip` --env ADVERTISED_PORT=9092 sheeley/docker-kafka-exhibitor
```

```bash
export KAFKA=`boot2docker ip`:9092
kafka-console-producer.sh --broker-list $KAFKA --topic test
```

```bash
export ZOOKEEPER=`boot2docker ip`:2181
kafka-console-consumer.sh --zookeeper $ZOOKEEPER --topic test
```

Public Builds
---

https://registry.hub.docker.com/u/sheeley/docker-kafka-exhibitor


Forked from
---
- https://github.com/spotify/docker-kafka
- https://github.com/mbabineau/docker-zk-exhibitor
