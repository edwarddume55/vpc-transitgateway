resource "aws_vpc" "WEBAPP_VPC" {
  cidr_block       = "10.0.0.0/16"
  

  tags = {
    Name = "WEBAPP_VPC"
  }
}

resource "aws_subnet" "WEBAPP_SUBNET" {
  vpc_id     = aws_vpc.WEBAPP_VPC.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "WEBAPP_SUBNET"
  }
}

resource "aws_internet_gateway" "WEBAPP_IGW" {
  vpc_id     = aws_vpc.WEBAPP_VPC.id

  tags = {
    Name = "WEBAPP_IGW"
  }
}

resource "aws_default_route_table" "WEBAPP_ROUTE" {
  default_route_table_id = aws_vpc.WEBAPP_VPC.default_route_table_id

  tags = {
    Name = "WEBAPP_ROUTE"
  }
}

resource "aws_route" "webapp_route" {
  route_table_id         = aws_default_route_table.WEBAPP_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.WEBAPP_IGW.id

  depends_on = [aws_vpc.WEBAPP_VPC]  # Ensure VPC is created before route
}

# Route to BACKEND_SERVICES_VPC via Transit Gateway Attachment
resource "aws_route" "webapp_to_backendservices" {
  route_table_id         = aws_default_route_table.WEBAPP_ROUTE.id
  destination_cidr_block = "11.0.0.0/16"  
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.webapp_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.webapp_attachment]
}

# Route to SHARED_DATABASE_VPC via Transit Gateway Attachment
resource "aws_route" "webapp_to_shareddatabase" {
  route_table_id         = aws_default_route_table.WEBAPP_ROUTE.id
  destination_cidr_block = "12.0.0.0/16"  
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.webapp_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.webapp_attachment]
}