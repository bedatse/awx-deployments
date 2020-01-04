variable "aks_service_name" {
  description = "The Service Name of the Ansible AWX service"
}

variable "location" {
  description = "Location of the Ansible AWX deployment"
}

variable "ssh_key" {
  description = "SSH Public Key for Agent Node"
}

variable "tags" {
  description = "Tags to be added to each resources"
  default = {}
}
