variable "dc_promo_vars" {
  type = map(string)
  default = {
    domainname = "sequafy.local"
    password   = "sE3q28uaf4y!"
  }
  description = "Parameters for creating the forest and domaincontrollers"
}

variable "domainjoin_vars" {
  type = map(string)
  default = {
    domainname     = "sequafy.local"
    admin_password = "sE3q28uaf4y!"
  }
  description = "Parameters for joining the demhost to the domain and creating a demouser"
}

variable "create_demo" {
  type        = bool
  default     = true
  description = "Decide wether to create a domainjoined demohost and a demouser"
}