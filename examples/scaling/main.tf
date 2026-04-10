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

    stateless_agent = {
      manual_resource_prediction = {
        monday_schedule = [
          { count = 2, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        tuesday_schedule = [
          { count = 2, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        wednesday_schedule = [
          { count = 2, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        thursday_schedule = [
          { count = 2, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        friday_schedule = [
          { count = 2, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
      }
    }

    virtual_machine_scale_set_fabric = {
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
    }

    azure_devops_organization = {
      organization = [{
        url         = var.ado_organization_url
        parallelism = 2
      }]
    }

    maximum_concurrency = 2
  }

  tags = {
    environment = "demo"
  }
}
