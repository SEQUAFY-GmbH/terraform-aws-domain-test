resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.2.0/24"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}