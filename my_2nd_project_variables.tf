# Define variables to be used with Terraform. 

# Define Sub-Id variable. 
variable "subscription_id" {
  type    = string
  default = "d40df8e9-d3c9-4a68-8333-af374546254c"
}

# Define Resource Group variable.
variable "resource_group_name" {
  type    = string
  default = "anksolrgvk"
}

# Define Location variable.
variable "location" {
  type    = string
  default = "eastus"
}

# Define Virtual Network (vnet) variable.
variable "vnet_name" {
  type    = string
  default = "myVnet00121"
}

# Define Virtual Subnet (snet) variable.
variable "subnet_name" {
  type    = string
  default = "mySnet12100"
}

# Define Network Security Group (NSG) variable.
variable "nsg_name" {
  type    = string
  default = "myNSG001"
}

# Define Public IP variable
variable "NIC1pubipname" {
  type    = string
  default = "mypubip001"
}

# Define Public IP variable
variable "NIC2pubipname" {
  type    = string
  default = "mypubip002"
}

# Define Virtual Machine 1 variable.
variable "vm1Name" {
  type    = string
  default = "adminvm0021"
}

# Define Virtual Machine 2 variable.
variable "vm2Name" {
  type    = string
  default = "uservm0021"
}

# Define Virtual Machine 1 Network Interface Card (NIC) variable.
variable "nic1" {
  type    = string
  default = "myfstNIC01"
}

# Define Virtual Machine 2 Network Interface Card (NIC) variable.
variable "nic2" {
  type    = string
  default = "mysecNIC02"
}

# Define Virtual Machine 1 Credentials.
variable "admin_name" {
  type    = string
  default = "adminqtecmai"
}
variable "admin_password" {
  type    = string
  default = "P@ssword456rV$"
}

# Define Virtual Machine 2 Credentials.
variable "user_name" {
  type    = string
  default = "usersqtech"
}
variable "user_password" {
  type    = string
  default = "Ynae25iasdfas"
}