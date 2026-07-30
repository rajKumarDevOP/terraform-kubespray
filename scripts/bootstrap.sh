#!/bin/bash
set -euxo pipefail

apt-get update
apt-get install -y git python3 python3-pip python3-venv sshpass

cd /home/ubuntu

if [ ! -d kubespray ]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git
fi

chown -R ubuntu:ubuntu kubespray

cd kubespray
cp -rf /home/ubuntu/kubespray/inventory/sample /home/ubuntu/kubespray/inventory/ai-cluster
python3 -m venv venv

./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

chown -R ubuntu:ubuntu inventory/ai-cluster