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
resource "azapi_resource" "this" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-09-20"
  name      = var.config.name
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${coalesce(var.config.resource_group_name, var.resource_group_name)}"
  location  = coalesce(var.config.location, var.location)
  tags      = coalesce(var.config.tags, var.tags)

  schema_validation_enabled = false
  ignore_null_property      = true
  response_export_values    = ["*"]

  dynamic "identity" {
    for_each = try(var.config.identity, null) != null ? [var.config.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, [])
    }
  }

  body = {
    properties = {
      devCenterProjectResourceId = coalesce(
        var.config.dev_center_project_resource_id,
        try(azurerm_dev_center_project.this["default"].id, null)
      )
      maximumConcurrency = var.config.maximum_concurrency

      agentProfile = {
        for k, v in {
          kind                = var.config.agent_profile.kind
          maxAgentLifetime    = var.config.agent_profile.max_agent_lifetime
          gracePeriodTimeSpan = var.config.agent_profile.grace_period_time_span
          resourcePredictionsProfile = var.config.agent_profile.resource_prediction_profile != null ? {
            for k, v in {
              kind                 = var.config.agent_profile.resource_prediction_profile
              predictionPreference = var.config.agent_profile.prediction_preference
            } : k => v if v != null
          } : null
          resourcePredictions = var.config.agent_profile.resource_predictions_manual != null ? {
            timeZone = var.config.agent_profile.resource_predictions_manual.time_zone
            daysData = var.config.agent_profile.resource_predictions_manual.days_data
          } : null
        } : k => v if v != null
      }

      fabricProfile = {
        kind = "Vmss"
        sku  = { name = var.config.fabric_profile.sku_name }
        images = [for img in var.config.fabric_profile.images : {
          wellKnownImageName = img.well_known_image_name
          resourceId         = img.resource_id
          aliases            = img.aliases
          buffer             = img.buffer
          ephemeralType      = img.ephemeral_type
        }]
        storageProfile = {
          osDiskStorageAccountType = var.config.fabric_profile.os_disk_storage_account_type
          dataDisks = [for disk in var.config.fabric_profile.data_disks : {
            caching            = disk.caching
            diskSizeGiB        = disk.disk_size_gigabytes
            driveLetter        = disk.drive_letter
            storageAccountType = disk.storage_account_type
          }]
        }
        networkProfile = var.config.fabric_profile.subnet_id != null ? {
          subnetId             = var.config.fabric_profile.subnet_id
          staticIpAddressCount = var.config.fabric_profile.static_ip_address_count
        } : null
        osProfile = var.config.fabric_profile.logon_type != null || var.config.fabric_profile.secrets_management != null ? {
          logonType = var.config.fabric_profile.logon_type
          secretsManagementSettings = var.config.fabric_profile.secrets_management != null ? {
            keyExportable            = var.config.fabric_profile.secrets_management.key_exportable
            observedCertificates     = var.config.fabric_profile.secrets_management.observed_certificates
            certificateStoreLocation = var.config.fabric_profile.secrets_management.certificate_store_location
            certificateStoreName     = var.config.fabric_profile.secrets_management.certificate_store_name
          } : null
        } : null
      }

      organizationProfile = jsondecode(
        var.config.organization_profile.kind == "GitHub" ? jsonencode({
          kind = "GitHub"
          organizations = [for org in var.config.organization_profile.github_organizations : {
            url          = org.url
            repositories = org.repositories
          }]
          }) : jsonencode({
          kind  = "AzureDevOps"
          alias = var.config.organization_profile.alias
          organizations = [for org in var.config.organization_profile.organizations : {
            url         = org.url
            alias       = org.alias
            projects    = org.projects
            parallelism = org.parallelism
            openAccess  = org.open_access
          }]
          permissionProfile = var.config.organization_profile.permission_profile != null ? {
            kind   = var.config.organization_profile.permission_profile.kind
            groups = var.config.organization_profile.permission_profile.groups
            users  = var.config.organization_profile.permission_profile.users
          } : null
        })
      )

      runtimeConfiguration = var.config.runtime_configuration != null ? {
        workFolder = var.config.runtime_configuration.work_folder
      } : null
    }
  }
}

# role assignment
resource "azurerm_role_assignment" "this" {
  for_each = var.config.role_assignment != null ? { "default" = var.config.role_assignment } : {}

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
