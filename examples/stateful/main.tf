module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.29"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 1.0"

  config = {
    name                = module.naming.managed_devops_pool.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    dev_center = {
      name = module.naming.dev_center.name_unique
    }

    dev_center_project = {
      name = module.naming.dev_center_project.name
    }

    stateful_agent = {
      grace_period_time_span = "1:00:00"
    }

    virtual_machine_scale_set_fabric = {
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
      storage = [{
        caching              = "ReadWrite"
        disk_size_in_gb      = 100
        storage_account_type = "Premium_LRS"
      }]
    }

    azure_devops_organization = {
      organization = [{
        url = var.ado_organization_url
      }]
    }

  }

  tags = {
    environment = "demo"
  }
}
