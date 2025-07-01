#!/bin/bash
mkdir -p /usr/local/src/etcd /etc/etcd /var/lib/etcd
sudo wget https://github.com/etcd-io/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz -P /usr/local/src
sudo tar -xvf /usr/local/src/etcd-${etcd_version}-linux-amd64.tar.gz -C /usr/local/src/etcd
sudo mv /usr/local/src/etcd/etcd-${etcd_version}-linux-amd64/etcd* /usr/local/bin/
sudo groupadd -f -g 1501 etcd
sudo useradd -c "etcd user" -d /var/lib/etcd -s /bin/false -g etcd -u 1501 etcd
sudo chown -R etcd:etcd /var/lib/etcd

export ETCD_HOST_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Systemd service for etcd
cat << EOF > /etc/systemd/system/etcd-member.service
[Unit]
Description=etcd service
Documentation=https://github.com/etcd-io/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0
ExecStart=/usr/local/bin/etcd --name ${etcd_name} \\
    --data-dir /var/lib/etcd \\
    --listen-client-urls http://$ETCD_HOST_IP:2379 \\
    --advertise-client-urls http://$ETCD_HOST_IP:2379 \\
    --listen-peer-urls http://$ETCD_HOST_IP:2380 \\
    --initial-advertise-peer-urls http://$ETCD_HOST_IP:2380 \\
    --initial-cluster ${etcd_initial_cluster} \\
    --initial-cluster-token my-etcd-token \\
    --initial-cluster-state new

[Install]
WantedBy=multi-user.target
EOF

# Enable and start etcd-member.service
sudo systemctl daemon-reload
sudo systemctl enable etcd-member.service
sudo systemctl start etcd-member.service