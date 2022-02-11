provider "aws"{
    region="us-east-1"
    access_key=""
    secret_key=""
}
#Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "Igway" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.vpc_.id               # vpc_id will be generated after we create VPC
 }
#VPC
 resource "aws_vpc" "vpc_" {                # Creating VPC here
   cidr_block       = "10.22.0.0/16"   # Defining the CIDR block use 10.0.0.0/24 for demo
tags= {
        Name = "vpc__L"
    }
 }



output "aws_vpc_id" {
  value = aws_vpc.vpc_.id
}
 # Subnet 2
 resource "aws_subnet" "onesubnets" {    # Creating Public Subnets
   vpc_id =  aws_vpc.vpc_.id
   cidr_block = "10.22.0.0/24"  
     availability_zone = "us-east-1a"      
     tags= {
        Name = "subnet1L"
    }
 }
#Subnet       1             # Creating Private Subnets
 resource "aws_subnet" "secsubnets" {
   vpc_id =  aws_vpc.vpc_.id
   cidr_block = "10.22.1.0/24"  
     availability_zone = "us-east-1b"    
     tags= {
        Name = "sub2L"
    }
 }
 output "aws_sub1_id" {
  value = aws_subnet.onesubnets.id
}
output "aws_sub2_id" {
  value = aws_subnet.secsubnets.id
}
#Route table for
 resource "aws_route_table" "oneRT" {    
    vpc_id =  aws_vpc.vpc_.id
         route {
    cidr_block = "0.0.0.0/0"              
    gateway_id = aws_internet_gateway.Igway.id
     }
     route {
   ipv6_cidr_block = "::/0"
   gateway_id      = aws_internet_gateway.Igway.id
   }
     
 }
output "aws_1RT_id" {
  value = aws_route_table.oneRT.id
}
 resource "aws_route_table" "secRT" {  
   vpc_id = aws_vpc.vpc_.id
   route {
   cidr_block = "0.0.0.0/0"            
   gateway_id = aws_internet_gateway.Igway.id
   }
   
 }
 output "aws_sRT_id" {
  value = aws_route_table.secRT.id
}
 #Route table Association
 resource "aws_route_table_association" "oneRTassociation" {
    subnet_id = aws_subnet.onesubnets.id
    route_table_id = aws_route_table.oneRT.id
   
 }
 
 resource "aws_route_table_association" "secRTassociation" {
    subnet_id = aws_subnet.secsubnets.id
    route_table_id = aws_route_table.secRT.id
   
 }
output "aws_1RTs_id" {
  value = aws_route_table_association.oneRTassociation.id
}
output "aws_1RTas_id" {
  value = aws_route_table_association.secRTassociation.id
}
 
 
# security group
resource "aws_security_group" "ssh-allowed" {
    vpc_id = aws_vpc.vpc_.id
    ingress {
    // protocol    = "tcp"
    // from_port   = 0
    // to_port     = 3306
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh !
        // Do not do it in the production.
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
       ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 343
    to_port     = 343
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
    tags= {
        Name = "ssh-allowed"
    }
}
output "aws_sg_id" {
  value = aws_security_group.ssh-allowed.id
}
 
 
resource "aws_network_interface" "web_server"{
    subnet_id=aws_subnet.onesubnets.id
    private_ips=["10.22.0.10"]
    security_groups=[aws_security_group.ssh-allowed.id]
 

}
resource "aws_eip" "one"{
    vpc=true
    network_interface=aws_network_interface.web_server.id
    associate_with_private_ip="10.22.0.10"
    depends_on=[aws_internet_gateway.Igway]
}

resource "aws_instance" "web1ab" {
    ami = "ami-04505e74c0741db8d"
    availability_zone= "us-east-1a"
    instance_type = "t2.micro"
    key_name="""
    
    network_interface{
        device_index=0
        network_interface_id=aws_network_interface.web_server.id
    }

   
    
    tags={Name="server10LB"}
  
 
  
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

