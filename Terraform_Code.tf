provider "aws" {
  region     = "us-east-1"
}

resource "aws_vpc" "myvpc_resourcename" {

  cidr_block       = "192.168.0.0/16"

  instance_tenancy = "default"

 tags = {

    Name = "Web Portal Deployment"

         }

}

output "printvpc_id" {

      value = aws_vpc.myvpc_resourcename.id

                 }

resource "aws_subnet" "Public" {

  vpc_id     = aws_vpc.myvpc_resourcename.id

  cidr_block = "192.168.0.0/24"

  map_public_ip_on_launch = true

  availability_zone = "us-east-1a"

  tags = {

    Name = "Public Subnet"

  }

}

resource "aws_subnet" "Private" {

  vpc_id     = aws_vpc.myvpc_resourcename.id

  cidr_block = "192.168.1.0/24"

  availability_zone = "us-east-1b"

  tags = {

    Name = "Private Subnet"

  }

}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.myvpc_resourcename.id

tags = {

    Name = "Wordpress Internet Gateway"

  }

}

resource "aws_route_table" "wproutingtable" {

  vpc_id = aws_vpc.myvpc_resourcename.id

 tags = {

    Name = "Wordpress Routing Table"

  }


}

resource "aws_route" "r" {
  route_table_id            =   aws_route_table.wproutingtable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =  aws_internet_gateway.gw.id
  
}


resource "aws_route_table_association" "rt_attach_subnet" {

  subnet_id      = aws_subnet.Public.id

  route_table_id = aws_route_table.wproutingtable.id

}
resource "aws_route_table_association" "rt_attach_subnet2" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.wproutingtable.id
}

resource "aws_security_group" "securitygroup" {                      
  name        = "launch-wizard-1"
  description = "this security group will allow traffic at port 80"
    vpc_id = aws_vpc.myvpc_resourcename.id
      
  ingress {
    description = "http is allowed"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
ingress {
    description = "ssh is allowed"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
  tags = {
    Name = "Wordpress Security Group"                   
  }
}

 resource  "aws_security_group" "securitygroup2" {                      
  name        = "launch-wizard-2"
  description = "this security group will allow traffic at port 80"
    vpc_id = aws_vpc.myvpc_resourcename.id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
    description = "mysql"
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }


	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "MySQL Security Group"                   
  }

}

resource "aws_instance" "myinstance" {

  ami           = "ami-01d50ebc11ce4a9f9"

  instance_type = "t2.micro"

  key_name = "credits"

  vpc_security_group_ids = [ aws_security_group.securitygroup.id ]                

  subnet_id      = aws_subnet.Public.id

tags = {

   	  Name = "Wordpress"

       	        }

}
resource "aws_instance" "mysqlinstance_rn" {
  ami           = "ami-0054cff8bcd7a1b3a"
  instance_type = "t2.micro"
  key_name = "credits"
      
  vpc_security_group_ids = [ aws_security_group.securitygroup2.id ]               
  subnet_id = aws_subnet.Private.id 
tags = {
   	  Name = "MySQL"
       	        }

                                         }