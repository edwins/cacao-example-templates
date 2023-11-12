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

variable "image_uuid" {
  type = string
  description = "string, image id; image will have priority if both image and image name are provided"
  default = ""
}


variable "image" {
  type = string
  description = "string, image id; image will have priority if both image and image name are provided"
  default = "Featured-Ubuntu22"
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
