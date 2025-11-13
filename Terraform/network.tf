resource "aws_vpc" "proj_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "createdBy" = "Naveen and Abhilash"
  }
}

resource "aws_subnet" "proj_sub" {
  vpc_id = aws_vpc.proj_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "ngnix-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = { Name = "tf-basic-igw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.proj_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.proj_sub.id
}