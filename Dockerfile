# Kafka and Zookeeper
FROM java:8

ENV DEBIAN_FRONTEND="noninteractive"
ENV EXHIBITOR_POM="https://raw.githubusercontent.com/Netflix/exhibitor/d911a16d704bbe790d84bbacc655ef050c1f5806/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml"
ENV KAFKA_HOME="/opt/kafka_2.10-0.8.2.1"
ENV ZK_RELEASE="http://www.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz"
ENV MVN_RELEASE="http://mirror.nexcess.net/apache/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz"
ENV KAFKA_RELEASE="http://apache.mirrors.spacedump.net/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz"

# Install Kafka, Zookeeper and other needed things
RUN mkdir -p /opt/maven /opt/zookeeper/transactions /opt/zookeeper/snapshots /opt/exhibitor /opt/kafka && \
    apt-get update && \
    apt-get install -y wget supervisor dnsutils && \
    curl -Lo /tmp/mvn.tgz $MVN_RELEASE && \
    curl -Lo /tmp/zookeeper.tgz $ZK_RELEASE && \
    curl -Lo /tmp/kafka.tgz $KAFKA_RELEASE && \
    curl -Lo /opt/exhibitor/pom.xml $EXHIBITOR_POM && \
    ls -l /tmp && \
    tar -xzf /tmp/mvn.tgz -C /opt/maven && \
    tar -xzf /tmp/zookeeper.tgz -C /opt/zookeeper --strip=1 && \
    tar -xzf /tmp/kafka.tgz -C /opt/kafka && \
    /opt/maven/apache-maven-*/bin/mvn -f /opt/exhibitor/pom.xml package && \
    ln -s /opt/exhibitor/target/exhibitor*.jar /opt/exhibitor/exhibitor.jar && \
    rm -rf /tmp/*.tgz /var/lib/apt/lists/*

# Add the wrapper script to setup configs and exec exhibitor
ADD scripts/exhibitor.sh /opt/exhibitor/wrapper.sh
ADD scripts/start-kafka.sh /usr/bin/start-kafka.sh

# Supervisor config
ADD supervisor/kafka.conf /etc/supervisor/conf.d/kafka.conf
ADD supervisor/zookeeper.conf /etc/supervisor/conf.d/zookeeper.conf
ADD supervisor/exhibitor.conf /etc/supervisor/conf.d/exhibitor.conf

# 2181 is zookeeper, 9092 is kafka, 8181 is exhibitor
EXPOSE 2181 9092 8181

USER root
WORKDIR /opt/exhibitor

CMD ["supervisord", "-n"]


