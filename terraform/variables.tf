//Creating Variable for AMI_ID
variable "ami_id" {
  type    = string
  default = "ami-0022f774911c1d690"
}

//Creating Variable for AMI_Type
variable "ami_type" {
  type    = string
  default = "c5.2xlarge"
}

//Roo Volume
variable "root_volume_type" {
  default = "gp3"
}

variable "root_volume_size" {
  default = "20"
}

//Extra attached volume
variable "external_volume_type" {
  default = "gp3"
}

variable "external_volume_size" {
  default = "100"
}