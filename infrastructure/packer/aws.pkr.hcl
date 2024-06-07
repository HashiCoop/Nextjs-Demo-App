source "amazon-ebs" "ubuntu" {
  ami_name      = "base-security"
  instance_type = "t2.small"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"
}

build {
    hcp_packer_registry {
      bucket_name = "base-security"
      description = "Base image for building demos"

      bucket_labels = {
        "owner"          = "HashiCoop"
        "os"             = "Ubuntu",
        "ubuntu-version" = "22.04",
      }

      build_labels = {
        "build-time"   = timestamp()
        "build-source" = basename(path.cwd)
      }
  }

  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {    
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  provisioner "file" {
    source      = "./config.sh"
    destination = "/tmp/config.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "PRIVATE_IP_METADATA_URL=http://169.254.169.254/latest/meta-data/local-ipv4",
      "PUBLIC_IP_METADATA_URL=http://169.254.169.254/latest/meta-data/public-ipv4"
    ]

    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    inline = [
      "sudo bash /tmp/config.sh",
      "rm /tmp/config.sh",
    ]
  }
}