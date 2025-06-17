resource "aws_instance" "k8s_control_plane" {
  ami           = var.ami
  instance_type = "t3.small"
  key_name = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]
  associate_public_ip_address = true
 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  tags = {
    Name = "k8s-control-plane"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R +x /tmp/scripts",
      "/tmp/scripts/init_cluster.sh \"${var.k8s_version}\"",
      # "/tmp/create_control_pane_secret.sh",
      # "/tmp/create_worker_secret.sh"
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "cat /tmp/output.txt"
  #   ]
  # }
}