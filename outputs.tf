#====================================================================outputs.tf========================================

output "master_public_ip" {
  value = aws_instance.master[*].public_ip
}

output "gpu_node_public_ip" {
  value = aws_instance.gpu_worker[*].public_ip
}