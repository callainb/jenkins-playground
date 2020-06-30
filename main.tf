{
  "debug" : true,
  "bip" : "10.30.0.1/24"
}
(AWS_PROFILE=scrap)allc014@C02Y302HJG5H@bnc jenkins %   cat main.tf 
# The AMI has git on it
# The AMI has Python3 on it

variable private-key-location-for-ssh-provisioners {
  type = string
}

variable ingress-from-cidr-blocks {
  type = list(string)
}

variable vpc-id {
  type = string
}

variable subnet-id {
  type = string
}

variable ami-id {
  type = string
}

variable slave-ami-id {
  type = string
}

variable ssh-keypair-name {
  type = string
}

variable master-instance-type {
  type = string
}

variable master-root-partition-size {
  type = number
}

variable slave-instance-type {
  type = string
}

variable slave-root-partition-size {
  type = number
}

variable public-addresses {
  type = bool
  default = false
}

provider aws {
  region = "us-east-1"
  version = "2.64"
}

resource "aws_security_group" "mastersg" {
  name        = "carl-tests-master"
  description = "Used by Carl for testing stuff"
  vpc_id      = var.vpc-id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress-from-cidr-blocks
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress-from-cidr-blocks
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.ingress-from-cidr-blocks
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress-from-cidr-blocks
  }

  ingress {
    description = "All in cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.clustersg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "carl-tests"
    src = "tf"
  }

}

resource "aws_security_group" "slavesg" {
  name        = "carl-tests-slave"
  description = "Used by Carl for testing stuff"
  vpc_id      = var.vpc-id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress-from-cidr-blocks
  }

  ingress {
    description = "All in cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.clustersg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "carl-tests"
    src = "tf2"
  }

}

resource "aws_security_group" "clustersg" {
  name        = "carl-tests-cluster"
  description = "Used by Carl for testing stuff"
  vpc_id      = var.vpc-id

  tags = {
    Name = "carl-tests"
    src = "tf-clustersg"
  }

}

resource aws_instance master {
  ami = var.ami-id
  instance_type = var.master-instance-type
  subnet_id = var.subnet-id
  key_name = var.ssh-keypair-name
  vpc_security_group_ids = [aws_security_group.mastersg.id, aws_security_group.clustersg.id]
  associate_public_ip_address = var.public-addresses
  user_data = file("./user-data.sh")
  tags = {
    "Name" : "carl-test"
    src = "tf"
  }
  root_block_device {
    volume_size = var.master-root-partition-size
  }
}

resource aws_instance slave {
  ami = var.slave-ami-id
  instance_type = var.slave-instance-type
  subnet_id = var.subnet-id
  key_name = var.ssh-keypair-name
  vpc_security_group_ids = [aws_security_group.slavesg.id, aws_security_group.clustersg.id]
  associate_public_ip_address = var.public-addresses
  user_data = file("./slave-user-data.sh")
  tags = {
    "Name" : "carl-test"
    src = "tf2"
  }
  root_block_device {
    volume_size = var.slave-root-partition-size
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private-key-location-for-ssh-provisioners)
    host = var.public-addresses ? self.public_ip : self.private_ip
    timeout = "5m"
  }

  # tls_private_key.slave-pk.public_key_openssh adds a newline...
  # When doing sudo echo and redirecting it, the redirection is done by the shell before sudo is even started... so can't create from scratch
  provisioner "remote-exec" {
    inline = [
      "sudo useradd -m -s /bin/bash jenkins",
      "sudo mkdir -p /home/jenkins/.ssh",
      "echo '${chomp(tls_private_key.slave-pk.public_key_openssh)}' | sudo tee /home/jenkins/.ssh/authorized_keys",
      "sudo chown -R jenkins:jenkins /home/jenkins/.ssh",
      "sudo chmod 700 /home/jenkins/.ssh",
      "sudo chmod 600 /home/jenkins/.ssh/authorized_keys",
      # Here we force bash as inlined scripts run in a file uploaded to the host with sh as its interpreter...
      "bash -c \"for i in {1..60}; do if getent group docker; then echo 'docker group ok'; break; else echo 'docker group does not exist yet'; sleep 5; fi ; done\"",
      "sudo usermod -a -G docker jenkins"
    ]
  }

}

resource "tls_private_key" "slave-pk" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

output slave-pk-private-pem {
  value = tls_private_key.slave-pk.private_key_pem
  sensitive = true
}

output slave-pk-public-pem {
  value = tls_private_key.slave-pk.public_key_pem
}

output slave-pk-public-openssh {
  value = tls_private_key.slave-pk.public_key_openssh
}

output master-private-ip {
  value = aws_instance.master.private_ip
}

output master-public-ip {
  value = aws_instance.master.public_ip
}

output slave-private-ip {
  value = aws_instance.slave.private_ip
}

output slave-public-ip {
  value = aws_instance.slave.public_ip
}
