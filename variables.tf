variable "config" {
  description = "contains managed devops pool configuration"
  type = object({
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
        type         = string
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
        type         = string
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
        monday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        tuesday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        wednesday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        thursday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        friday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        saturday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        sunday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
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
        monday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        tuesday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        wednesday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        thursday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        friday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        saturday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
        sunday_schedule = optional(map(object({
          count = number
          time  = string
        })), {})
      }))
    }))

    virtual_machine_scale_set_fabric = object({
      sku_name                     = optional(string, "Standard_D2ads_v5")
      os_disk_storage_account_type = optional(string, "Standard")
      subnet_id                    = optional(string)

      image = map(object({
        well_known_image_name = optional(string)
        id                    = optional(string)
        aliases               = optional(list(string))
        buffer                = optional(string, "*")
      }))

      storage = optional(map(object({
        disk_size_in_gb      = number
        caching              = optional(string)
        drive_letter         = optional(string)
        storage_account_type = optional(string, "Standard_LRS")
      })), {})

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
      organization = map(object({
        url         = optional(string)
        parallelism = number
        projects    = optional(list(string))
      }))
      permission = optional(object({
        kind = string
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

  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.dev_center_project_id != null || var.config.dev_center_project != null
    error_message = "either dev_center_project_id or dev_center_project must be provided."
  }

  validation {
    condition     = var.config.identity == null || var.config.identity.type == "UserAssigned"
    error_message = "managed devops pool identity only supports type 'UserAssigned'."
  }

  validation {
    condition     = (var.config.stateless_agent != null) != (var.config.stateful_agent != null)
    error_message = "exactly one of stateless_agent or stateful_agent must be set."
  }

  validation {
    condition = alltrue([
      for org in values(var.config.azure_devops_organization.organization) :
      org.url != null || var.ado_organization_url != null
    ])
    error_message = "each organization must have a url, or ado_organization_url must be provided."
  }
}

variable "ado_organization_url" {
  description = "URL of the Azure DevOps organization to link the pool to, e.g. https://dev.azure.com/<your-org>"
  type        = string
  default     = null
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
