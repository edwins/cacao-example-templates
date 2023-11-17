variable "project" {
  type = string
  description = "project name"
}

variable "region" {
  type = string
  description = "string, openstack region name; default = IU"
  default = "IU"
}

variable "instance_name" {
  type = string
  description = "name of instance"
}

variable "image" {
  type = string
  description = "string, image name"
  default = "Featured-Ubuntu22"
}

variable "flavor" {
  type = string
  description = "flavor or size of instance to launch"
  default = "m3.large"
}

variable "keypair" {
  type = string
  description = "keypair to use when launching"
  default = ""
}

variable "power_state" {
  type = string
  description = "power state of instance"
  default = "active"
}

variable "root_storage_size" {
  type = number
  description = "number, size in GB"
  default = 100
}

variable "user_data" {
  type = string
  description = "cloud init script"
  default = ""
}

variable "username" {
  type = string
  description = "username"
}
