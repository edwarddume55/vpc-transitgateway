# Attach WEB_APP_VPC to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "webapp_attachment" {
  # ID of the Transit Gateway
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  subnet_ids = [
    aws_subnet.WEBAPP_SUBNET.id  # Reference the created subnet ID
  ]
  # VPC ID to be attached
  vpc_id = aws_vpc.WEBAPP_VPC.id

  
  tags = {
    Name = "Web App VPC Attachment"
  }
}
# Attach WEBAPP_VPC to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "backendservices_attachment" {
  # ID of the Transit Gateway
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  subnet_ids = [
    aws_subnet.BACKENDSERVICES_SUBNET.id  # Reference the created subnet ID
  ]
  # VPC ID to be attached
  vpc_id = aws_vpc.BACKENDSERVICES_VPC.id

  # Optional tags for identification
  tags = {
    Name = "Backend Services VPC Attachment"
  }
}
# Attach WEB_APP_VPC to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "shareddatabase_attachment" {
  # ID of the Transit Gateway
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  subnet_ids = [
    aws_subnet.SHAREDDATABASE_SUBNET.id  # Reference the created subnet ID
  ]
  # VPC ID to be attached
  vpc_id = aws_vpc.SHAREDDATABASE_VPC.id

  # Optional tags for identification
  tags = {
    Name = "Shared database VPC Attachment"
  }
}