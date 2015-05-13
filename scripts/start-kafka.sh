#!/bin/sh

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `boot2docker ip`
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"


# Configure advertised host/port if we run in helios
if [ ! -z "$HELIOS_PORT_kafka" ]; then
    ADVERTISED_HOST=`echo $HELIOS_PORT_kafka | cut -d':' -f 1 | xargs -n 1 dig +short | tail -n 1`
    ADVERTISED_PORT=`echo $HELIOS_PORT_kafka | cut -d':' -f 2`
fi

# Set the external host and port
if [ ! -z "$ADVERTISED_HOST" ]; then
    echo "advertised host: $ADVERTISED_HOST"
    sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties
else
    MY_DOCKER_IP=$(cat /etc/hosts | grep "`hostname`" | awk '{print $1}')
    echo "Using my docker host IP ad advertised host: $MY_DOCKER_IP"
    sed -r -i "s/#(advertised.host.name)=(.*)/\1=$MY_DOCKER_IP/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$ADVERTISED_PORT" ]; then
    echo "advertised port: $ADVERTISED_PORT"
    sed -r -i "s/#(advertised.port)=(.*)/\1=$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
else
    echo "Using default port as advertised port: 9092"
    sed -r -i "s/#(advertised.port)=(.*)/\1=9092/g" $KAFKA_HOME/config/server.properties
fi

# wait for zk to start... embedding together in same script seems problematic.
until /opt/zookeeper/bin/zkServer.sh status; do
    sleep 0.1
done

# Set the zookeeper chroot
if [ ! -z "$ZK_CHROOT" ]; then

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | /opt/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$ZK_CHROOT/g" $KAFKA_HOME/config/server.properties
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
