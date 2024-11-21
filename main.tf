# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

# начальный вариант
# module "vpc_dev" {
#   source        = "./vpc"
#   vpc_name      = var.vpc_name
#   default_zone  = var.default_zone
#   default_cidr  = var.default_cidr
# }

# вариант для задания 4. для нескольких сетей использовать переменную vpc_prod
module "vpc_dev" {
  source       = "./vpc2"
  vpc_name     = "production"
  vpc_subnets  =  var.vpc_dev
  
}

module "test-vm" {
#  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=0049a0c47c805c2552e16f7bca2581a7feae0f14"
  env_name       = var.vm_name 
  network_id     = module.vpc_dev.yandex_vpc_net_info.id
  subnet_zones   = [for key, subnet in module.vpc_dev.yandex_vpc_subnet_info : subnet.zone]
  subnet_ids     = [for key, subnet in module.vpc_dev.yandex_vpc_subnet_info : subnet.id]
  instance_name  = local.vm_labels[0].project
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    project = local.vm_labels[0].project
     }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered 
    serial-port-enable = 1
  }

}

module "test-vm2" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=0049a0c47c805c2552e16f7bca2581a7feae0f14"
#  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = var.vm_name 
  network_id     = module.vpc_dev.yandex_vpc_net_info.id
  subnet_zones   = [for key, subnet in module.vpc_dev.yandex_vpc_subnet_info : subnet.zone]
  subnet_ids     = [for key, subnet in module.vpc_dev.yandex_vpc_subnet_info : subnet.id]
  instance_name  = local.vm_labels[1].project
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    project = local.vm_labels[1].project
     }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered 
    serial-port-enable = 1
  }

}


# #передача cloud-config
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key     = file("~/.ssh/ycbarmaq.pub")
  }

}



#задача 4
#валидация через cidrhost
variable "ip_address" {
  type        = string
  description = "ip-адрес"
#  default     = "1920.1680.0.1"
  default     = "192.168.0.1"

  validation {
    condition     = can(cidrhost(join("/", [var.ip_address, "32"]), 0))
    error_message = "ip-адрес должен быть в формате x.x.x.x, где x - это число от 0 до 255."
  }
}

#вариант с regex  
# variable "ip_address" {
#   type        = string
#   description = "ip-адрес"
#   default     = "192.168.0.1"

#   validation {
#     condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.ip_address))
#     error_message = "ip-адрес должен быть в формате x.x.x.x, где x - это число от 0 до 255."
#   }
# }

variable "ip_addresses" {
  type        = list(string)
  description = "список ip-адресов"
#  default     = ["192.168.0.1", "1.1.1.1", "1270.0.0.1"]
  default     = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]

  validation {
    condition     = alltrue([for ip in var.ip_addresses : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))])
    error_message = "все ip-адреса в списке должны быть в формате x.x.x.x. где x - это число от 0 до 255"
  }
}


variable "low_case" {
  type        = string
  description = "строка только в нижнем регистре"
  default     = "hello world 13!, привет мир"

  validation {
    condition     = can(regex("^[^A-ZА-ЯЁ]*$", var.low_case))
    error_message = "в строке недопустимы заглавные  буквы"
  }
}


variable "in_the_end_there_can_be_only_one" {
  description = "Who is better Connor or Duncan?"
  type = object({
    Dunkan = optional(bool)
    Connor = optional(bool)
  })

  default = {
    Dunkan = true
    Connor = false
  }

  validation {
    condition     = (var.in_the_end_there_can_be_only_one.Dunkan != var.in_the_end_there_can_be_only_one.Connor)
    error_message = "There can be only one MacLeod. Either Dunkan or Connor must be true, but not both."
  }
}