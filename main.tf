provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" "my_webserver" {
    ami = "ami-05f7491af5eef733a"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.my_webserver.id]
    key_name = "${aws_key_pair.ubuntu.key_name}"
    user_data = <<EOF
#!/bin/bash
apt-get update
apt-get upgade -y
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
groupadd docker
usermod -aG docker ubuntu
reboot
EOF
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu_user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/XCWFPbJk5Q30lBWesTLIBCeGcsWpGaZ+8pfUKEmVDW6sS7q9JIy3EWwkB+JSU3CgIiyhjfXjYnwv/li94bCnEKV0dgglxsgjmdkGJw9dQNLysqx9tQeZh6Oo1kPdmWxJL+UPBJK2N8bFApWoFrWTRFMBHpXAdsFZGOvGdu6xx7u90u8WnxJ5+HiK4HjkOd7JBGTFVICIs4TL78cLRVr/7f4YvgBwrwnPFbKOOo6zUL2dH3uHYeq4ZCU9BlULRqj6V3jm1FClsASKzVmYzYUTDH3sQ03WclrYMfZnhpPiy+0mwZ9TaDFeTPt6QgjJtW73bjJ5QMNreqYGKUJfG0f695GJpX/TCfaZP3bqZC/pCoKaq3q76N+vqfvuWtdE+NPS+/EObXbIk1VVrFhQeywOEyiqIfRAeGmDlZwNkQ/mrn7wcxrsVz+NH4sa/ObKqGtELKAld5ak51Xb+N/iDgu66xdgIrUy2zWQkkAKrUOcuysSAyrYip57Ja68O7fJrPE= kishinskiy@MacBook-Pro-Oleg.local"
}

resource "aws_security_group" "my_webserver" {
    name = "web-server"
    description = "my security group"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
