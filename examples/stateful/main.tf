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

  pool = {
    name                = module.naming.managed_devops_pool.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    dev_center = {
      name = module.naming.dev_center.name_unique
    }

    dev_center_project = {
      name = module.naming.dev_center_project.name
    }

    agent_profile = {
      kind                   = "Stateful"
      max_agent_lifetime     = "7.00:00:00"
      grace_period_time_span = "1:00:00"
    }

    fabric_profile = {
      sku_name = "Standard_D2ads_v5"
      images = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
      data_disks = [{
        caching              = "ReadWrite"
        disk_size_gigabytes  = 100
        storage_account_type = "Premium_LRS"
      }]
    }

    organization_profile = {
      organizations = [{
        url = var.ado_organization_url
      }]
    }

    maximum_concurrency = 1
  }

  tags = {
    environment = "demo"
  }
}
