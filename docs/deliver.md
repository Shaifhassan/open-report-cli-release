## Data Delivery (`deliver`)

The `deliver` module is the final stage of the Open Report pipeline. It is responsible for moving your generated data from your local workspace to external infrastructure.

### The Core Concept: Session Caching

The most powerful feature of the `deliver` command is its integration with the **Session Cache**.

- **What is the Cache?** Every time you run a `dump` command, the CLI "tracks" the resulting file in a temporary session record.
- **The "One-Click" Advantage:** Instead of manually typing long file paths for every upload, you simply tell the CLI _where_ to go (e.g., `sftp` or `email`). The CLI automatically gathers every file generated in that session and delivers them as a batch.
- **Manual Overrides:** You can bypass the cache using the `--no-from-cache` flag or add external files using the `--file` flag.

> [Read More about Caching](session.md)

---

### Global Command Options

These options apply to **all** delivery subcommands and control _what_ is being sent.

| Flag              | Shorthand | Description                                                       |
| ----------------- | --------- | ----------------------------------------------------------------- |
| `--file`          | `-f`      | Manually specify a file to upload. Can be used multiple times.    |
| `--from-cache`    |           | (Default: `True`) Includes all files from the current session.    |
| `--no-from-cache` |           | Ignore the session cache; only send files specified via `--file`. |
| `--add-to-cache`  |           | Adds the manual files provided via `-f` to the session record.    |

---

## Delivery Methods & Syntax

### **`SFTP / FTP` (File Transport)**

Used for moving files to remote servers, NAS drives, or Linux hosts.

**Syntax:**

```bash
open_report deliver [ftp|sftp] [SERVER_ALIAS] [REMOTE_DIRECTORY]

```

**Options:**

These protocols focus on file system navigation and binary integrity.

| Flag         | Shorthand    | Description                                          | Default                  |
| ------------ | ------------ | ---------------------------------------------------- | ------------------------ |
| `remote_dir` | (Positional) | The target folder path on the remote server.         | `.` (Root)               |
| `--port`     |              | Overrides the default port defined in server config. | `21` (FTP) / `22` (SFTP) |
| `--timeout`  |              | Seconds to wait before failing a connection.         | `30s`                    |

**Examples:**

```bash
# Upload all session files to a secure vault
open_report deliver sftp FIN_VAULT "/reports/daily/feb"

# Upload a specific old log without using the current session
open_report deliver ftp LOCAL_SRV "/backups" --file "old_data.csv" --no-from-cache

```

### **`API` (Web Services)**

Pushes data to REST endpoints, webhooks, or dashboards.

**Syntax:**

```bash
open_report deliver api [SERVER_ALIAS] --endpoint [PATH] [FLAGS]

```

**Options:**

These flags control how the CLI interacts with RESTful web services.

| Flag         | Shorthand | Description                                                   | Default |
| ------------ | --------- | ------------------------------------------------------------- | ------- |
| `--endpoint` | `-e`      | The specific API path (e.g., `/v1/upload`).                   | `/`     |
| `--as-json`  | `-j`      | If the file is `.json`, sends its content as a raw JSON body. | `False` |
| `--method`   |           | The HTTP verb to use (`POST` or `PUT`).                       | `POST`  |

**Examples:**

```bash
# Push session files as binary multipart uploads
opera_report deliver api DASHBOARD_API --endpoint "/v1/upload"

# Push a single file from the workspace
open_report deliver -f "sales.csv" --no-from-cache api SALES_API --endpoint "/v1/sales"

# Parse a JSON report and send it as a raw Request Body
open_report deliver api MONITOR_API --endpoint "/ingest" --as-json

```

### **`Email` (Stakeholder Distribution)**

Sends reports as attachments to one or more recipients.

**Syntax:**

```bash
open_report deliver email [SERVER_ALIAS] --to-addresses "[EMAILS]" --subject "[TEXT]"

```

**Options:**

These flags manage the presentation and routing of the automated message.

| Flag             | Shorthand | Description                                      | Default                |
| ---------------- | --------- | ------------------------------------------------ | ---------------------- |
| `--to-addresses` |           | Comma-separated list of recipients.              | _Server Username_      |
| `--subject`      |           | The text appearing in the email subject line.    | `Open Report Delivery` |
| `--body-text`    |           | Plain text content for the email body.           | `Please find files...` |
| `--body-html`    |           | Optional HTML string for formatted email bodies. | `None`                 |

**Examples:**

```bash
# Send all session reports to multiple managers
open_report deliver email M365_SMTP --to-addresses "gm@hotel.com,fom@hotel.com" --subject "Night Audit Pack"

# Send a quick body message with the files
open_report deliver email GMAIL_SRV --to-addresses "admin@xkyeron.com" --body-text "System health reports attached."

```

---

## Advanced Delivery Scenarios

#### **Scenario: The "Night Audit" Suite**

A single script can generate a CSV, a JSON, and a fixed-width file, then distribute them to different endpoints simultaneously:

```bash
# 1. Generate the data
open_report dump -c PROD -f query1.sql delimited
open_report dump -c PROD -f query2.sql json
open_report dump -c PROD -f query3.sql fixed-width

# 2. Distribute to SFTP for Archiving
open_report deliver sftp ARCHIVE_SRV "/2026/02/10"

# 3. Distribute to Management via Email
open_report deliver email M365_SMTP --to-addresses "exec@company.com" --subject "Daily Stats"

# 4. Clean up for tomorrow
open_report session clear

```

---

### Best Practices

- **Use SFTP over FTP:** Whenever possible, use `sftp` for the encryption of data in transit.
- **API Payloads:** Use the `--as-json` flag only for files with a `.json` extension to ensure the API receiver can parse the body correctly.
- **Email Body:** When automating via Batch/Shell scripts, use the `--body-text` flag to provide context so the email doesn't look like spam to the recipient.

---

\*Powered by **Xkyeron**\*
