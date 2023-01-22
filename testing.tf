resource "azurerm_resource_group" "AKSS" {
  name     = "AKSS-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "AKSS" {
  name                = "AKSS-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.AKSS.location
  resource_group_name = azurerm_resource_group.AKSS.name
}

resource "azurerm_subnet" "AKSS" {
  name                 = "AKSS-subnet"
  resource_group_name  = azurerm_resource_group.AKSS.name
  virtual_network_name = azurerm_virtual_network.AKSS.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "AKSS" {
  name                = "AKSS-nic"
  location            = azurerm_resource_group.AKSS.location
  resource_group_name = azurerm_resource_group.AKSS.name

  ip_configuration {
    name                          = "AKSS"
    subnet_id                     = azurerm_subnet.AKSS.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "AKSS" {
  name                  = "AKSS-vm"
  location              = azurerm_resource_group.AKSS.location
  resource_group_name   = azurerm_resource_group.AKSS.name
  network_interface_ids = [azurerm_network_interface.AKSS.id]
  vm_size               = "Standard_B1s" # Within Free Tier Limits

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "AKSS-os-disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "AKSS-vm"
    admin_username = "your-admin-username"
    admin_password = "your-admin-password"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
