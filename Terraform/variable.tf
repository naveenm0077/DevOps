variable "instance_type" {
  type    = string
  default = "t3.micro"
}



variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}