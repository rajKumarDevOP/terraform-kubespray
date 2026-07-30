# AI Kubernetes Cluster on AWS using Terraform & Kubespray

## Architecture

```text
AWS
│
├── VPC
│
├── Control Plane
│   ├── Kubernetes API Server
│   ├── Controller Manager
│   ├── Scheduler
│   └── etcd
│
└── GPU Worker
    ├── NVIDIA Driver
    ├── containerd
    ├── GPU Operator
    └── AI Workloads
```

## Infrastructure

| Component   | Instance Type |
| ----------- | ------------- |
| Master Node | `t3.large`    |
| GPU Worker  | `g5.xlarge`   |

---

# Terraform Project Structure

```text
terraform/
├── vpc/
├── subnets/
├── route-tables/
├── security-groups/
├── ec2-master/
├── ec2-gpu-worker/
├── eip/
└── s3/
```

---

# AWS Resources

The following resources are provisioned using Terraform:

* VPC
* Public Subnet
* Internet Gateway
* Route Tables
* Security Groups
* Control Plane EC2
* GPU Worker EC2
* Elastic IP
* S3 Bucket (Terraform Backend)

---

# Terraform Resource References

## Single Resource

Without `count` or `for_each`

```hcl
aws_instance.master.id
```

---

## Using `count`

Returns a **list (tuple)**.

```hcl
aws_instance.master[0].id
```

---

## Using `for_each`

Returns a **map**.

```hcl
aws_instance.master["master1"].id
```

---

## Summary

| Resource Definition     | Output Type   | Example                             |
| ----------------------- | ------------- | ----------------------------------- |
| No `count` / `for_each` | Single Object | `aws_instance.master.id`            |
| `count`                 | List (Tuple)  | `aws_instance.master[0].id`         |
| `for_each`              | Map           | `aws_instance.master["master1"].id` |

Python analogy:

```python
# count
for index, item in list:
    ...

# for_each
for key, value in map.items():
    ...
```

---

# Cluster Deployment

After Terraform completes successfully:

```bash
cd ~/kubespray

source venv/bin/activate

ansible -i inventory/ai-cluster/inventory.ini all -m ping

ansible-playbook \
    -i inventory/ai-cluster/inventory.ini \
    --become \
    --become-user=root \
    cluster.yml
```

---

# Configure kubectl

If `kubectl` is not configured:

```bash
mkdir -p ~/.kube

sudo cp /etc/kubernetes/admin.conf ~/.kube/config

sudo chown ubuntu:ubuntu ~/.kube/config
```

Verify:

```bash
kubectl get nodes
```

---

# Fix: kubectl Connection Refused

### Error

```text
E0730 ... couldn't get current server API group list:
Get "http://localhost:8080/api":
connect: connection refused
```

### Solution

```bash
mkdir -p ~/.kube

sudo cp /etc/kubernetes/admin.conf ~/.kube/config

sudo chown ubuntu:ubuntu ~/.kube/config
```

---

# Fix: CoreDNS CrashLoopBackOff

Check the node DNS configuration:

```bash
cat /etc/resolv.conf

resolvectl status
```

The DNS server in `resolv.conf` should match the resolver reported by `resolvectl`.

If they don't match, edit:

```text
inventory/ai-cluster/group_vars/k8s_cluster/k8s-cluster.yml
```

Add:

```yaml
upstream_dns_servers:
  - 10.25.0.2
```

Re-run Kubespray:

```bash
ansible-playbook \
    -i inventory/ai-cluster/inventory.ini \
    --become \
    cluster.yml
```

---

# Install Metrics Server

```bash
kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

# Fix: Metrics Server TLS Error

### Error

```text
tls: failed to verify certificate

x509:
cannot validate certificate because it doesn't contain any IP SANs
```

Edit the deployment:

```bash
kubectl edit deployment metrics-server -n kube-system
```

Update the container arguments:

```yaml
args:
  - --cert-dir=/tmp
  - --secure-port=10250
  - --kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls
```

Wait for rollout:

```bash
kubectl rollout status deployment metrics-server -n kube-system
```

Verify:

```bash
kubectl top nodes

kubectl top pods -A
```

---

# Install Helm

```bash
curl -fsSL -o get_helm.sh \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

Verify:

```bash
helm version
```

---

# Add Helm Repositories

```bash
helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts

helm repo add argo \
https://argoproj.github.io/argo-helm

helm repo update
```

---

# Install Monitoring Stack

Create the namespace:

```bash
kubectl create namespace monitoring
```

Install kube-prometheus-stack:

```bash
helm install monitoring \
prometheus-community/kube-prometheus-stack \
-n monitoring
```

Verify:

```bash
kubectl get pods -n monitoring
```

This installs:

* Prometheus
* Grafana
* Alertmanager
* kube-state-metrics
* Node Exporter

---

# Install Argo CD

Create namespace:

```bash
kubectl create namespace argocd
```

Install Argo CD:

```bash
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify:

```bash
kubectl get pods -n argocd
```

---

# Cluster Verification

Check cluster status:

```bash
kubectl get nodes

kubectl get pods -A

kubectl get all -A

kubectl cluster-info
```

---

# Next Steps

After the base cluster is operational:

* Install NVIDIA GPU Operator
* Configure GPU Runtime
* Install NGINX Gateway Fabric or Ingress-NGINX
* Install cert-manager
* Configure external DNS
* Deploy AI workloads using Argo CD
* Enable GitOps for all platform components
