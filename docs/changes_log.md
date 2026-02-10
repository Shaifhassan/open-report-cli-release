# Changelog

All notable changes to the **Open Report CLI** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.3] - 2026-02-10

### Added

- **Encryption Toolkit**: Dedicated `encrypt` command group featuring `password` (for credential obfuscation) and `query` (for creating `.zsql` archives).
- **Z-SQL Native Support**: The `dump` command now accepts `.zsql` files. It supports both basic encryption and password-protected archives via the new `z_sql_key` logic.
- **Universal Delivery Servers**: Added server registration support for **API Endpoints** (REST/Webhooks) and **SMTP Email** servers.
- **Multi-Channel Delivery**: Expanded the `deliver` module with native `api` and `email` subcommands, including support for JSON body parsing and automated attachments.

### Improved

- **Union Query Engine**: Refactored `dump` to support simultaneous multiple file inputs (`-f`), which are now automatically combined into a single `UNION ALL` execution plan.
- **Cryptography Core**: Upgraded the underlying encryption engine for better performance and cross-platform key handling.
- **Session Intelligence**: Improved the way the CLI tracks and batches files in the session cache.

### Fixed

- **Double Initialization Warning**: Resolved the issue where `app_context` was being initialized multiple times in certain Oracle/Opera environments.
- **Broken Links**: Fixed various internal documentation links in the README.
- **Minor Bug Fixes**: Resolved edge-case failures in path resolution and general stability improvements.

---

## [1.0.2] - 2026-02-09

### Added

- **Workspace Path Management**: Introduced `set-output-dir` and `output-path` commands to manage a global default workspace for all exports.
- **Smart Path Resolution**: Added support for anchoring relative paths to the default workspace while maintaining absolute path overrides.
- **Dynamic Parameter Resolution**: Added the `@[...]` syntax to allow resolving parameters via database function calls (e.g., fetching `pms_p.business_date`) before report execution.
- **Smart Parameter Mapping**: The CLI now automatically maps `-p resort` and `-p username` to session initialization requirements, reducing redundant flags.

### Fixed

- Improved directory handling: The CLI now recursively creates the entire folder path if it does not exist during a `dump` operation.
- Fixed a bug where `clear_password` flag was not properly bypassing keychain encryption for temporary overrides.

---

## [1.0.1] - 2026-02-04

### Added

- **Session Tracking**: Introduced the `session` command group to track, list, and remove generated files within a work cycle.
- **Batch Delivery**: Added `deliver` command for FTP/SFTP, utilizing the session cache to upload multiple files in a single execution.
- **Cross-Platform Bootstrapping**: Added PowerShell and Bash installation scripts for instant deployment.

### Changed

- Refactored `OracleEngine` to support both Thin and Thick client modes for broader Oracle version compatibility.

---

## [1.0.0] - 2026-01-28

### Added

- **Initial Release**: Core CLI architecture launched.
- **Security Vault**: Implementation of PBKDF2-HMAC-SHA256 encryption integrated with OS Keychain (Windows Credential Manager / macOS Keychain).
- **Core Commands**: Support for `add-oracle`, `add-ftp`, and basic `dump` functionality (CSV, JSON).
- **Manual Hooks**: Added `--before-statement` and `--after-statement` for session lifecycle management.

---

<!-- ## [Unreleased]

* Support for API Endpoint delivery (`add-api`).
* Email delivery support (SMTP).
* Native Excel (.xlsx) export support using XlsxWriter. -->

---

\*Powered by **Xkyeron**\*
