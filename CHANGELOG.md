# Changelog

## 1.0.6 - 2026-01-19

### Changed

- Changed Adminer theme.

## 1.0.5 - 2026-01-18

### Added

- Added `CHANGELOG.md`
- Added `config/adminer-plugins.php`
- Added `setenforce Permissive` and firewall commands to unblock localhost websites.

### Changed

- Updated YAML array format in `settings.yaml`.
    - Added `:id` to all `:forwarded_ports`.
- Updated `Vagrantfile` by adding local variables.
    - Modernized path in the `YAML.load_file()` call.
- Replaced `FORWARDED_PORT_80` variable with `HOST_HTTP_PORT` in 3 files.
    - Updated `provision.sh`, `adminer.conf`, `virtualhost.conf` with new variable name.
- Modified the version section of `provision.sh` for the section title and the Apache version output.
- Updated the last section of `README.md`.
- Updated `config/adminer.php`.

### Fixed

- Updated Adminer to version 5+ plugin code and files.
- Fixed the URLs for End Of Life repositories.
    - Replaced yum repositories URLs in `/etc/yum.repos.d/CentOS-*` files.
    - Original CentOS mirrors no longer supported.

## 1.0.4 - 2023-01-15

### Changed

- Updated to PHP 7.4.
- Updated Adminer.

## 1.0.3 - 2022-05-06

### Changed

- Moved box name to `settings.yaml`.
- Added checks in `provision.sh`.

## 1.0.2 - 2022-04-28

### Added

- Added Python 3.

### Changed

- Removed VM_CONFIG_PATH.
- Updated README.

### Fixed

- Fixed dnf cache.

## 1.0.1 - 2021-04-26

### Added

- Added SSH forwarded ports to `settings.yaml`.
- Added `:php_error_reporting` to `settings.yaml`.

### Changed

- Updated MariaDB to version 10.6.
- Modified `Vagrantfile` and `provision.sh`.

## 1.0.0 - 2021-04-15

_First release_
