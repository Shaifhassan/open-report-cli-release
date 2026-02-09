## Server Management Reference

The `servers` subcommand group is used to manage your network of data sources and delivery endpoints. All credentials added via these commands are automatically encrypted using the `PBKDF2-HMAC-SHA256` engine.

### Data Source Registration

Use these commands to establish a new connection to your infrastructure.

#### **`add-oracle`**

Registers a new Oracle Database connection.

- **Syntax:** `open_report servers add-oracle [NAME] [HOST] [DB_USER] [SERVICE_NAME]`
- **Options:**
- `--port`: The database port (Default: `1521`).
- `--store-plain`: Boolean flag to skip encryption (Not recommended for production).

- **Interaction:** Prompts for the database password securely.

#### **`add-ftp` / `add-sftp`**

Registers a file transport endpoint for data delivery.

- **Syntax:** `open_report servers add-ftp [NAME] [HOST] [USERNAME]`
- **Options:**
- `--port`: Default `21` for FTP, `22` for SFTP.

- **Interaction:** Prompts for the user password or secret token.

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
