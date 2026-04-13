# Managed DevOps Pool

This terraform module simplifies the creation and management of managed devops pool resources on Azure, providing customizable options for agent profiles, resource prediction, and organization connectivity, all managed through code.

## Features

Deploys Azure Managed DevOps Pools via the AzureRM provider

Optionally creates a Dev Center and Dev Center Project

Supports both Stateless and Stateful agent profiles

Supports Manual and Automatic resource prediction (stand-by agents)

Supports VMSS fabric with custom VM images and data disks

Supports networking integration via subnet configuration

Supports Azure DevOps organization profiles

Supports User-assigned managed identity

Utilization of terratest for robust validation

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

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

`dev_center_project_id` and the inline `dev_center_project` block are mutually exclusive — provide one or the other.

The `dev_center_project.dev_center_id` field is only needed when attaching an existing dev center not managed by this module.

Exactly one of `stateless_agent` or `stateful_agent` must be set.

Manual resource predictions use per-day schedule blocks (`monday_schedule` through `sunday_schedule`), each containing a list of `{ count, time }` entries. Omit a day block to leave that day idle. Use `all_week_schedule` for a flat 24/7 standby count instead.

Pool identity only supports `UserAssigned` type. Dev Center and Dev Center Project resources support `SystemAssigned` and `UserAssigned`.

GitHub organization profiles are not supported by `azurerm_managed_devops_pool`. Only Azure DevOps organizations are supported.

`os_disk_storage_account_type` accepts `Standard`, `Premium`, or `StandardSSD` (not the full `_LRS`-suffixed names used for data disks).

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-mdp/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-mdp" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview?view=azure-devops)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/azure/devops)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/devopsinfrastructure)
