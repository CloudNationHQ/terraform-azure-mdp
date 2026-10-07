module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.29"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.0.0.0/16"]

    subnets = {
      agents = {
        network_security_group = {}
        address_prefixes       = ["10.0.1.0/24"]
        delegations = {
          mdp = {
            name    = "Microsoft.DevOpsInfrastructure/pools"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      }
    }
  }
}

module "rbac" {
  source  = "cloudnationhq/rbac/azure"
  version = "~> 4.0"

  role_assignments = {
    "DevOpsInfrastructure" = {
      display_name = "DevOpsInfrastructure"
      type         = "ServicePrincipal"
      roles = {
        "Reader" = {
          scopes = {
            vnet = { id = module.network.vnet.id }
          }
        }
        "Network Contributor" = {
          scopes = {
            vnet = { id = module.network.vnet.id }
          }
        }
      }
    }
  }
}

module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 2.0"

  depends_on = [module.rbac]

  ado_organization_url = var.ado_organization_url

  pool = {
    name                = module.naming.managed_devops_pool.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    maximum_concurrency = 1

    dev_center = {
      name = module.naming.dev_center.name_unique
    }

    dev_center_project = {
      name = module.naming.dev_center_project.name
    }

    stateless_agent = {}

    virtual_machine_scale_set_fabric = {
      sku_name  = "Standard_D2ads_v5"
      subnet_id = module.network.subnets.agents.id
      image = {
        primary = {
          well_known_image_name = "ubuntu-24.04/latest"
        }
      }
    }

    azure_devops_organization = {
      organization = {
        demo = {
          parallelism = 1
        }
      }
    }

  }

  tags = {
    environment = "demo"
  }
}
