variable "pool" {
  description = "contains managed devops pool configuration"
  type = object({
    name                           = string
    location                       = optional(string)
    resource_group_name            = optional(string)
    tags                           = optional(map(string))
    maximum_concurrency            = optional(number, 1)
    dev_center_project_resource_id = optional(string)

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

    agent_profile = object({
      kind                        = optional(string, "Stateless")
      max_agent_lifetime          = optional(string)
      grace_period_time_span      = optional(string)
      resource_prediction_profile = optional(string)
      prediction_preference       = optional(string)
      resource_predictions_manual = optional(object({
        time_zone = optional(string, "UTC")
        days_data = optional(list(map(number)), [{}, {}, {}, {}, {}, {}, {}])
      }))
    })

    fabric_profile = object({
      sku_name                     = optional(string, "Standard_D2ads_v5")
      os_disk_storage_account_type = optional(string)
      logon_type                   = optional(string)
      subnet_id                    = optional(string)
      static_ip_address_count      = optional(number)

      images = list(object({
        well_known_image_name = optional(string)
        resource_id           = optional(string)
        aliases               = optional(list(string))
        buffer                = optional(string)
        ephemeral_type        = optional(string)
      }))

      data_disks = optional(list(object({
        caching              = optional(string)
        disk_size_gigabytes  = optional(number)
        drive_letter         = optional(string)
        storage_account_type = optional(string)
      })), [])

      secrets_management = optional(object({
        key_exportable             = bool
        observed_certificates      = list(string)
        certificate_store_location = optional(string)
        certificate_store_name     = optional(string)
      }))
    })

    organization_profile = object({
      kind  = optional(string, "AzureDevOps")
      alias = optional(string)

      organizations = optional(list(object({
        url         = string
        alias       = optional(string)
        projects    = optional(list(string))
        parallelism = optional(number)
        open_access = optional(bool)
      })), [])

      permission_profile = optional(object({
        kind   = optional(string, "CreatorOnly")
        groups = optional(list(string))
        users  = optional(list(string))
      }))

      github_organizations = optional(list(object({
        url          = string
        repositories = optional(list(string))
      })), [])
    })

    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }))

    role_assignment = optional(object({
      role_definition_name                   = optional(string)
      role_definition_id                     = optional(string)
      scope                                  = optional(string)
      principal_id                           = optional(string)
      principal_type                         = optional(string)
      name                                   = optional(string)
      description                            = optional(string)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      skip_service_principal_aad_check       = optional(bool)
    }))

    runtime_configuration = optional(object({
      work_folder = optional(string)
    }))
  })
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
