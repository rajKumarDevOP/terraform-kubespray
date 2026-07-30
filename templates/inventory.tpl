

[all]
%{ for node in masters ~}
${node.name} ansible_host=${node.private_ip} ip=${node.private_ip} etcd_member_name=${node.etcd_name}
%{ endfor ~}

%{ for node in workers ~}
${node.name} ansible_host=${node.private_ip} ip=${node.private_ip}
%{ endfor ~}

[kube_control_plane]
%{ for node in masters ~}
${node.name}
%{ endfor ~}

[etcd]
%{ for node in masters ~}
${node.name}
%{ endfor ~}

[kube_node]
%{ for node in workers ~}
${node.name}
%{ endfor ~}

[k8s_cluster:children]
kube_control_plane
kube_node

[calico_rr]