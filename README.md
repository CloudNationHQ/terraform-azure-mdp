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
      image = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
    }

    azure_devops_organization = {
      organization = [{
        url = "https://dev.azure.com/myorg"
      }]
    }
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
      grace_period_time_span = "1:00:00"
      manual_resource_prediction = {
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
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (4.68.0)

## Resources

The following resources are used by this module:

- [azurerm_dev_center.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center) (resource)
- [azurerm_dev_center_project.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center_project) (resource)
- [azurerm_managed_devops_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_devops_pool) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: contains managed devops pool configuration

Type:

```hcl
object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
    maximum_concurrency = optional(number, 1)
    work_folder         = optional(string)

    dev_center_project_id = optional(string)

    dev_center = optional(object({
      name                              = string
      location                          = optional(string)
      resource_group_name               = optional(string)
      tags                              = optional(map(string))
      project_catalog_item_sync_enabled = optional(bool, false)
      identity = optional(object({
        type         = optional(string, "SystemAssigned")
        identity_ids = optional(list(string), [])
      }))
    }))

    dev_center_project = optional(object({
      name                       = string
      location                   = optional(string)
      resource_group_name        = optional(string)
      description                = optional(string)
      dev_center_id              = optional(string)
      tags                       = optional(map(string))
      maximum_dev_boxes_per_user = optional(number)
      identity = optional(object({
        type         = optional(string, "SystemAssigned")
        identity_ids = optional(list(string), [])
      }))
    }))

    stateless_agent = optional(object({
      automatic_resource_prediction = optional(object({
        prediction_preference = optional(string, "Balanced")
      }))
      manual_resource_prediction = optional(object({
        time_zone_name    = optional(string, "UTC")
        all_week_schedule = optional(number)
        monday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        tuesday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        wednesday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        thursday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        friday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        saturday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        sunday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
      }))
    }))

    stateful_agent = optional(object({
      grace_period_time_span = optional(string, "00:00:00")
      maximum_agent_lifetime = optional(string, "7.00:00:00")
      automatic_resource_prediction = optional(object({
        prediction_preference = optional(string, "Balanced")
      }))
      manual_resource_prediction = optional(object({
        time_zone_name    = optional(string, "UTC")
        all_week_schedule = optional(number)
        monday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        tuesday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        wednesday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        thursday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        friday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        saturday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
        sunday_schedule = optional(list(object({
          count = number
          time  = string
        })), [])
      }))
    }))

    virtual_machine_scale_set_fabric = object({
      sku_name                     = optional(string, "Standard_D2ads_v5")
      os_disk_storage_account_type = optional(string, "Standard")
      subnet_id                    = optional(string)

      image = list(object({
        well_known_image_name = optional(string)
        id                    = optional(string)
        aliases               = optional(list(string))
        buffer                = optional(string, "*")
      }))

      storage = optional(list(object({
        disk_size_in_gb      = number
        caching              = optional(string)
        drive_letter         = optional(string)
        storage_account_type = optional(string, "Standard_LRS")
      })), [])

      security = optional(object({
        interactive_logon_enabled = optional(bool, false)
        key_vault_management = optional(object({
          key_vault_certificate_ids  = list(string)
          certificate_store_location = optional(string)
          certificate_store_name     = optional(string)
          key_export_enabled         = optional(bool, false)
        }))
      }))
    })

    azure_devops_organization = object({
      organization = list(object({
        url         = string
        parallelism = optional(number, 1)
        projects    = optional(list(string))
      }))
      permission = optional(object({
        kind = optional(string, "Inherit")
        administrator_account = optional(object({
          groups = optional(list(string))
          users  = optional(list(string))
        }))
      }))
    })

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_dev_center"></a> [dev\_center](#output\_dev\_center)

Description: contains dev center configuration

### <a name="output_dev_center_project"></a> [dev\_center\_project](#output\_dev\_center\_project)

Description: contains dev center project configuration

### <a name="output_pool"></a> [pool](#output\_pool)

Description: contains managed devops pool configuration
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
