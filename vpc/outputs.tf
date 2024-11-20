
output "yandex_vpc_net_info" {
  description = "yandex vpc"
  value       = yandex_vpc_network.develop
}

output "yandex_vpc_subnet_info" {
  description = "yandex vpc subnet"
  value       = yandex_vpc_subnet.develop
}