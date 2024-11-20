variable "vpc_name" {
  type        = string
  description = "VPC network&subnet name"
}

variable "vpc_subnets" {
  description = "vpc_dev список"
  type = list(object({
    zone = string
    cidr = string
  }))
  default = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}