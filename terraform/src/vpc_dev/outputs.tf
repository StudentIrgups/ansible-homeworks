output "network_id" {
    value = yandex_vpc_network.develop.id
}

output "subnet_id" {
  value =  [
    for k in yandex_vpc_subnet.develop: {
      id   = k.id
    }     
  ] 
}