# #====================================================================network.tf========================================


# USING EXISTING VPC RESOURCES=====================================================================================

# resource "aws_vpc" "vpc_ai" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_hostnames = true

#   tags = {
#     Name = "ai-vpc"
#   }
# }

# resource "aws_internet_gateway" "ai_vpc_igw" {
#   vpc_id = aws_vpc.vpc_ai.id
#   tags = {
#     Name = "ai-igw"
#   }
# }

# resource "aws_subnet" "ai_pub_subnet" {
#   vpc_id                  = aws_vpc.vpc_ai.id
#   cidr_block              = var.public_subnet_cidr
#   map_public_ip_on_launch = true

#   availability_zone = "ap-south-1a"

#   tags = {
#     Name = "ai-public-subnet"
#   }
# }

# resource "aws_route_table" "ai_rt" {
#   vpc_id = aws_vpc.vpc_ai.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.ai_vpc_igw.id
#   }
#   tags = {
#     Name = "public-route-table"
#    }
# }

# resource "aws_route_table_association" "ai_rt_sub_ascn" {
#   subnet_id      = aws_subnet.ai_pub_subnet.id
#   route_table_id = aws_route_table.ai_rt.id
# }


# variable "vpc_cidr" {
#   default = "10.27.0.0/16"
# }

# variable "public_subnet_cidr" {
#   default = "10.27.1.0/24"
# }