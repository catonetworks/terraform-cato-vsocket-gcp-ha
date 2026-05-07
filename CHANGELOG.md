# Changelog

## 0.0.2 (2025-09-25)

### Features
- Initial commit 

## 0.0.3 (2025-10-15)

### Features
- Updated flaotingip param referenced in underlying API to loadbalancerIp

## 0.0.5 (2025-11-04)

### Features
- Added EA verbiage

## 0.0.6 (2026-02-18)

### Features
- Reverted to provider version 0.0.57 to address local_ip and gateway api param issue in state

## 0.0.7 (2026-05-07)

### Fixes
- Replaced dynamic `cato_siteLocation` data source lookup with a hardcoded `region_to_site_location` mapping
- Mapping covers all major GCP regions across North America, Canada, Europe, Asia Pacific (including Australia and India), Middle East, Africa, and South America
- Removed `site_location_debug` output; replaced with `site_location` output exposing the resolved location
