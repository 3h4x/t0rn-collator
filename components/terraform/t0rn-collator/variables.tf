variable "region" {
  type        = string
  description = "Region"
}

variable "instance_type" {
  type        = string
  description = "Collator instance type"
}

variable "volume_size" {
  type        = number
  description = "Collator volume size"
}

variable "volume_type" {
  type        = string
  description = "Collator volume type"
}

variable "rococo_boot_node" {
  type = string
  description = "Boot node for Rococo"
}

variable "t0rn_boot_node" {
  type = string
  description = "Boot node for t0rn"
}

variable "collator_name" {
  type = string
  description = "Name of the collator"
}

variable "collator_image" {
  type = string
  description = "Collator image repository and tag to use"
}