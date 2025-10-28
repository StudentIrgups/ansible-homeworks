module "vpc_dev" {
  source       = "./vpc_dev"
  vpc_name     = var.vpc_name
  cloud_id     = var.cloud_id
  folder_id    = var.folder_id
  mass_zones   = [
    { name = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_ubuntu_version
}

resource "yandex_compute_instance" "web" {
  count       = 4
  name        = "web${count.index + 1}"
  platform_id = var.vm_platform_id
  allow_stopping_for_update = true

  resources { 
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true    
  }
  network_interface {
    subnet_id          = module.vpc_dev.subnet_id[0].id
    nat                = true
  }

  metadata = {
    serial-port-enable = local.serial-port-enable
    ssh-keys           = "${local.ssh-keys}"  
  }
  
}