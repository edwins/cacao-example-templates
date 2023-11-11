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
  default = ""
}

variable "flavor" {
  type = string
  description = "flavor or size of instance to launch"
  default = "m1.tiny"
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

variable "user_data" {
  type = string
  description = "cloud init script"
  default = ""
}

variable "username" {
  type = string
  description = "username"
}

variable "enable_gpu" {
    type = bool
    description = "if set to true, will enable gpu; for example purposes since one can simply scan the flavor to set gpu"
    default = false
}