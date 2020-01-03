module "awx_azure" {
  source                     = "./awx_azure"

  location                   = "southeastasia"
  ssh_key                    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRFkSMRhSPT3YftfomhPVrEHHC8OWZ/nWPTNlnIDIK+kApe08dXHDUqJpwX7q6FAZTTD0//ctSX2xIHvbFyEhOOaRvsVBn61cxwR3kD470QyQzGDtvmVqWtTYDcYzQHP+t8jDHWdgX/5OFCQVcTwLUc4+ErM6kFZAELvzpAqnLuly8DQJ80KDhcOBmseJP+zIqUA6/kSDpOSruOyNKTLg8BC1Nn/6cT7GdltBGem2ZNfSThHGCloSjrJOckYFN7rGdhfbmV0kjWJzj0TMSKXH81f18YCcvQxpihBS2k+LsdpTMyVM7rPsZoWGmxsAohmpNMAnDx2HZue074eQr0ZtxUrFZu58SFG8ljuHYX68wBPMh6SUqDco2uZDBCj6coIZHjcf37njMqnyEBV0U8MdZK/v6N0tsU8+w26c4JRS30INyOvo8yVxGg6XWqfAJVMxx4ZBdTCrUgzUDAkgQUSPYZEFV59w3WC4zAtTdN5mNJzxwTtt9FnsSEfrbon6c89/RPWW9VT0QsByvtqSRG1vaAqthgtxoG2xNKOJcU3qU+Uu3MAhBm+5eXAAAXIYraRUmITgJTkpxYNpRzcCurWLGPMGe7mk2KJJcldPTL9tKAVhpcFJy9hXbM2qDYhCsT/WyQwbxmFf4Z0lGYDCswCpqq0w6hlKmZix7036+JuLl9Q=="

  kubernetes_client_id       = "${var.azure_client_id}"
  kubernetes_client_secret   = "${var.azure_client_secret}"

  tags                       = {
    Environment    = "dev"
  }
}
