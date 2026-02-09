## Data Delivery (deliver)

The `deliver` module is responsible for the secure transport of your generated reports to external endpoints. It integrates natively with the **Session Cache**, allowing for one-click distribution of entire report batches.

### Core Concept: Session-Driven Delivery

By default, the `deliver` command looks at your current session. If you have generated three CSVs and two JSON files in your previous `dump` steps, `deliver` will detect all five files and upload them in a single execution.

---

### Delivery Protocols

#### **1. `ftp`**

Uploads files to a standard FTP server using the credentials stored in your secure vault.

- **Syntax:** `open_report deliver ftp [SERVER_NAME] [REMOTE_DIR]`
- **Example:** `open_report deliver ftp OFFICE_CORE "/reports/daily"`

#### **2. `sftp`**

Uploads files via SSH File Transfer Protocol for enhanced security.

- **Syntax:** `open_report deliver sftp [SERVER_NAME] [REMOTE_DIR]`
- **Example:** `open_report deliver sftp SECURE_VAULT "/incoming"`

---

### Command Options

| Flag             | Shorthand | Description                                                                                                                     |
| ---------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `--file`         | `-f`      | Manually specify a file to upload (ignoring or adding to cache). support multiple files                                         |
| `--from-cache`   |           | Include all files from the current session cache, Set to `--no-from-cache` if you only want to upload manually specified files. |
| `--add-to-cache` |           | If you specify a manual file via `-f`, this flag adds it to the session record for future use.                                  |

---

### Delivery Scenarios

#### **Scenario A: Automated Batch Upload (Preferred)**

After running multiple `dump` commands, simply run:

```bash
open_report deliver sftp MY_SERVER "/uploads"

```

_The CLI will automatically find every file you generated in the current session and upload them._

#### **Scenario B: Specific File Delivery**

If you want to send a specific file that wasn't part of your current session:

```bash
open_report deliver ftp MY_SERVER "/manual" --file "./old_report.csv" --no-from-cache

```

#### **Scenario C: Hybrid Delivery**

Upload everything from your session **plus** manually defined files:

```bash
open_report deliver ftp MY_SERVER "/daily" --file "./external_log.txt" --file "./export.csv"

```

---

### Best Practices for Enterprise Delivery

- **Connection Testing:** Before scheduling an automated delivery, use the `open_report servers test [NAME]` command to ensure the target server is reachable.
- **Directory Preparation:** Ensure the `remote_dir` exists on the target server. Most enterprise servers require specific permissions to create new directories.
- **Session Cleanup:** For scheduled tasks, always end your script with `open_report session clear` to prevent the next day's run from re-uploading old files.

> [!TIP]
> **Performance:** For large batches, SFTP is generally more stable than standard FTP. If your organization supports both, prioritize **SFTP** for critical financial data.

---
