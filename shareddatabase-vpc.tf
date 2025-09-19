resource "aws_vpc" "SHAREDDATABASE_VPC" {
  cidr_block       = "12.0.0.0/16"
  

  tags = {
    Name = "SHAREDDATABASE_VPC"
  }
}

resource "aws_subnet" "SHAREDDATABASE_SUBNET" {
  vpc_id     = aws_vpc.SHAREDDATABASE_VPC.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "SHARED_DAYABASE_SUBNET"
  }
}

resource "aws_internet_gateway" "SHAREDDATABASE_IGW" {
  vpc_id     = aws_vpc.SHAREDDATABASE_VPC.id

  tags = {
    Name = "SHAREDDATABASE_IGW"
  }
}
# Create a default route table for shared database VPC
resource "aws_default_route_table" "SHAREDDATABASE_ROUTE" {
  default_route_table_id = aws_vpc.SHAREDDATABASE_VPC.default_route_table_id

  tags = {
    Name = "SHAREDDATABASE_ROUTE"
  }
}

# Create a default route for shared database VPC
resource "aws_route" "shareddatabase_route" {
  route_table_id         = aws_default_route_table.SHAREDDATABASE_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.SHAREDDATABASE_IGW.id 

  depends_on = [aws_vpc.SHAREDDATABASE_VPC]  
}

# Route to backend services VPC via Transit Gateway Attachment
resource "aws_route" "shared_database_to_backend_services" {
  route_table_id         = aws_default_route_table.SHAREDDATABASE_ROUTE.id
  destination_cidr_block = "11.0.0.0/16"  
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.shareddatabase_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.shareddatabase_attachment]
}

resource "aws_route" "shared_database_to_webapp" {
  route_table_id         = aws_default_route_table.SHAREDDATABASE_ROUTE.id
  destination_cidr_block = "10.0.0.0/16"  
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.shareddatabase_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.shareddatabase_attachment]
}