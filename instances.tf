#====================================================================instance.tf========================================


resource "aws_instance" "master" {
  count         = var.masterCP_count
  ami           = var.ami
  instance_type = var.master_instance_type

  key_name  = var.key_name                                        
  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
 
  # user_data = file("scripts/bootstrap.sh")
  tags = {
    Name    = "master-${count.index + 1}"
    Role    = "kube_control_plane"
    Cluster = "ai-cluster"
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "gpu_worker" {
  count         = var.gpu_worker_count
  ami           = var.ami
  instance_type = var.gpu_instance_type

  
  key_name  = var.key_name
  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name    = "gpu-node-${count.index + 1}"
    Role    = "kube_node"
    Cluster = "ai-cluster"
    ManagedBy = "Terraform"
  }
}


 