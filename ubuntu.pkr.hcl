# Set Packer Azure Plugin
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

# Time stamps for image file placed into Cloud
locals {
	timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

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
source "azure-arm" "ubuntu-1804" {
  azure_tags = {
    dept = "Solution Engineering"
    task = "GitHub Packer Demo"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  build_resource_group_name         = "oeghaneyan-demos"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "18.04-LTS"
  managed_image_name                = "ubuntu-1804-${local.timestamp}"
  managed_image_resource_group_name = "oeghaneyan-demos"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

# Build Information

build {
	
  hcp_packer_registry {
    bucket_name = "ubuntu-image"
    description = <<EOT
      This is an image for Ubuntu 18.04.
    EOT
    bucket_labels = {
      "os" = "ubuntu",
    }
  }	
	
  sources = ["source.azure-arm.ubuntu-1804"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["apt-get update", "apt-get upgrade -y", "apt-get -y install nginx", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }
	  
  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }	  

}
