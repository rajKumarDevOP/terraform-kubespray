# resource "local_file" "kubespray_inventory" {
#   filename = "../kubespray/inventory/ai-cluster/inventory.ini"

#   content = templatefile("${path.module}/templates/inventory.tpl", {
#     master_public_ip  = aws_instance.master[0].public_ip
#     master_private_ip = aws_instance.master[0].private_ip

#     worker_public_ip  = aws_instance.gpu_worker[0].public_ip
#     worker_private_ip = aws_instance.gpu_worker[0].private_ip
#   })
# }
locals {

  masters = [
    for idx, node in aws_instance.master : {
      name       = "master${idx + 1}"
      public_ip  = node.public_ip
      private_ip = node.private_ip
      etcd_name  = "etcd${idx + 1}"
    }
  ]

  workers = [
    for idx, node in aws_instance.gpu_worker : {
      name       = "worker${idx + 1}"
      public_ip  = node.public_ip
      private_ip = node.private_ip
    }
  ]
}

resource "local_file" "kubespray_inventory" {

  filename = "../kubespray/inventory/mycluster/inventory.ini"

  content = templatefile("${path.module}/../templates/inventory.tpl", {
    masters = local.masters
    workers = local.workers
  })
}

 