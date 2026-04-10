# Managed DevOps Pool

Terraform module which creates Managed DevOps Pool resources on Azure.

## Features

- Deploys Azure Managed DevOps Pools via the native AzureRM provider
- Optionally creates a Dev Center and Dev Center Project
- Supports both Stateless and Stateful agent profiles
- Supports Manual and Automatic resource prediction (stand-by agents)
- Supports VMSS fabric with custom VM images and data disks
- Supports networking integration via subnet configuration
- Supports Azure DevOps organization profiles
- Supports User-assigned managed identity
- Supports RBAC role assignments on the pool

## Usage

```hcl
module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 1.0"

  config = {
    name                = "pool-demo-dev"
    location            = "westeurope"
    resource_group_name = "rg-demo-dev"

    dev_center = {
      name = "dc-demo-dev"
    }

    dev_center_project = {
      name = "dcp-demo-dev"
    }

    stateless_agent = {}

    virtual_machine_scale_set_fabric = {
      sku_name = "Standard_D2ads_v5"
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
    }

    azure_devops_organization = {
      organization = [{
        url = "https://dev.azure.com/myorg"
      }]
    }

    maximum_concurrency = 1
  }
}
```

## Stateful pool with manual scaling schedule

```hcl
module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 1.0"

  config = {
    name                = "pool-demo-dev"
    location            = "westeurope"
    resource_group_name = "rg-demo-dev"

    dev_center_project_id = azurerm_dev_center_project.existing.id

    stateful_agent = {
      maximum_agent_lifetime = "7.00:00:00"
      grace_period_time_span = "1:00:00"
      manual_resource_prediction = {
        time_zone_name = "UTC"
        monday_schedule = [
          { count = 3, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        tuesday_schedule = [
          { count = 3, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        wednesday_schedule = [
          { count = 3, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        thursday_schedule = [
          { count = 3, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
        friday_schedule = [
          { count = 3, time = "07:00:00" },
          { count = 0, time = "18:00:00" },
        ]
      }
    }

    virtual_machine_scale_set_fabric = {
      sku_name  = "Standard_D2ads_v5"
      subnet_id = azurerm_subnet.agents.id
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
        aliases               = ["ubuntu-24.04"]
      }]
      storage = [{
        disk_size_in_gb      = 20
        storage_account_type = "StandardSSD_LRS"
      }]
    }

    azure_devops_organization = {
      organization = [{
        url      = "https://dev.azure.com/myorg"
        projects = ["my-project"]
      }]
    }

    maximum_concurrency = 3
  }
}
```

## Requirements

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Goals

The module follows the design principles of the [CloudNation](https://github.com/CloudNationHQ) module ecosystem. See [GOALS.md](GOALS.md) for details.

## Testing

Validation via Terratest. See [TESTING.md](TESTING.md) for more information.

## Notes

- `dev_center_project_id` and the inline `dev_center_project` block are mutually exclusive — provide one or the other.
- The `dev_center_project.dev_center_id` field is only needed when attaching an existing dev center not managed by this module.
- Exactly one of `stateless_agent` or `stateful_agent` must be set.
- Manual resource predictions use per-day schedule blocks (`monday_schedule` through `sunday_schedule`), each containing a list of `{ count, time }` entries. Omit a day block to leave that day idle. Use `all_week_schedule` for a flat 24/7 standby count instead.
- Pool identity only supports `UserAssigned` type. Dev Center and Dev Center Project resources support `SystemAssigned` and `UserAssigned`.
- GitHub organization profiles are not supported by `azurerm_managed_devops_pool`. Only Azure DevOps organizations are supported.
- `os_disk_storage_account_type` accepts `Standard`, `Premium`, or `StandardSSD` (not the full `_LRS`-suffixed names used for data disks).

## Contributors

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.

## References

- [Azure Managed DevOps Pools overview](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview?view=azure-devops)
- [azurerm_managed_devops_pool resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_devops_pool)
- [AVM reference module](https://github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool)
