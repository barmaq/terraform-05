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
