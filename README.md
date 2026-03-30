# Managed DevOps Pool

Terraform module which creates Managed DevOps Pool resources on Azure.

## Features

- Deploys Azure Managed DevOps Pools via the AzAPI provider
- Optionally creates a Dev Center and Dev Center Project
- Supports both Stateless and Stateful agent profiles
- Supports Manual and Automatic resource prediction (stand-by agents)
- Supports VMSS fabric profile with custom VM images and data disks
- Supports networking integration via subnet configuration
- Supports Azure DevOps and GitHub organization profiles
- Supports managed identity (System-assigned and User-assigned)
- Supports RBAC role assignments on the pool

## Usage

```hcl
module "mdp" {
  source  = "cloudnationhq/mdp/azure"
  version = "~> 1.0"

  pool = {
    name                = "pool-demo-dev"
    location            = "westeurope"
    resource_group_name = "rg-demo-dev"

    dev_center = {
      name = "dc-demo-dev"
    }

    dev_center_project = {
      name = "dcp-demo-dev"
    }

    agent_profile = {
      kind = "Stateless"
    }

    fabric_profile = {
      sku_name = "Standard_D2ads_v5"
      images = [{
        well_known_image_name = "ubuntu-24.04/latest"
      }]
    }

    organization_profile = {
      organizations = [{
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

  pool = {
    name                = "pool-demo-dev"
    location            = "westeurope"
    resource_group_name = "rg-demo-dev"

    dev_center_project_resource_id = azurerm_dev_center_project.existing.id

    agent_profile = {
      kind                        = "Stateful"
      max_agent_lifetime          = "7:00:00:00"
      grace_period_time_span      = "1:00:00"
      resource_prediction_profile = "Manual"

      resource_predictions_manual = {
        time_zone = "UTC"
        days_data = [
          {},
          { "07:00:00" = 3, "18:00:00" = 0 },
          { "07:00:00" = 3, "18:00:00" = 0 },
          { "07:00:00" = 3, "18:00:00" = 0 },
          { "07:00:00" = 3, "18:00:00" = 0 },
          { "07:00:00" = 3, "18:00:00" = 0 },
          {},
        ]
      }
    }

    fabric_profile = {
      sku_name = "Standard_D2_v5"
      images = [{
        well_known_image_name = "ubuntu-24.04/latest"
        aliases               = ["ubuntu-24.04"]
      }]
      data_disks = [{
        disk_size_gigabytes  = 20
        storage_account_type = "StandardSSD_LRS"
      }]
      subnet_id = azurerm_subnet.agents.id
    }

    organization_profile = {
      organizations = [{
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

- The `Microsoft.DevOpsInfrastructure/pools` resource requires the AzAPI provider as no native AzureRM resource exists yet.
- `dev_center_project_resource_id` and the inline `dev_center_project` block are mutually exclusive — provide one or the other.
- The `dev_center_project.dev_center_id` field is only needed when attaching an existing dev center not managed by this module.
- Manual resource predictions (`days_data`) is a list of 7 maps (Sunday through Saturday). Use an empty map `{}` for off days.

## Contributors

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.

## References

- [Azure Managed DevOps Pools overview](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview?view=azure-devops)
- [Microsoft.DevOpsInfrastructure/pools API reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.devopsinfrastructure/pools?pivots=deployment-language-terraform)
- [AVM reference module](https://github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool)
