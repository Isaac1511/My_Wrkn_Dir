# Project Brick by Brick: Build out and test creation of vnet, snet, 2 VMs, etc: 

# Define Providers and features
terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=1.6.4"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}

  subscription_id = var.subscription_id
}

# Added Creating resource group 
resource "azurerm_resource_group" "AnkSolRGtf" {
  name     = var.resource_group_name
  location = var.location
}

# Added Creating local state files 4/7/24@1047
terraform {}


# Create virtual network
resource "azurerm_virtual_network" "tfvnetname" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.AnkSolRGtf] # This ensures that the virtual network waits for the resource group to be created

  tags = {
    environment = "Terraform Networking"
  }
}

# Create subnet - Both VMs will be on the same subnet.
resource "azurerm_subnet" "tfsubnet1name" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.tfvnetname.name
  address_prefixes     = ["10.0.0.0/24"]

  depends_on = [azurerm_virtual_network.tfvnetname] # This ensures that the Subnet waits for the virtual network to be created

}

# Create NSG
resource "azurerm_network_security_group" "tfnsgname" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_subnet.tfsubnet1name] # This ensures that the Subnet waits for the virtual network to be created

  tags = {
    environment = "Terraform Networking"
  }
}

# Add Inbound NSG rules
resource "azurerm_network_security_rule" "tfallowrdpin" {
  name                        = "AllowRDPIn"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.tfnsgname.name

  depends_on = [azurerm_network_security_group.tfnsgname] # This ensures that the Subnet waits for the virtual network to be created
}

resource "azurerm_network_security_rule" "tfdenywebin" {
  name                        = "DenywebIn"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "8080"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.tfnsgname.name

  depends_on = [azurerm_network_security_rule.tfallowrdpin] # This ensures that the Subnet waits for the virtual network to be created
}

resource "azurerm_network_security_rule" "tfallowinwebin" {
  name                        = "SSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.tfnsgname.name

  depends_on = [azurerm_network_security_rule.tfdenywebin] # This ensures that the Subnet waits for the virtual network to be created
}

# Add Outbound NSG rules
resource "azurerm_network_security_rule" "tfdenyoutwebout" {
  name                        = "DenyOutWebOut"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "80"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.tfnsgname.name

  depends_on = [azurerm_network_security_rule.tfallowinwebin] # This ensures that the Subnet waits for the virtual network to be created
}

# Create public IP address for NIC1
resource "azurerm_public_ip" "tfnic1_public_ip" {
  name                = var.NIC1pubipname
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  depends_on = [azurerm_network_security_rule.tfdenyoutwebout] # This ensures that the Subnet waits for the virtual network to be created
}

#Create private address for NIC1
resource "azurerm_network_interface" "tfmynic1" {
  name                = var.nic1
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.tfsubnet1name.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfnic1_public_ip.id
  }

  depends_on = [azurerm_public_ip.tfnic1_public_ip] # This ensures that Subnet waits for virtual network to be created
}

# Associate NSG with NIC1
resource "azurerm_network_interface_security_group_association" "tf_nic1_nsg_association" {
  network_interface_id      = azurerm_network_interface.tfmynic1.id
  network_security_group_id = azurerm_network_security_group.tfnsgname.id

  depends_on = [azurerm_network_interface.tfmynic1] # Ensure NIC1 is created before associating
}

# Create public IP address for NIC2
resource "azurerm_public_ip" "tfnic2_public_ip" {
  name                = var.NIC2pubipname
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  depends_on = [azurerm_network_interface.tfmynic1] # This ensures that PUB NIC2 waits for to be created
}

#Create private address for NIC2
resource "azurerm_network_interface" "tfmynic2" {
  name                = var.nic2
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.tfsubnet1name.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfnic2_public_ip.id
  }

  depends_on = [azurerm_public_ip.tfnic2_public_ip] # This ensures that NIC2 waits for Pub NIC2 to be created
}

# Associate NSG with NIC2
resource "azurerm_network_interface_security_group_association" "tf_nic2_nsg_association" {
  network_interface_id      = azurerm_network_interface.tfmynic2.id
  network_security_group_id = azurerm_network_security_group.tfnsgname.id
}

# Create virtual machine 1
resource "azurerm_linux_virtual_machine" "tfmyfstlinvm001" {
  name                = var.vm1Name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls"

  admin_username                  = var.admin_name
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface_ids = [azurerm_network_interface.tfmynic1.id]

  depends_on = [azurerm_network_interface.tfmynic2] # This ensures that VM1 waits for NIC2 to be created
}


# Create virtual machine 2
resource "azurerm_linux_virtual_machine" "tfmyfstlinvm002" {
  name                = var.vm2Name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls"

  admin_username                  = var.user_name
  admin_password                  = var.user_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface_ids = [azurerm_network_interface.tfmynic2.id]

  depends_on = [azurerm_linux_virtual_machine.tfmyfstlinvm001] # This ensures that VM2 waits for VM1 to be created
}