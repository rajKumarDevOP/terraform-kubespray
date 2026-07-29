# #!/bin/bash
# set -euxo pipefail

# apt-get update
# apt-get install -y git python3 python3-pip python3-venv sshpass

# cd /home/ubuntu

# if [ ! -d kubespray ]; then
#     git clone https://github.com/kubernetes-sigs/kubespray.git
# fi

# chown -R ubuntu:ubuntu kubespray

# cd kubespray
# cp -rf /home/ubuntu/kubespray/inventory/sample /home/ubuntu/kubespray/inventory/ai-cluster
# python3 -m venv venv

# ./venv/bin/pip install --upgrade pip
# ./venv/bin/pip install -r requirements.txt

# #!/bin/bash

# apt update -y

# apt install -y \
# git \
# python3 \
# python3-pip \
# python3-venv

# cd /opt

# git clone https://github.com/kubernetes-sigs/kubespray.git

# cd kubespray

# python3 -m venv venv

# source venv/bin/activate

# pip install -U pip

# pip install -r requirements.txt

# ansible-galaxy collection install amazon.aws
# mkdir -p /opt/kubespray/inventory/ai-cluster
# cat > /opt/kubespray/inventory/ai-cluster/aws_ec2.yml <<EOF
# plugin: amazon.aws.aws_ec2

# regions:
#   - ap-south-1

# filters:
#   tag:Cluster: ai-cluster
#   instance-state-name: running

# keyed_groups:
#   - key: tags.Role

# compose:
#   ansible_host: private_ip_address
# EOF

# source /opt/kubespray/venv/bin/activate

# ansible-inventory \
# -i /opt/kubespray/inventory/ai-cluster/aws_ec2.yml 

# until ansible-inventory \
# -i /opt/kubespray/inventory/ai-cluster/aws_ec2.yml \
# --graph
# do
#     sleep 15
# done
# cd /opt/kubespray

# source venv/bin/activate

# ansible-playbook \
#   -i inventory/ai-cluster/aws_ec2.yml \
#   cluster.yml \
#   -b \
#   -u ubuntu

# mkdir -p /home/ubuntu/.kube

# sudo cp /etc/kubernetes/admin.conf \
#     /home/ubuntu/.kube/config

# sudo chown ubuntu:ubuntu \
#     /home/ubuntu/.kube/config

# chmod 600 \
#     /home/ubuntu/.kube/config

#!/bin/bash

set -euxo pipefail

#
# Update OS
#

apt update -y

apt install -y \
    git \
    curl \
    unzip \
    jq \
    python3 \
    python3-pip \
    python3-venv

#
# Install AWS CLI
#

cd /tmp

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o awscliv2.zip

unzip -oq awscliv2.zip

./aws/install

#
# Install Kubespray
#

cd /opt

if [ ! -d kubespray ]; then
  git clone https://github.com/kubernetes-sigs/kubespray.git
fi

cd kubespray

python3 -m venv venv

source venv/bin/activate

pip install --upgrade pip

pip install -r requirements.txt

ansible-galaxy collection install amazon.aws

#
# Create Kubespray Inventory Directory
#

mkdir -p /opt/kubespray/inventory/ai-cluster

#
# Dynamic Inventory
#

cat > /opt/kubespray/inventory/ai-cluster/aws_ec2.yml <<'EOF'
plugin: amazon.aws.aws_ec2

regions:
  - ap-south-1

filters:
  tag:Cluster: ai-cluster
  instance-state-name: running

keyed_groups:
  - key: tags.Role

compose:
  ansible_host: private_ip_address
EOF

#
# Create Kubespray Variables
#

mkdir -p \
/opt/kubespray/inventory/ai-cluster/group_vars/k8s_cluster

cat > \
/opt/kubespray/inventory/ai-cluster/group_vars/k8s_cluster/k8s-cluster.yml <<'EOF'
cluster_name: ai-cluster

container_manager: containerd

kube_network_plugin: calico

dns_mode: coredns
EOF

cat > \
/opt/kubespray/inventory/ai-cluster/group_vars/k8s_cluster/addons.yml <<'EOF'
helm_enabled: true

metrics_server_enabled: true

dashboard_enabled: false

local_path_provisioner_enabled: true
EOF

#
# Cluster Deployment Script
#

cat > /opt/kubespray/cluster-deploy.sh <<'EOF'
#!/bin/bash

set -euxo pipefail

cd /opt/kubespray

source venv/bin/activate

#
# Wait until both master and workers appear
#

sleep 180

until ansible-inventory \
-i inventory/ai-cluster/aws_ec2.yml \
--graph | grep kube_control_plane
do
  echo "Waiting for control plane inventory..."
  sleep 30
done

until ansible-inventory \
-i inventory/ai-cluster/aws_ec2.yml \
--graph | grep kube_node
do
  echo "Waiting for worker nodes..."
  sleep 30
done

#
# Verify Inventory
#

ansible-inventory \
-i inventory/ai-cluster/aws_ec2.yml \
--graph

#
# Verify SSH
#

ansible \
-i inventory/ai-cluster/aws_ec2.yml \
all \
-m ping \
-u ubuntu

#
# Build Kubernetes Cluster
#

ansible-playbook \
-i inventory/ai-cluster/aws_ec2.yml \
cluster.yml \
-b \
-u ubuntu

#
# Configure kubectl
#

mkdir -p /home/ubuntu/.kube

cp /etc/kubernetes/admin.conf \
   /home/ubuntu/.kube/config

chown ubuntu:ubuntu \
   /home/ubuntu/.kube/config

chmod 600 \
   /home/ubuntu/.kube/config

echo 'export KUBECONFIG=$HOME/.kube/config' \
>> /home/ubuntu/.bashrc

kubectl get nodes
EOF

chmod +x /opt/kubespray/cluster-deploy.sh

#
# Systemd Service
#

cat > /etc/systemd/system/kubespray-bootstrap.service <<'EOF'
[Unit]
Description=Kubespray Bootstrap
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/kubespray/cluster-deploy.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable kubespray-bootstrap.service

systemctl start kubespray-bootstrap.service