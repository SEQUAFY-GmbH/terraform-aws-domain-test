resource "tls_private_key" "instance_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "instance_key_pair" {
  key_name   = "instance-key"
  public_key = tls_private_key.instance_key.public_key_openssh
}

resource "aws_instance" "dc01" {
  ami                    = "ami-0cf9380844da84d7e"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.1.20"
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.instance_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.rdp_public.id, aws_security_group.dc.id]
  tags = {
    Name = "DC01"
  }

  user_data = "${base64encode(<<EOF
  <powershell>
  ${templatefile("scripts/dc_forest.tftpl", var.domain_vars)}
  </powershell>
  EOF
  )}"
}

resource "time_sleep" "dc02_delay" {
  depends_on = [aws_instance.dc01]

  create_duration = "120s"
}

resource "aws_instance" "dc02" {
  ami                    = "ami-0cf9380844da84d7e"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.1.21"
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.instance_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.rdp_public.id, aws_security_group.dc.id]
  tags = {
    Name = "DC02"
  }

  user_data = "${base64encode(<<EOF
  <powershell>
  ${templatefile("scripts/dc_forest.tftpl", var.domain_vars)}
  </powershell>
  EOF
  )}"

  depends_on = [time_sleep.dc02_delay]

}

resource "time_sleep" "demohost_delay" {
  depends_on = [aws_instance.dc02]

  create_duration = "600s"
}

resource "aws_instance" "Demohost" {
  ami                    = "ami-0cf9380844da84d7e"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private.id
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.instance_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.rdp_public.id, aws_security_group.dc.id]
  tags = {
    Name = "Demohost"
  }
  user_data = "${base64encode(<<EOF
  <powershell>
  ${templatefile("scripts/domainjoin.tftpl", var.domain_vars)}
  </powershell>
  EOF
  )}"

  depends_on = [time_sleep.demohost_delay]

}

resource "aws_eip" "jumper_eip" {
  instance = aws_instance.jumper_host.id
  vpc      = true
}

resource "aws_instance" "jumper_host" {
  ami                    = "ami-0cf9380844da84d7e"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public.id
  availability_zone      = "eu-central-1a"
  vpc_security_group_ids = [aws_security_group.sg_jumper.id]
  key_name               = aws_key_pair.instance_key_pair.key_name
  tags = {
    Name = "Jumper Host"
  }

  user_data = "${base64encode(<<EOF
  <powershell>
  ${templatefile("scripts/prepare_jumper.tftpl", var.domain_vars)}
  </powershell>
  EOF
  )}"
}

resource "aws_security_group" "sg_jumper" {
  name   = "allow_rdp"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]

  }

  tags = {
    Name = "allow_rdp"
  }
}

resource "aws_security_group" "rdp_public" {
  name   = "rdp_from_public"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dc" {
  name   = "dc_internal"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}