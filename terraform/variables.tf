variable "kubernetes_client_id" {
  description = "The Client ID (appId) for the Service Principal used for the AKS"
}

variable "kubernetes_client_secret" {
  description = "The Client Secret (password) for the Service Principal used for the AKS"
}

variable "kubernetes_sp_object_id" {
  description = "The Object ID for the Service Principal used for the AKS"
}
