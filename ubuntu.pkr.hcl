source "azure-arm" "ubuntu-2004" {
  azure_tags = {
    dept = "Solution Engineering"
    task = "GitHub Packer Demo"
  }
  client_id                         = ""
  client_secret                     = ""
  subscription_id                   = ""
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "20.04-LTS"
  location                          = "East US"
  managed_image_name                = "oeghaneyan-ubuntu-2004"
  managed_image_resource_group_name = "oeghaneyan-demos"
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
