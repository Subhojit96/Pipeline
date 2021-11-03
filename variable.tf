variable "vpc" {
  default = "172.16.0.0/16"
  type =  string
}

variable "subnet" {
  type = string
  default = "172.16.0.0/24"
}

variable "availablityzone" {
  type = string
  default = "us-east-1a"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string  
}