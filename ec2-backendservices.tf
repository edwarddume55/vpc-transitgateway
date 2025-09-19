# Create a security group named 'customer-securitygrp' with ingress rules
resource "aws_default_security_group" "default2" {
  vpc_id = aws_vpc.BACKENDSERVICES_VPC.id
  tags = {
    Name = "BackendServices-sg"
  }
 

  # Allow SSH access 
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere for testing
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch the EC2 instance
resource "aws_instance" "backendservices_linux" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t3.micro" 
  key_name = "terraform-key"
  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to My Web App!</title>
<style>
body {
  font-family: Arial, sans-serif;
  background-color: #f0f0f0;
}
.container {
  max-width: 800px;
  margin: 50px auto;
  padding: 20px;
  background-color: #fff;
  border-radius: 5px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
}
</style>
</head>
<body>
<div class="container">
  <h1>Welcome to My Backend services ec2!</h1>
  <p><strong>Hostname:</strong> $(hostname)</p>
  <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
</div>
</body>
</html>
EOF


  )

  tags = {
    Name = "Backend-Services-Linux-Instance"
  }

  # Associate the instance with a security group
  vpc_security_group_ids = [aws_default_security_group.default2.id]
  subnet_id = aws_subnet.BACKENDSERVICES_SUBNET.id
  associate_public_ip_address = true
}

# Output the public IP address 
output "backendservices_public_ip" {
  value = aws_instance.backendservices_linux.public_ip
}

# Output the private IP address
output "backendservices_private_ip" {
  value = aws_instance.backendservices_linux.private_ip
}