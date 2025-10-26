output "web" {
  value =  [
    for k in yandex_compute_instance.web: {
      name = k.network_interface[0].nat_ip_address     
    }     
  ]  
}