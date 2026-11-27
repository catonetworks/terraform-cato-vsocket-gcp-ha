# Retain the mode in state after creation so a later plan cannot change it.
resource "terraform_data" "deployment_mode" {
  input = var.ha

  lifecycle {
    ignore_changes = [input]

    postcondition {
      condition     = self.input == var.ha
      error_message = "Changing ha on an existing deployment is unsupported. Create a separate deployment in the desired mode."
    }
  }
}

# An MVP deployment has no deployment_mode marker yet. Check the same-name
# site before the first plan can add a marker or change the site's socket mode.
data "cato_sites" "deployment" {
  name_filter = [var.site_name]
}

locals {
  matching_sites = [for site in coalesce(data.cato_sites.deployment.items, []) : site if site.name == var.site_name]
}

data "cato_accountSnapshotSite" "deployment" {
  count = length(local.matching_sites) == 1 ? 1 : 0
  id    = local.matching_sites[0].id
}

locals {
  existing_sockets = length(data.cato_accountSnapshotSite.deployment) == 1 ? coalesce(data.cato_accountSnapshotSite.deployment[0].info.sockets, []) : []
}

resource "terraform_data" "validate_existing_site" {
  lifecycle {
    precondition {
      condition     = length(local.matching_sites) <= 1
      error_message = "Multiple Cato sites match site_name. Use a unique name before planning this deployment."
    }

    precondition {
      condition = length(local.matching_sites) == 1 ? (
        length([for socket in local.existing_sockets : socket if socket.is_primary == true && try(length(socket.serial) > 0, false)]) == 1 &&
        length(local.existing_sockets) == (var.ha ? 2 : 1) &&
        length([for socket in local.existing_sockets : socket if socket.is_primary == false && try(length(socket.serial) > 0, false)]) == (var.ha ? 1 : 0)
      ) : (!var.ha || var.assign_secondary_on_create)
      error_message = "An existing site must already match the requested ha mode. Create a separate site to change modes. assign_secondary_on_create=false requires an existing HA site."
    }
  }
}
