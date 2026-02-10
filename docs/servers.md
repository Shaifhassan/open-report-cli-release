## Server Management Reference

The `servers` subcommand group is used to manage your network of data sources and delivery endpoints. All credentials added via these commands are automatically encrypted using the `PBKDF2-HMAC-SHA256` engine.

The addition of **API Endpoints** and **SMTP Email** support significantly expands the reach of your data pipeline. Open Report now functions as a universal data bridge, connecting secure Oracle environments directly to modern web services and internal communication channels.

Here is the refactored **Server Registration** documentation, updated to include these new delivery channels.

---

## Server Registration

Use these commands to establish secure connections within your infrastructure. Open Report categorizes servers into **Data Sources** (where data comes from) and **Delivery Endpoints** (where data goes).

### Data Sources

#### **`add-oracle`**

Registers a new Oracle Database connection for extraction.

- **Syntax:** `open_report servers add-oracle [NAME] [HOST] [DB_USER] [SERVICE_NAME]`
- **Key Options:**
- `--port`: The database listener port (Default: `1521`).
- `--store-plain`: Skips encryption for the password (Not recommended for production).

- **Interaction:** The CLI will securely prompt you for the database password.

**Example**

```bash
# Registering a production Opera database
open_report servers add-oracle PROD_DB 10.10.20.50 OPPROD --port 1521

```

- **Context:** Connects to host `10.10.20.50` using the service name `OPPROD`.
- **Result:** You can now run reports using `-c PROD_DB`.

---

### Transport & Storage Endpoints

#### **`add-ftp` / `add-sftp`**

Registers a file transport server for automated data delivery.

- **Syntax:** `open_report servers add-ftp [NAME] [HOST] [USERNAME]`
- **Key Options:**
- `--port`: Default `21` for FTP, `22` for SFTP.

- **Interaction:** Prompts for the user password or secret token.

**SFTP Example (Secure):**

```bash
# Registering a secure file server for the Finance department
open_report servers add-sftp FIN_VAULT sftp.company.com finance_user --port 2222

```

**FTP Example (Standard):**

```bash
# Registering a legacy local printer/folder endpoint
open_report servers add-ftp LOCAL_STORAGE 192.168.1.100 backup_svc

```

#### **`add-api`**

Registers a web service endpoint. This allows you to push reporting data to REST APIs or webhooks.

- **Syntax:** `open_report servers add-api [NAME] [BASE_URL]`
- **Key Options:**
- `--auth-type`: Choose from `bearer`, `basic`, or `none`.
- `--username`: Required if using `basic` authentication.

- **Interaction:** If authentication is required, the CLI prompts for the Token or Password and stores it in the secure vault.

**No Auth Example:**

```bash
# For testing and Internal Webhooks
open_report servers add-api MEILLI "http://localhost:7077
```

**Bearer Token Example:**

```bash
# Registering a PowerBI or Custom Dashboard Webhook
open_report servers add-api DASHBOARD_API "https://api.company.com/v1/ingest" --auth-type bearer

```

**Basic Auth Example:**

```bash
# Registering a Jira or Confluence endpoint for automated logging
open_report servers add-api JIRA_LOGS "https://jira.company.com/rest/api" --auth-type basic --username "svc_account"

```

---

### Communication Endpoints

#### **`add-email`**

Registers an SMTP server to enable automated report delivery via email.

- **Syntax:** `open_report servers add-email [NAME] [USERNAME]`
- **Key Options:**
- `--smtp-server`: The SMTP host (Default: `smtp.gmail.com`).
- `--port`: The SMTP port (Default: `587`).
- `--from-address`: The "Sender" email address (Defaults to username).
- `--no-use-tls`: Disable TLS encryption (Not recommended).

- **Interaction:** Securely prompts for your SMTP application password.

**Gmail / Google Workspace Example:**

```bash
# Registering Gmail as the sender
open_report servers add-email GMAIL_SENDER reports@company.com --smtp-server smtp.gmail.com --port 587

```

**Office 365 / Outlook Example:**

```bash
# Registering a Microsoft 365 relay
open_report servers add-email M365_SENDER automations@company.com --smtp-server smtp.office365.com --port 587 --from-address "Reports Admin <automations@company.com>"

```

---

### Server Management Summary

| Type            | Command      | Primary Use Case                           |
| --------------- | ------------ | ------------------------------------------ |
| **Database**    | `add-oracle` | Oracle/Opera PMS Data Extraction           |
| **Transport**   | `add-sftp`   | Secure file movement to remote servers     |
| **Web Service** | `add-api`    | Pushing data to JSON endpoints or Webhooks |
| **Mailing**     | `add-email`  | Distribution of reports to stakeholders    |

### Best Practices

- **Alias Naming:** Use clear aliases like `PROD_DB`, `FINANCE_SFTP`, or `MGMT_EMAIL` to keep your automation scripts readable.
- **Security:** Always rely on the secure prompt for passwords rather than passing them as plain text via `--store-plain`.
- **Verification:** After adding a server, use the `servers list` command to verify its registration.

---

### Configuration Maintenance

#### **`update`**

A dynamic, "smart" update command that detects the server type and modifies only relevant fields.

- **Syntax:** `open_report servers update [NAME] [OPTIONS]`
- **Usage:** You only need to provide the flags you wish to change.
- **Key Options:**
- `--host`, `--port`, `--username`, `--password`
- `--db-user`, `--service-name` (Oracle specific)
- `--smtp-server`, `--from-address` (Email specific)

- **Example:** `open_report servers update PROD_DB --host 10.1.1.50`

#### **`list`**

Displays a tabular overview of all registered servers, their connection status, and endpoints.

- **Syntax:** `open_report servers list`
- **Output Columns:**
- `Status`: Enabled/Disabled indicator.
- `Type`: The driver type (ORACLE, FTP, etc.).
- `Name`: The unique alias.
- `Endpoint`: The connection URI or host address.

```bash
open_report servers list

```

**Expected Output Table:**

| Alias           | Type   | Host / URL                    | User                  |
| --------------- | ------ | ----------------------------- | --------------------- |
| `PROD_DB`       | Oracle | `10.10.20.50`                 | `OPPROD`              |
| `FIN_VAULT`     | SFTP   | `sftp.company.com`            | `finance_user`        |
| `DASHBOARD_API` | API    | `https://api.xkyeron.com/...` | _Token_               |
| `GMAIL_SENDER`  | Email  | `smtp.gmail.com`              | `reports@company.com` |

---

### Testing & Lifecycle

#### **`test`**

Performs a real-time handshake with the server to verify credentials and network availability. Currently supports Oracle Database sources.

- **Syntax:** `open_report servers test [NAME]`
- **Process:** Decrypts credentials temporarily in memory, attempts a session bind, and reports success/failure.

#### **`enable` / `disable`**

Toggles the operational status of a server without deleting its configuration.

- **Syntax:** `open_report servers disable [NAME]`
- **Use Case:** Use this to temporarily pause automated reports during maintenance windows.

#### **`remove`**

Permanently deletes a server configuration and its associated encrypted credentials from the local vault.

- **Syntax:** `open_report servers remove [NAME]`

---

### Integration Architecture

> [!NOTE]
> **Credential Safety:** When using the `update` command to change a password, Open Report automatically generates a new salt and re-encrypts the entry. The old salt is discarded to ensure cryptographic freshness.

---

\*Powered by **Xkyeron**\*
