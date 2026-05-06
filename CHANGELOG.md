# Changelog

## Unreleased

### Features
- Added `ha` input (default `true`) to support non-HA single-vSocket deployments.
- Made secondary vSocket resources conditional on `ha`.
- Made secondary IP inputs and `load_balancer_ip` optional for non-HA usage.

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
