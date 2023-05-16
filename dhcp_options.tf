resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "sequafy.local"
  domain_name_servers = [aws_instance.dc01.private_ip, aws_instance.dc02.private_ip]
  ntp_servers         = [aws_instance.dc01.private_ip]
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_asso" {
  vpc_id          = aws_vpc.demo_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}