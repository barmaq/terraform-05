terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.8.4"
}

# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = "${var.vpc_name}-subnet"
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

resource "yandex_vpc_network" "develop" {
  name = "${var.vpc_name}-network"
}

resource "yandex_vpc_subnet" "develop" {
  for_each = { for subnet in var.vpc_subnets : "${subnet.zone}-${subnet.cidr}" => subnet }

  name           = "${var.vpc_name}-${each.value.zone}"
  zone           = each.value.zone
  v4_cidr_blocks = [each.value.cidr]
  network_id     = yandex_vpc_network.develop.id 

  labels = {
    environment = var.vpc_name
  }
}
