resource "null_resource" "copy_files" {

  depends_on = [
    local_file.kubespray_inventory,
    aws_instance.master
  ]

  connection {
    type        = "ssh"
    host        = aws_instance.master.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  # Copy inventory
  provisioner "file" {
    source      = "${path.module}/kubespray/inventory/ai-cluster/inventory.ini"
    destination = "/home/ubuntu/kubespray/inventory/ai-cluster/inventory.ini"
  }

  # Copy SSH key
  provisioner "file" {
    source      = file(var.private_key_path)
    destination = file(var.private_key_path)
  }

  # Set permissions
  provisioner "remote-exec" {
    inline = [
      "chmod 700 /home/ubuntu/.ssh",
      "chmod 400 /home/ubuntu/.ssh/${var.key_name}.pem"
    ]
  }
}