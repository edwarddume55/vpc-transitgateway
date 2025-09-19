resource "aws_vpc" "BACKENDSERVICES_VPC" {
  cidr_block       = "11.0.0.0/16"
  

  tags = {
    Name = "BACKENDSERVICES_VPC"
  }
}

resource "aws_subnet" "BACKENDSERVICES_SUBNET" {
  vpc_id     = aws_vpc.BACKENDSERVICES_VPC.id
  cidr_block = "11.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "BACKENDSERVICES_SUBNET"
  }
}

resource "aws_internet_gateway" "BACKENDSERVICES_IGW" {
  vpc_id     = aws_vpc.BACKENDSERVICES_VPC.id

  tags = {
    Name = "BACKENDSERVICES_IGW"
  }
}

# Create a default route table for backend services VPC
resource "aws_default_route_table" "BACKENDSERVICES_ROUTE" {
  default_route_table_id = aws_vpc.BACKENDSERVICES_VPC.default_route_table_id

  tags = {
    Name = "BACKENDSERVICES_ROUTE"
  }
}

# Create a default route for backend services VPC
resource "aws_route" "backendservices_route" {
  route_table_id         = aws_default_route_table.BACKENDSERVICES_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.BACKENDSERVICES_IGW.id 

  depends_on = [aws_vpc.BACKENDSERVICES_VPC]  
}

resource "aws_route" "backendservices_to_web_app" {
  route_table_id         = aws_default_route_table.BACKENDSERVICES_ROUTE.id
  destination_cidr_block = "10.0.0.0/16" 
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.backendservices_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.backendservices_attachment]
}

resource "aws_route" "backendservices_to_shared_database" {
  route_table_id         = aws_default_route_table.BACKENDSERVICES_ROUTE.id
  destination_cidr_block = "12.0.0.0/16"  
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.backendservices_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.backendservices_attachment]
}