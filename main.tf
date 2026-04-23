# dev center
resource "azurerm_dev_center" "this" {
  for_each = var.config.dev_center != null ? { "default" = var.config.dev_center } : {}

  name                              = each.value.name
  resource_group_name               = coalesce(each.value.resource_group_name, var.resource_group_name, var.config.resource_group_name)
  location                          = coalesce(each.value.location, var.location, var.config.location)
  tags                              = coalesce(each.value.tags, var.tags)
  project_catalog_item_sync_enabled = each.value.project_catalog_item_sync_enabled

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# dev center project
resource "azurerm_dev_center_project" "this" {
  for_each = var.config.dev_center_project != null ? { "default" = var.config.dev_center_project } : {}

  name                       = each.value.name
  resource_group_name        = coalesce(each.value.resource_group_name, var.resource_group_name, var.config.resource_group_name)
  location                   = coalesce(each.value.location, var.location, var.config.location)
  description                = each.value.description
  tags                       = coalesce(each.value.tags, var.tags)
  maximum_dev_boxes_per_user = each.value.maximum_dev_boxes_per_user

  dev_center_id = coalesce(
    each.value.dev_center_id,
    try(azurerm_dev_center.this["default"].id, null)
  )

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# managed devops pool
resource "azurerm_managed_devops_pool" "this" {
  name                = var.config.name
  resource_group_name = coalesce(var.config.resource_group_name, var.resource_group_name)
  location            = coalesce(var.config.location, var.location)
  tags                = coalesce(var.config.tags, var.tags)

  dev_center_project_id = coalesce(
    var.config.dev_center_project_id,
    try(azurerm_dev_center_project.this["default"].id, null)
  )

  maximum_concurrency = var.config.maximum_concurrency
  work_folder         = var.config.work_folder

  dynamic "identity" {
    for_each = var.config.identity != null ? [var.config.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "stateless_agent" {
    for_each = var.config.stateless_agent != null ? [var.config.stateless_agent] : []
    content {
      dynamic "automatic_resource_prediction" {
        for_each = stateless_agent.value.automatic_resource_prediction != null ? [stateless_agent.value.automatic_resource_prediction] : []
        content {
          prediction_preference = automatic_resource_prediction.value.prediction_preference
        }
      }
      dynamic "manual_resource_prediction" {
        for_each = stateless_agent.value.manual_resource_prediction != null ? [stateless_agent.value.manual_resource_prediction] : []
        content {
          time_zone_name    = manual_resource_prediction.value.time_zone_name
          all_week_schedule = manual_resource_prediction.value.all_week_schedule
          dynamic "monday_schedule" {
            for_each = manual_resource_prediction.value.monday_schedule
            content {
              count = monday_schedule.value.count
              time  = monday_schedule.value.time
            }
          }
          dynamic "tuesday_schedule" {
            for_each = manual_resource_prediction.value.tuesday_schedule
            content {
              count = tuesday_schedule.value.count
              time  = tuesday_schedule.value.time
            }
          }
          dynamic "wednesday_schedule" {
            for_each = manual_resource_prediction.value.wednesday_schedule
            content {
              count = wednesday_schedule.value.count
              time  = wednesday_schedule.value.time
            }
          }
          dynamic "thursday_schedule" {
            for_each = manual_resource_prediction.value.thursday_schedule
            content {
              count = thursday_schedule.value.count
              time  = thursday_schedule.value.time
            }
          }
          dynamic "friday_schedule" {
            for_each = manual_resource_prediction.value.friday_schedule
            content {
              count = friday_schedule.value.count
              time  = friday_schedule.value.time
            }
          }
          dynamic "saturday_schedule" {
            for_each = manual_resource_prediction.value.saturday_schedule
            content {
              count = saturday_schedule.value.count
              time  = saturday_schedule.value.time
            }
          }
          dynamic "sunday_schedule" {
            for_each = manual_resource_prediction.value.sunday_schedule
            content {
              count = sunday_schedule.value.count
              time  = sunday_schedule.value.time
            }
          }
        }
      }
    }
  }

  dynamic "stateful_agent" {
    for_each = var.config.stateful_agent != null ? [var.config.stateful_agent] : []
    content {
      grace_period_time_span = stateful_agent.value.grace_period_time_span
      maximum_agent_lifetime = stateful_agent.value.maximum_agent_lifetime
      dynamic "automatic_resource_prediction" {
        for_each = stateful_agent.value.automatic_resource_prediction != null ? [stateful_agent.value.automatic_resource_prediction] : []
        content {
          prediction_preference = automatic_resource_prediction.value.prediction_preference
        }
      }
      dynamic "manual_resource_prediction" {
        for_each = stateful_agent.value.manual_resource_prediction != null ? [stateful_agent.value.manual_resource_prediction] : []
        content {
          time_zone_name    = manual_resource_prediction.value.time_zone_name
          all_week_schedule = manual_resource_prediction.value.all_week_schedule
          dynamic "monday_schedule" {
            for_each = manual_resource_prediction.value.monday_schedule
            content {
              count = monday_schedule.value.count
              time  = monday_schedule.value.time
            }
          }
          dynamic "tuesday_schedule" {
            for_each = manual_resource_prediction.value.tuesday_schedule
            content {
              count = tuesday_schedule.value.count
              time  = tuesday_schedule.value.time
            }
          }
          dynamic "wednesday_schedule" {
            for_each = manual_resource_prediction.value.wednesday_schedule
            content {
              count = wednesday_schedule.value.count
              time  = wednesday_schedule.value.time
            }
          }
          dynamic "thursday_schedule" {
            for_each = manual_resource_prediction.value.thursday_schedule
            content {
              count = thursday_schedule.value.count
              time  = thursday_schedule.value.time
            }
          }
          dynamic "friday_schedule" {
            for_each = manual_resource_prediction.value.friday_schedule
            content {
              count = friday_schedule.value.count
              time  = friday_schedule.value.time
            }
          }
          dynamic "saturday_schedule" {
            for_each = manual_resource_prediction.value.saturday_schedule
            content {
              count = saturday_schedule.value.count
              time  = saturday_schedule.value.time
            }
          }
          dynamic "sunday_schedule" {
            for_each = manual_resource_prediction.value.sunday_schedule
            content {
              count = sunday_schedule.value.count
              time  = sunday_schedule.value.time
            }
          }
        }
      }
    }
  }

  virtual_machine_scale_set_fabric {
    sku_name                     = var.config.virtual_machine_scale_set_fabric.sku_name
    os_disk_storage_account_type = var.config.virtual_machine_scale_set_fabric.os_disk_storage_account_type
    subnet_id                    = var.config.virtual_machine_scale_set_fabric.subnet_id

    dynamic "image" {
      for_each = var.config.virtual_machine_scale_set_fabric.image
      content {
        well_known_image_name = image.value.well_known_image_name
        id                    = image.value.id
        aliases               = image.value.aliases
        buffer                = image.value.buffer
      }
    }

    dynamic "storage" {
      for_each = var.config.virtual_machine_scale_set_fabric.storage
      content {
        disk_size_in_gb      = storage.value.disk_size_in_gb
        caching              = storage.value.caching
        drive_letter         = storage.value.drive_letter
        storage_account_type = storage.value.storage_account_type
      }
    }

    dynamic "security" {
      for_each = var.config.virtual_machine_scale_set_fabric.security != null ? [var.config.virtual_machine_scale_set_fabric.security] : []
      content {
        interactive_logon_enabled = security.value.interactive_logon_enabled
        dynamic "key_vault_management" {
          for_each = security.value.key_vault_management != null ? [security.value.key_vault_management] : []
          content {
            key_vault_certificate_ids  = key_vault_management.value.key_vault_certificate_ids
            certificate_store_location = key_vault_management.value.certificate_store_location
            certificate_store_name     = key_vault_management.value.certificate_store_name
            key_export_enabled         = key_vault_management.value.key_export_enabled
          }
        }
      }
    }
  }

  azure_devops_organization {
    dynamic "organization" {
      for_each = var.config.azure_devops_organization.organization
      content {
        url         = coalesce(organization.value.url, var.ado_organization_url)
        parallelism = organization.value.parallelism
        projects    = organization.value.projects
      }
    }

    dynamic "permission" {
      for_each = var.config.azure_devops_organization.permission != null ? [var.config.azure_devops_organization.permission] : []
      content {
        kind = permission.value.kind
        dynamic "administrator_account" {
          for_each = permission.value.administrator_account != null ? [permission.value.administrator_account] : []
          content {
            groups = administrator_account.value.groups
            users  = administrator_account.value.users
          }
        }
      }
    }
  }
}
