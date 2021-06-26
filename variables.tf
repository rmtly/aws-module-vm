variable "environment" {
  description = "The software execution environment to deploy in."
  type = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the VM."
  type = string
}

variable "instance_size" {
  description = "The size of the EC2 VM to create."
  type = string
}

variable "root_disk_gbs" {
  description = "The size of the root volume for the VM."
  type = number
  default = 8
}

variable "managed_disk_gbs" {
  description = "The number of GB available in the managed disk attached to the VM."
  type = number
  default = 50
}

variable "ssh_public_key_path" {
  description = "The filename of the SSH key to authorize on VMs."
  type = string
}

variable "availability_zone" {
  description = "The availability zone in which to deploy resources; must be within var.region."
  type = string
  default = "ca-central-1a"
}

variable "security_group_name" {
  description = "The name of the security group in which to put the VM (must already exist)."
  type = string
}

variable "parent_domain_name" {
  type = string
  default = null
}

variable "hostname" {
  description = "The name of the VM and the hostname component of the VM's FQDN, if a parent_domain_name is given."
  type = string
}
