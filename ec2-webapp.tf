# Create a security group named 'customer-securitygrp' with ingress rules
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.WEBAPP_VPC.id
  tags = {
    Name = "Webapp-sg"
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

  # Allow all outbound traffic for simplicity
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# Launch the EC2 instance
resource "aws_instance" "webapp_linux" {
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
  <h1>Welcome to My Web App!</h1>
  <p><strong>Hostname:</strong> $(hostname)</p>
  <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
</div>
</body>
</html>
EOF


  )

  # Tag the instance for easy identification
  tags = {
    Name = "Webapp-Linux-Instance"
  }

  vpc_security_group_ids = [aws_default_security_group.default.id]
  subnet_id = aws_subnet.WEBAPP_SUBNET.id
  associate_public_ip_address = true
}

# Output the public IP address 
output "webapp_public_ip" {
  value = aws_instance.webapp_linux.public_ip
}
