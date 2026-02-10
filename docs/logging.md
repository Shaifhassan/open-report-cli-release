## Observability & Logging

Open Report features a centralized logging engine that captures execution details, connection attempts, and data extraction metrics. Proper log management is vital for auditing and troubleshooting automated workflows in production environments.

> [!NOTE]
> Logging is disabled by default

### Logging Commands

The `logger` subcommand group allows you to manage how and where the CLI records its activity.

#### **`show`**

Displays the active logging profile, including the storage path and severity threshold.

- **Syntax:** `open_report logger show`
- **Output Parameters:**
- **Enabled:** Boolean state indicating if logs are currently being written.
- **Directory:** The file system path where `.log` files are persisted.
- **Level:** The current verbosity filter (e.g., `INFO`, `DEBUG`).

#### **`set`**

Modifies the logging behavior in real-time. Changes are applied immediately to the next command execution.

- **Syntax:** `open_report logger set [OPTIONS]`
- **Options:**
- `--enabled / --no-enabled`: Toggles log recording.
- `--log-dir [PATH]`: Sets the target directory. Use absolute paths for production server environments.
- `--log-level [LEVEL]`: Configures verbosity. Supported levels: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`.

---

### Understanding Log Levels

To optimize disk space and troubleshoot effectively, choose the level that matches your environment:

| Level        | Recommended Use Case                                                                   |
| ------------ | -------------------------------------------------------------------------------------- |
| **DEBUG**    | **Development Only.** Captures full stack traces and sensitive execution metadata.     |
| **INFO**     | **Standard Operation.** Logs successful connection handshakes and export summaries.    |
| **WARNING**  | **Pre-Production.** Highlights non-fatal issues like deprecated flags or slow queries. |
| **ERROR**    | **Production Baseline.** Records connection timeouts and failed SQL executions.        |
| **CRITICAL** | **Emergency.** Logs system-level failures (e.g., OS Keychain inaccessible).            |

---

### Best Practices for Enterprise Logging

> [!IMPORTANT]
> **Log Rotation:** Open Report creates standard log files. In high-volume production environments, it is recommended to use an external utility like `logrotate` (Linux) or a scheduled PowerShell script (Windows) to archive and purge old logs to prevent disk saturation.

- **Audit Trails:** Set the level to `INFO` for production tasks to maintain a history of which user extracted data and when.
- **Troubleshooting:** If a `dump` command fails silently in a CI/CD pipeline, temporarily set the level to `DEBUG` to view the underlying Oracle driver errors.

---

\*Powered by **Xkyeron**\*
