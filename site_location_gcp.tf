data "cato_siteLocation" "site_location" {
  count = local.all_location_fields_null ? 1 : 0
  filters = concat([
    {
      field     = "city"
      operation = "exact"
      search    = local.region_to_location[local.region_key].city
    },
    {
      field     = "country_name"
      operation = "exact"
      search    = local.region_to_location[local.region_key].country
    }
    ],
    local.region_to_location[local.region_key].state != null ? [
      {
        field     = "state_name"
        operation = "exact"
        search    = local.region_to_location[local.region_key].state
      }
  ] : [])
}

locals {
  ## Check for all site_location inputs to be null
  all_location_fields_null = (
    var.site_location.city == null &&
    var.site_location.country_code == null &&
    var.site_location.state_code == null &&
    var.site_location.timezone == null
  ) ? true : false

  ## If all site_location fields are null, use the data source to fetch the 
  ## site_location from GCP region, else use var.site_location
  cur_site_location = local.all_location_fields_null ? {
    country_code = data.cato_siteLocation.site_location[0].locations[0].country_code
    timezone     = data.cato_siteLocation.site_location[0].locations[0].timezone[0]
    state_code   = data.cato_siteLocation.site_location[0].locations[0].state_code
    city         = data.cato_siteLocation.site_location[0].locations[0].city
  } : var.site_location

  region_key = lower(replace(var.region, "-", ""))

  # Manual mapping of GCP regions to their cities, states, countries, and timezones
  # Based on official GCP region data and geographic locations
  region_to_location = {
    # Africa
    "africasouth1" = { city = "Johannesburg", state = null, country = "South Africa", continent = "Africa", timezone = "Africa/Johannesburg" }

    # Asia Pacific
    "asiaeast1"      = { city = "Changhua County", state = null, country = "Taiwan", continent = "Asia Pacific", timezone = "Asia/Taipei" }
    "asiaeast2"      = { city = "Hong Kong", state = null, country = "Hong Kong", continent = "Asia Pacific", timezone = "Asia/Hong_Kong" }
    "asianortheast1" = { city = "Tokyo", state = null, country = "Japan", continent = "Asia Pacific", timezone = "Asia/Tokyo" }
    "asianortheast2" = { city = "Osaka", state = null, country = "Japan", continent = "Asia Pacific", timezone = "Asia/Tokyo" }
    "asianortheast3" = { city = "Seoul", state = null, country = "South Korea", continent = "Asia Pacific", timezone = "Asia/Seoul" }
    "asiasouth1"     = { city = "Mumbai", state = "Maharashtra", country = "India", continent = "Asia Pacific", timezone = "Asia/Kolkata" }
    "asiasouth2"     = { city = "Delhi", state = "Delhi", country = "India", continent = "Asia Pacific", timezone = "Asia/Kolkata" }
    "asiasoutheast1" = { city = "Jurong West", state = null, country = "Singapore", continent = "Asia Pacific", timezone = "Asia/Singapore" }
    "asiasoutheast2" = { city = "Jakarta", state = null, country = "Indonesia", continent = "Asia Pacific", timezone = "Asia/Jakarta" }

    # Australia
    "australiasoutheast1" = { city = "Sydney", state = "New South Wales", country = "Australia", continent = "Asia Pacific", timezone = "Australia/Sydney" }
    "australiasoutheast2" = { city = "Melbourne", state = "Victoria", country = "Australia", continent = "Asia Pacific", timezone = "Australia/Melbourne" }

    # Europe
    "europecentral2"   = { city = "Warsaw", state = null, country = "Poland", continent = "Europe", timezone = "Europe/Warsaw" }
    "europenorth1"     = { city = "Hamina", state = null, country = "Finland", continent = "Europe", timezone = "Europe/Helsinki" }
    "europenorth2"     = { city = "Stockholm", state = null, country = "Sweden", continent = "Europe", timezone = "Europe/Stockholm" }
    "europesouthwest1" = { city = "Madrid", state = null, country = "Spain", continent = "Europe", timezone = "Europe/Madrid" }
    "europewest1"      = { city = "St. Ghislain", state = null, country = "Belgium", continent = "Europe", timezone = "Europe/Brussels" }
    "europewest2"      = { city = "London", state = null, country = "United Kingdom", continent = "Europe", timezone = "Europe/London" }
    "europewest3"      = { city = "Frankfurt", state = null, country = "Germany", continent = "Europe", timezone = "Europe/Berlin" }
    "europewest4"      = { city = "Eemshaven", state = null, country = "Netherlands", continent = "Europe", timezone = "Europe/Amsterdam" }
    "europewest6"      = { city = "Zurich", state = null, country = "Switzerland", continent = "Europe", timezone = "Europe/Zurich" }
    "europewest8"      = { city = "Milan", state = null, country = "Italy", continent = "Europe", timezone = "Europe/Rome" }
    "europewest9"      = { city = "Paris", state = null, country = "France", continent = "Europe", timezone = "Europe/Paris" }
    "europewest10"     = { city = "Berlin", state = null, country = "Germany", continent = "Europe", timezone = "Europe/Berlin" }
    "europewest12"     = { city = "Turin", state = null, country = "Italy", continent = "Europe", timezone = "Europe/Rome" }

    # Middle East
    "mecentral1" = { city = "Doha", state = null, country = "Qatar", continent = "Middle East", timezone = "Asia/Qatar" }
    "mecentral2" = { city = "Dammam", state = null, country = "Saudi Arabia", continent = "Middle East", timezone = "Asia/Riyadh" }
    "mewest1"    = { city = "Tel Aviv", state = null, country = "Israel", continent = "Middle East", timezone = "Asia/Jerusalem" }

    # North America - Canada
    "northamericanortheast1" = { city = "Montréal", state = "Québec", country = "Canada", continent = "North America", timezone = "America/Montreal" }
    "northamericanortheast2" = { city = "Toronto", state = "Ontario", country = "Canada", continent = "North America", timezone = "America/Toronto" }

    # North America - Mexico
    "northamericasouth1" = { city = "Queretaro", state = "Querétaro", country = "Mexico", continent = "North America", timezone = "America/Mexico_City" }

    # South America
    "southamericaeast1" = { city = "Osasco", state = "São Paulo", country = "Brazil", continent = "South America", timezone = "America/Sao_Paulo" }
    "southamericawest1" = { city = "Santiago", state = null, country = "Chile", continent = "South America", timezone = "America/Santiago" }

    # United States
    "uscentral1" = { city = "Council Bluffs", state = "Iowa", country = "United States", continent = "North America", timezone = "America/Chicago" }
    "useast1"    = { city = "Moncks Corner", state = "South Carolina", country = "United States", continent = "North America", timezone = "America/New_York" }
    "useast4"    = { city = "Ashburn", state = "Virginia", country = "United States", continent = "North America", timezone = "America/New_York" }
    "useast5"    = { city = "Columbus", state = "Ohio", country = "United States", continent = "North America", timezone = "America/New_York" }
    "ussouth1"   = { city = "Dallas", state = "Texas", country = "United States", continent = "North America", timezone = "America/Chicago" }
    "uswest1"    = { city = "The Dalles", state = "Oregon", country = "United States", continent = "North America", timezone = "America/Los_Angeles" }
    "uswest2"    = { city = "Los Angeles", state = "California", country = "United States", continent = "North America", timezone = "America/Los_Angeles" }
    "uswest3"    = { city = "Salt Lake City", state = "Utah", country = "United States", continent = "North America", timezone = "America/Denver" }
    "uswest4"    = { city = "Las Vegas", state = "Nevada", country = "United States", continent = "North America", timezone = "America/Los_Angeles" }
  }
}

output "site_location_debug" {
  description = "Debug information for site location lookup"
  value = {
    region_key               = local.region_key
    all_location_fields_null = local.all_location_fields_null
    matched_location         = local.all_location_fields_null ? local.region_to_location[local.region_key] : null
    final_site_location      = local.cur_site_location
  }
}