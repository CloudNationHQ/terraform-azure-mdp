data "azurerm_client_config" "current" {}

# dev center
resource "azurerm_dev_center" "this" {
  for_each = var.pool.dev_center != null ? { "default" = var.pool.dev_center } : {}

  name                              = each.value.name
  resource_group_name               = coalesce(try(each.value.resource_group_name, null), var.resource_group_name, var.pool.resource_group_name)
  location                          = coalesce(try(each.value.location, null), var.location, var.pool.location)
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
  for_each = var.pool.dev_center_project != null ? { "default" = var.pool.dev_center_project } : {}

  name                       = each.value.name
  resource_group_name        = coalesce(try(each.value.resource_group_name, null), var.resource_group_name, var.pool.resource_group_name)
  location                   = coalesce(try(each.value.location, null), var.location, var.pool.location)
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
resource "azapi_resource" "this" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-09-20"
  name      = var.pool.name
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${coalesce(var.pool.resource_group_name, var.resource_group_name)}"
  location  = coalesce(var.pool.location, var.location)
  tags      = coalesce(var.pool.tags, var.tags)

  schema_validation_enabled = false
  ignore_null_property      = true
  response_export_values    = ["*"]

  dynamic "identity" {
    for_each = try(var.pool.identity, null) != null ? [var.pool.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, [])
    }
  }

  body = {
    properties = {
      devCenterProjectResourceId = coalesce(
        var.pool.dev_center_project_resource_id,
        try(azurerm_dev_center_project.this["default"].id, null)
      )
      maximumConcurrency = var.pool.maximum_concurrency

      agentProfile = {
        for k, v in {
          kind                = var.pool.agent_profile.kind
          maxAgentLifetime    = var.pool.agent_profile.max_agent_lifetime
          gracePeriodTimeSpan = var.pool.agent_profile.grace_period_time_span
          resourcePredictionsProfile = var.pool.agent_profile.resource_prediction_profile != null ? {
            for k, v in {
              kind                 = var.pool.agent_profile.resource_prediction_profile
              predictionPreference = var.pool.agent_profile.prediction_preference
            } : k => v if v != null
          } : null
          resourcePredictions = var.pool.agent_profile.resource_predictions_manual != null ? {
            timeZone = var.pool.agent_profile.resource_predictions_manual.time_zone
            daysData = var.pool.agent_profile.resource_predictions_manual.days_data
          } : null
        } : k => v if v != null
      }

      fabricProfile = {
        kind = "Vmss"
        sku  = { name = var.pool.fabric_profile.sku_name }
        images = [for img in var.pool.fabric_profile.images : {
          wellKnownImageName = img.well_known_image_name
          resourceId         = img.resource_id
          aliases            = img.aliases
          buffer             = img.buffer
          ephemeralType      = img.ephemeral_type
        }]
        storageProfile = {
          osDiskStorageAccountType = var.pool.fabric_profile.os_disk_storage_account_type
          dataDisks = [for disk in var.pool.fabric_profile.data_disks : {
            caching            = disk.caching
            diskSizeGiB        = disk.disk_size_gigabytes
            driveLetter        = disk.drive_letter
            storageAccountType = disk.storage_account_type
          }]
        }
        networkProfile = var.pool.fabric_profile.subnet_id != null ? {
          subnetId             = var.pool.fabric_profile.subnet_id
          staticIpAddressCount = var.pool.fabric_profile.static_ip_address_count
        } : null
        osProfile = var.pool.fabric_profile.logon_type != null || var.pool.fabric_profile.secrets_management != null ? {
          logonType = var.pool.fabric_profile.logon_type
          secretsManagementSettings = var.pool.fabric_profile.secrets_management != null ? {
            keyExportable            = var.pool.fabric_profile.secrets_management.key_exportable
            observedCertificates     = var.pool.fabric_profile.secrets_management.observed_certificates
            certificateStoreLocation = var.pool.fabric_profile.secrets_management.certificate_store_location
            certificateStoreName     = var.pool.fabric_profile.secrets_management.certificate_store_name
          } : null
        } : null
      }

      organizationProfile = jsondecode(
        var.pool.organization_profile.kind == "GitHub" ? jsonencode({
          kind = "GitHub"
          organizations = [for org in var.pool.organization_profile.github_organizations : {
            url          = org.url
            repositories = org.repositories
          }]
          }) : jsonencode({
          kind  = "AzureDevOps"
          alias = var.pool.organization_profile.alias
          organizations = [for org in var.pool.organization_profile.organizations : {
            url         = org.url
            alias       = org.alias
            projects    = org.projects
            parallelism = org.parallelism
            openAccess  = org.open_access
          }]
          permissionProfile = var.pool.organization_profile.permission_profile != null ? {
            kind   = var.pool.organization_profile.permission_profile.kind
            groups = var.pool.organization_profile.permission_profile.groups
            users  = var.pool.organization_profile.permission_profile.users
          } : null
        })
      )

      runtimeConfiguration = var.pool.runtime_configuration != null ? {
        workFolder = var.pool.runtime_configuration.work_folder
      } : null
    }
  }
}

# role assignment
resource "azurerm_role_assignment" "this" {
  for_each = var.pool.role_assignment != null ? { "default" = var.pool.role_assignment } : {}

  principal_id = coalesce(
    each.value.principal_id, data.azurerm_client_config.current.object_id
  )

  scope                                  = coalesce(each.value.scope, azapi_resource.this.id)
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
