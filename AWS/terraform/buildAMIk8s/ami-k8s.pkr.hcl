packer {
  required_version = ">= 1.12.0" // packer minimum version

  required_plugins {
    amazon = {  //https://github.com/hashicorp/packer-plugin-amazon
      version = ">= 1.3.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


variable "k8s_version" {
  type    = string
  default = "1.29.0"
}

source "amazon-ebs" "k8s-ami" {
  region                  = "us-east-2"
  instance_type           = "t3.miremoveAllAmi.shcro"
  source_ami_filter {
    owners      = ["amazon"]
    filters     = {
      "name"                = "amzn2-ami-hvm-*-x86_64-gp2"
      "virtualization-type" = "hvm"
      "root-device-type"    = "ebs"
      "ena-support"         = "true"
    }
    most_recent = true
  }
  ssh_username            = "ec2-user"
  ami_name                = format("%s%s", "ami-k8s-v", var.k8s_version)
}

build {
  sources = ["source.amazon-ebs.k8s-ami"]

  # Copy the install script to the instance
  provisioner "file" {
    source      = "scripts/install_k8s.sh"
    destination = "/tmp/install_k8s.sh"
  }

  # Run the script with the version argument
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_k8s.sh",
      "/tmp/install_k8s.sh ${var.k8s_version}"
    ]
  }
}