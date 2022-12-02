variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "client_certificate_path" {
  default = "C:\\Users\\ccrain.TREMBLANT\\Documents\\Git\\SRProject\\certs\\phxcert.pfx"
}  
  
variable "client_certificate_password" {
  default = "phxauto"
}

variable "cidr_block" {
  default = ["10.0.0.0/16"]
}

variable "cidr_subnetblock" {
  default = "10.0.1.0/24"
}


