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

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

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
  version = "~> 2.0"

  role_assignments = {
    "DevOpsInfrastructure" = {
      display_name = "DevOpsInfrastructure"
      type         = "ServicePrincipal"
      roles = {
        "Reader" = {
          scopes = {
            vnet = module.network.vnet.id
          }
        }
        "Network Contributor" = {
          scopes = {
            vnet = module.network.vnet.id
          }
        }
      }
    }
  }
}

module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 1.0"

  depends_on = [module.rbac]

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

    stateless_agent = {}

    virtual_machine_scale_set_fabric = {
      subnet_id = module.network.subnets.agents.id
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
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
