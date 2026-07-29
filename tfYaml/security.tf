# #====================================================================security .tf========================================

#   CODE COMMENTED: USING EXISTING RESOURCES 

# resource "aws_security_group" "ai_k8s" {
#   name   = "ai_cluster"
#   vpc_id = aws_vpc.vpc_ai.id
#     ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.admin_ips
#   }

#   # Kubernetes API Server
#   ingress {
#     description = "Kubernetes API"
#     from_port   = 6443
#     to_port     = 6443
#     protocol    = "tcp"
#     self        = true
#   }

#   # etcd
#   ingress {
#     description = "etcd"
#     from_port   = 2379
#     to_port     = 2380
#     protocol    = "tcp"
#     self        = true
#   }

#   # Kubelet
#   ingress {
#     description = "Kubelet"
#     from_port   = 10250
#     to_port     = 10250
#     protocol    = "tcp"
#     self        = true
#   }

#   # Controller Manager
#   ingress {
#     description = "Controller Manager"
#     from_port   = 10257
#     to_port     = 10257
#     protocol    = "tcp"
#     self        = true
#   }

#   # Scheduler
#   ingress {
#     description = "Scheduler"
#     from_port   = 10259
#     to_port     = 10259
#     protocol    = "tcp"
#     self        = true
#   }

#   # NodePort Services
#   ingress {
#     description = "NodePort Services"
#     from_port   = 30000
#     to_port     = 32767
#     protocol    = "tcp"
#     self        = true
#   }

#   # ICMP (optional, for ping/troubleshooting)
#   ingress {
#     description = "ICMP"
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     self        = true
#   }

#     egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#     tags = {
#     Name ="ai-sg"
#   }
#  }