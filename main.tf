provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "cicd" {
  key_name   = "cicd"
  public_key = file("~/.ssh/cicd.pub")
}

# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = "ami-0583d8c7a9c35822c"  # RedHat Linux AMI ID
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.cicd.key_name
  security_groups        = [aws_security_group.allow_all.name]
  associate_public_ip_address = true

  tags = {
    Name = "sonarqube-server"
  }
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/cicd")
      host        = aws_instance.sonarqube.public_ip
  }
  
  # copy the sonar_setup.sh.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "sonar_setup.sh"
    destination = "/tmp/sonar_setup.sh"
  }

  # set permissions and run the sonar_setup.sh file
  provisioner "remote-exec" {
    inline = [ 
        "sudo chmod +x /tmp/sonar_setup.sh",
        "export GIT_USERNAME=${var.git_username} && export GIT_TOKEN=${var.git_token}",
        "bash /tmp/sonar_setup.sh",
    ]
  }
  # wait for ec2 to be created
  depends_on = [aws_instance.sonarqube]
}

resource "aws_instance" "nexus" {
  ami                    = "ami-0583d8c7a9c35822c"  # RedHat Linux AMI ID
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.cicd.key_name
  security_groups        = [aws_security_group.allow_all.name]
  associate_public_ip_address = true

  tags = {
    Name = "nexus-server"
  }
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/cicd")
      host        = aws_instance.nexus.public_ip
  }
  # copy the nexus_setup.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "nexus_setup.sh"
    destination = "/tmp/nexus_setup.sh"
  }

  # set permissions and run the nexus_setup.sh file
  provisioner "remote-exec" {
    inline = [ 
        "sudo chmod +x /tmp/nexus_setup.sh",
        "export GIT_USERNAME=${var.git_username} && export GIT_TOKEN=${var.git_token}",
        "bash /tmp/nexus_setup.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.nexus]
}

resource "null_resource" "capture_nexus_password" {
  depends_on = [aws_instance.nexus]

  provisioner "remote-exec" {
    inline = [
      "sudo cat /opt/nexus/sonatype-work/nexus3/admin.password > /home/ec2-user/nexus_admin_password.txt",
      "sudo chmod 644 /home/ec2-user/nexus_admin_password.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/cicd")
      host        = aws_instance.nexus.public_ip
    }
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/cicd ec2-user@${aws_instance.nexus.public_ip}:/home/ec2-user/nexus_admin_password.txt ./nexus_admin_password.txt"
  }
} 


output "sonarqube_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "nexus_url" {
  value = "http://${aws_instance.nexus.public_ip}:8081"
}

output "nexus_admin_password" {
  description = "The initial admin password for Nexus"
  value       = "The password is stored in nexus_admin_password.txt locally. Run `cat nexus_admin_password.txt` to view it."
}
