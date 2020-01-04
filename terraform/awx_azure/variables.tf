variable "awx_service_name" {
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

variable "kubernetes_client_id" {
  description = "The Client ID (appId) for the Service Principal used for the AKS"
}

variable "kubernetes_client_secret" {
  description = "The Client Secret (password) for the Service Principal used for the AKS"
}

variable "kubernetes_sp_object_id" {
  description = "The Object ID for the Service Principal used for the AKS"
}
