# [all]
# master1 ansible_host=${master_public_ip} ip=${master_private_ip} etcd_member_name=etcd1
# gpu_node ansible_host=${worker_public_ip} ip=${worker_private_ip}

# [kube_control_plane]
# master1

# [etcd]
# master1

# [kube_node]
# gpu_node

# [k8s_cluster:children]
# kube_control_plane
# kube_node

# [calico_rr]