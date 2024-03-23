terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
}

# get ssh key
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}


# Configure aws provider
provider "aws" {
	region = "us-west-2"
}


# Create a vpc
resource "aws_vpc" "fantasy_vpc" {
	cidr_block = "18.0.0.0/20"
		# Name the instance

  	tags = {
    	Name = "fantasy-vpc"
  	}
}

# Create public subnet
resource "aws_subnet" "public_subnet_one" {
	vpc_id = aws_vpc.fantasy_vpc.id
	cidr_block = "18.0.0.0/23"
	availability_zone = "us-west-2a"
	map_public_ip_on_launch = true
	
	# Name the subnet
  	tags = {
    	Name = "fantasy-public-subnet-one"
  	}
}

# Create private subnet
resource "aws_subnet" "private_subnet_one" {
	vpc_id = aws_vpc.fantasy_vpc.id
	cidr_block = "18.0.2.0/23"
	availability_zone = "us-west-2a"
	map_public_ip_on_launch = false
	
	# Name the subnet
  	tags = {
    	Name = "fantasy-public-subnet-two"
  	}
}

# Create internet gateway
resource "aws_internet_gateway" "fantasy_gateway" {
	vpc_id = aws_vpc.fantasy_vpc.id
	
	# Name the subnet
  	tags = {
    	Name = "fantasy-gateway"
  	}
}

# Public routes
resource "aws_route_table" "fantasy_public_route_table" {
    vpc_id = aws_vpc.fantasy_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.fantasy_gateway.id
    }
    
    tags = {
        Name = "fantasy_public_route_table"
    }
}

resource "aws_route_table_association" "fantasy_route_table_association"{
    subnet_id = aws_subnet.public_subnet_one.id
    route_table_id = aws_route_table.fantasy_public_route_table.id
}

// ec2 security group
resource "aws_security_group" "fantasy_security_group" {
	name = "fantasy_security_group"
	vpc_id = "${aws_vpc.fantasy_vpc.id}"
	ingress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 22
		to_port = 22
		protocol = "tcp"
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 7946
		to_port = 7946
		protocol = "udp"
	}
	egress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 7946
		to_port = 7946
		protocol = "udp"
	}
	ingress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 2377
		to_port = 2377
		protocol = "tcp"
	}
	egress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 2377
		to_port = 2377
		protocol = "tcp"
	}
	ingress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 4789
		to_port = 4789
		protocol = "udp"
	}
	egress {
		cidr_blocks = [
		"0.0.0.0/0"
		]
		from_port = 4789
		to_port = 24789
		protocol = "udp"
	}
}

# Create ec2 instance
resource "aws_instance" "farc-instance" {
	ami = "ami-0c2d06d50ce30b442"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.public_subnet_one.id
	key_name = aws_key_pair.ssh_key.key_name
	security_groups = [aws_security_group.fantasy_security_group.id]
	
	# Name the instance
  	tags = {
    	Name = "farc"
  	}


	# Copy in the bash script for installing and configuring docker swarm.
	provisioner "file" {
		source      = "install-docker.sh"
		destination = "/home/ec2-user/install-docker.sh"
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}

	# Change permissions on bash script and execute from ec2-user.
	provisioner "remote-exec" {
		inline = [
		"chmod +x /home/ec2-user/install-docker.sh",
		"sudo /home/ec2-user/install-docker.sh",
		]
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}

	# initiate docker swarm manager node.
	provisioner "file" {
		source      = "initiate-swarm.sh"
		destination = "/home/ec2-user/initiate-swarm.sh"
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}
	provisioner "remote-exec" {
		inline = [
		"chmod +x /home/ec2-user/initiate-swarm.sh",
		"sudo /home/ec2-user/initiate-swarm.sh",
		]
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}
}


data "external" "swarm_join_token" {
  program = ["./get-join-token.sh"]
  query = {
    host = "${aws_instance.farc-instance.public_ip}"
  }
}

# Create another ec2 instance
resource "aws_instance" "contra-instance" {
	ami = "ami-0c2d06d50ce30b442"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.public_subnet_one.id
	key_name = aws_key_pair.ssh_key.key_name
	security_groups = [aws_security_group.fantasy_security_group.id]

	# Name the instance
  	tags = {
    	Name = "contra"
  	}


	# Copy in the bash script for installing and configuring docker swarm.
	provisioner "file" {
		source      = "install-docker.sh"
		destination = "/home/ec2-user/install-docker.sh"
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}


	provisioner "remote-exec" {
		inline = [
		"chmod +x /home/ec2-user/install-docker.sh",
		"sudo /home/ec2-user/install-docker.sh",
		"sudo docker swarm join --token ${data.external.swarm_join_token.result.worker} ${aws_instance.farc-instance.public_ip}:2377",
		]
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("~/.ssh/id_rsa")
			host        = self.public_ip
		}
	}
}

# allows us to query the swarm manager using terraform shortcut
# terraform output manage_public_ip
output "manager_public_ip" {
  value = "${aws_instance.farc-instance.public_ip}"
}
