variable "domain_vars" {
  type = map(string)
  default = {
    domainname = "sequafy.local"
    password   = "sE3q28uaf4y!"
  }
  description = "Parameters for creating the forest and domaincontrollers"
}

variable "public_ip" {
  type = string
  default = "0.0.0.0/32"
}