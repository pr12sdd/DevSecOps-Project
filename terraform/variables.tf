variable "aws-ami" {
  default = "ami-0f5fcdfbd140e4ab7"
  type = string
}

variable "aws-instance-type" {
  default="t2.large"
  type = string
}

variable "aws-volume-size" {
  default = 30
  type = number
}
variable "aws-volume-type" {
  default = "gp3"
  type=string
}