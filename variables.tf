variable "ec2_command" {
  description = "este es el comando que va a ejecutar en docker"
  default = <<-EOF
                #!/bin/bash

                sudo yum update -y
                sudo yum install docker -y
                sudo systemctl start docker 
                sudo usermod -a -G docker ec2-user
                sudo systemctl enable docker
                sudo docker run -d -p 80:80 --name nginx-container nginx
            EOF
}