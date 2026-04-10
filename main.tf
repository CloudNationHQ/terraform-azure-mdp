data "azurerm_client_config" "current" {}

# dev center
resource "azurerm_dev_center" "this" {
  for_each = var.config.dev_center != null ? { "default" = var.config.dev_center } : {}

  name                              = each.value.name
  resource_group_name               = coalesce(try(each.value.resource_group_name, null), var.resource_group_name, var.config.resource_group_name)
  location                          = coalesce(try(each.value.location, null), var.location, var.config.location)
  tags                              = coalesce(try(each.value.tags, null), var.tags)
  project_catalog_item_sync_enabled = each.value.project_catalog_item_sync_enabled

  dynamic "identity" {
    for_each = try(each.value.identity, null) != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, [])
    }
  }
}

# dev center project
resource "azurerm_dev_center_project" "this" {
  for_each = var.config.dev_center_project != null ? { "default" = var.config.dev_center_project } : {}

  name                       = each.value.name
  resource_group_name        = coalesce(try(each.value.resource_group_name, null), var.resource_group_name, var.config.resource_group_name)
  location                   = coalesce(try(each.value.location, null), var.location, var.config.location)
  description                = each.value.description
  tags                       = coalesce(try(each.value.tags, null), var.tags)
  maximum_dev_boxes_per_user = each.value.maximum_dev_boxes_per_user

  dev_center_id = coalesce(
    try(each.value.dev_center_id, null),
    try(azurerm_dev_center.this["default"].id, null)
  )

  dynamic "identity" {
    for_each = try(each.value.identity, null) != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, [])
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
    for_each = var.config.identity != null ? { this = {} } : {}
    content {
      type         = var.config.identity.type
      identity_ids = var.config.identity.identity_ids
    }
  }

  dynamic "stateless_agent" {
    for_each = var.config.stateless_agent != null ? { this = {} } : {}
    content {
      dynamic "automatic_resource_prediction" {
        for_each = var.config.stateless_agent.automatic_resource_prediction != null ? { this = {} } : {}
        content {
          prediction_preference = var.config.stateless_agent.automatic_resource_prediction.prediction_preference
        }
      }
      dynamic "manual_resource_prediction" {
        for_each = var.config.stateless_agent.manual_resource_prediction != null ? { this = {} } : {}
        content {
          time_zone_name    = var.config.stateless_agent.manual_resource_prediction.time_zone_name
          all_week_schedule = var.config.stateless_agent.manual_resource_prediction.all_week_schedule
          dynamic "monday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.monday_schedule
            content {
              count = monday_schedule.value.count
              time  = monday_schedule.value.time
            }
          }
          dynamic "tuesday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.tuesday_schedule
            content {
              count = tuesday_schedule.value.count
              time  = tuesday_schedule.value.time
            }
          }
          dynamic "wednesday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.wednesday_schedule
            content {
              count = wednesday_schedule.value.count
              time  = wednesday_schedule.value.time
            }
          }
          dynamic "thursday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.thursday_schedule
            content {
              count = thursday_schedule.value.count
              time  = thursday_schedule.value.time
            }
          }
          dynamic "friday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.friday_schedule
            content {
              count = friday_schedule.value.count
              time  = friday_schedule.value.time
            }
          }
          dynamic "saturday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.saturday_schedule
            content {
              count = saturday_schedule.value.count
              time  = saturday_schedule.value.time
            }
          }
          dynamic "sunday_schedule" {
            for_each = var.config.stateless_agent.manual_resource_prediction.sunday_schedule
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
    for_each = var.config.stateful_agent != null ? { this = {} } : {}
    content {
      grace_period_time_span = var.config.stateful_agent.grace_period_time_span
      maximum_agent_lifetime = var.config.stateful_agent.maximum_agent_lifetime
      dynamic "automatic_resource_prediction" {
        for_each = var.config.stateful_agent.automatic_resource_prediction != null ? { this = {} } : {}
        content {
          prediction_preference = var.config.stateful_agent.automatic_resource_prediction.prediction_preference
        }
      }
      dynamic "manual_resource_prediction" {
        for_each = var.config.stateful_agent.manual_resource_prediction != null ? { this = {} } : {}
        content {
          time_zone_name    = var.config.stateful_agent.manual_resource_prediction.time_zone_name
          all_week_schedule = var.config.stateful_agent.manual_resource_prediction.all_week_schedule
          dynamic "monday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.monday_schedule
            content {
              count = monday_schedule.value.count
              time  = monday_schedule.value.time
            }
          }
          dynamic "tuesday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.tuesday_schedule
            content {
              count = tuesday_schedule.value.count
              time  = tuesday_schedule.value.time
            }
          }
          dynamic "wednesday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.wednesday_schedule
            content {
              count = wednesday_schedule.value.count
              time  = wednesday_schedule.value.time
            }
          }
          dynamic "thursday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.thursday_schedule
            content {
              count = thursday_schedule.value.count
              time  = thursday_schedule.value.time
            }
          }
          dynamic "friday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.friday_schedule
            content {
              count = friday_schedule.value.count
              time  = friday_schedule.value.time
            }
          }
          dynamic "saturday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.saturday_schedule
            content {
              count = saturday_schedule.value.count
              time  = saturday_schedule.value.time
            }
          }
          dynamic "sunday_schedule" {
            for_each = var.config.stateful_agent.manual_resource_prediction.sunday_schedule
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
      for_each = var.config.virtual_machine_scale_set_fabric.security != null ? { this = {} } : {}
      content {
        interactive_logon_enabled = var.config.virtual_machine_scale_set_fabric.security.interactive_logon_enabled
        dynamic "key_vault_management" {
          for_each = var.config.virtual_machine_scale_set_fabric.security.key_vault_management != null ? { this = {} } : {}
          content {
            key_vault_certificate_ids  = var.config.virtual_machine_scale_set_fabric.security.key_vault_management.key_vault_certificate_ids
            certificate_store_location = var.config.virtual_machine_scale_set_fabric.security.key_vault_management.certificate_store_location
            certificate_store_name     = var.config.virtual_machine_scale_set_fabric.security.key_vault_management.certificate_store_name
            key_export_enabled         = var.config.virtual_machine_scale_set_fabric.security.key_vault_management.key_export_enabled
          }
        }
      }
    }
  }

  azure_devops_organization {
    dynamic "organization" {
      for_each = var.config.azure_devops_organization.organization
      content {
        url         = organization.value.url
        parallelism = organization.value.parallelism
        projects    = organization.value.projects
      }
    }

    dynamic "permission" {
      for_each = var.config.azure_devops_organization.permission != null ? { this = {} } : {}
      content {
        kind = var.config.azure_devops_organization.permission.kind
        dynamic "administrator_account" {
          for_each = var.config.azure_devops_organization.permission.administrator_account != null ? { this = {} } : {}
          content {
            groups = var.config.azure_devops_organization.permission.administrator_account.groups
            users  = var.config.azure_devops_organization.permission.administrator_account.users
          }
        }
      }
    }
  }
}

# role assignment
resource "azurerm_role_assignment" "this" {
  for_each = var.config.role_assignment != null ? { "default" = var.config.role_assignment } : {}

  principal_id = coalesce(
    each.value.principal_id, data.azurerm_client_config.current.object_id
  )

  scope                                  = coalesce(each.value.scope, azurerm_managed_devops_pool.this.id)
  role_definition_name                   = each.value.role_definition_name
  role_definition_id                     = each.value.role_definition_id
  principal_type                         = each.value.principal_type
  name                                   = each.value.name
  description                            = each.value.description
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
