# Establishing Azure Variables
variable "client_id" {
  type    = string
  default = "${env("CLIENT_ID")}"
  sensitive = false
}

variable "client_secret" {
  type    = string
  default = "${env("CLIENT_SECRET")}"
  sensitive = false
}

variable "subscription_id" {
  type    = string
  default = "${env("SUBSCRIPTION_ID")}"
  sensitive = false
}

variable "tenant_id" {
  type    = string
  default = "${env("TENANT_ID")}"
  sensitive = false
}

# Azure Source Information
source "azure-arm" "ubuntu-2004" {
  azure_tags = {
    dept = "Solution Engineering"
    task = "GitHub Packer Demo"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"
  location                          = "East US"
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "myResourceGroup"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.ubuntu-2004"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["apt-get update", "apt-get upgrade -y", "apt-get -y install nginx", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }

}
