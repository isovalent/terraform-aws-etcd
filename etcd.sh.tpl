#!/bin/bash

# Install necessary packages
sudo yum install -y docker
sudo yum install -y bind-utils


# Ensure Docker is installed and running
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Mask locksmithd.service (not applicable in all environments, adjust as needed)
sudo systemctl mask locksmithd.service

# Create necessary directories with permissions
mkdir -p /etc/ssl/etcd /var/lib/etcd /opt/bootstrap /etc/etcd
chmod 700 /var/lib/etcd
chmod 500 /etc/ssl/etcd
chown 232:232 /var/lib/etcd


# Create necessary files with contents
echo -e "#!/bin/bash -e\nmkdir -p /etc/ssl/etcd\nmkdir -p /var/lib/etcd\nchown -R etcd:etcd /etc/ssl/etcd\nchmod -R 500 /etc/ssl/etcd\nchmod -R 700 /var/lib/etcd" > /opt/bootstrap/layout
chmod 0544 /opt/bootstrap/layout

echo "fs.inotify.max_user_watches=16184" > /etc/sysctl.d/max-user-watches.conf
sysctl --system


# etcd environment configuration
cat << EOF > /etc/etcd/etcd.env
ETCD_NAME=${etcd_name}
ETCD_DATA_DIR=/var/lib/etcd
ETCD_ADVERTISE_CLIENT_URLS=http://${etcd_domain}:2379
ETCD_INITIAL_ADVERTISE_PEER_URLS=${etcd_peer_url}
ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
ETCD_INITIAL_CLUSTER=${etcd_initial_cluster}
EOF

# Systemd service for etcd
cat << EOF > /etc/systemd/system/etcd-member.service
[Unit]
Description=etcd (System Container)
Documentation=https://github.com/etcd-io/etcd
Requires=docker.service
After=docker.service
[Service]
ExecStartPre=/usr/bin/docker run -d \\
  --name etcd \\
  --network host \\
  --env-file /etc/etcd/etcd.env \\
  --user 232:232 \\
  --volume /etc/ssl/etcd:/etc/ssl/certs:ro \\
  --volume /var/lib/etcd:/var/lib/etcd:rw \\
  gcr.io/etcd-development/etcd:v3.5.4
ExecStart=/usr/bin/docker exec etcd etcd
ExecStop=/usr/bin/docker stop etcd
ExecStopPost=/usr/bin/docker rm etcd
Restart=always
RestartSec=10s
TimeoutStartSec=0
LimitNOFILE=40000
[Install]
WantedBy=multi-user.target
EOF

# Enable and start etcd-member.service
sudo systemctl daemon-reload
sudo systemctl enable etcd-member.service
sudo systemctl start etcd-member.service

# Wait for DNS service script
cat << EOF > /opt/wait-for-dns.sh
#!/bin/bash
while ! /usr/bin/grep '^[^#[:space:]]' /etc/resolv.conf > /dev/null; do sleep 1; done
EOF
chmod +x /opt/wait-for-dns.sh
/opt/wait-for-dns.sh

# Bootstrap service script
if [ ! -f /opt/bootstrap/bootstrap.done ]; then
  /opt/bootstrap/layout
  touch /opt/bootstrap/bootstrap.done
fi