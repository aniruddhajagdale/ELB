variable "region" {

}
variable "ami" {}

variable "elb-log-bucket" {

}
variable "bucket_prefix" {
  
}


data "aws_availability_zones" "az-name" {}

data "aws_security_groups" "sg" {
  filter {
    name   = "vpc-id"
    values = ["vpc-fb313b93"]
  }
}
