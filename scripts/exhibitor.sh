#!/bin/bash -e

# Generates the default exhibitor config and launches exhibitor

if [ -z "$ADVERTISED_HOST" ]; then
    ADVERTISED_HOST=$(cat /etc/hosts | grep "`hostname`" | awk '{print $1}')
fi

cat <<- EOF > /opt/exhibitor/defaults.conf
    zookeeper-data-directory=/opt/zookeeper/snapshots
    zookeeper-install-directory=/opt/zookeeper
    zookeeper-log-directory=/opt/zookeeper/transactions
    log-index-directory=/opt/zookeeper/transactions
    cleanup-period-ms=300000
    check-ms=30000
    backup-period-ms=600000
    client-port=2181
    cleanup-max-files=20
    backup-max-store-ms=21600000
    connect-port=2888
    observer-threshold=0
    election-port=3888
    zoo-cfg-extra=tickTime\=2000&initLimit\=10&syncLimit\=5&quorumListenOnAllIPs\=true
    auto-manage-instances-settling-period-ms=0
    auto-manage-instances=1
EOF

exec 2>&1

# If we use exec and this is the docker entrypoint, Exhibitor fails to kill the ZK process on restart.
# If we use /bin/bash as the entrypoint and run wrapper.sh by hand, we do not see this behavior. I suspect
# some init or PID-related shenanigans, but I'm punting on further troubleshooting for now since dropping
# the "exec" fixes it.

java -jar /opt/exhibitor/exhibitor.jar \
    --port 8181 --defaultconfig /opt/exhibitor/defaults.conf \
    --configtype file --hostname ${ADVERTISED_HOST}

