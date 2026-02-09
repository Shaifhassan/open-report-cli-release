## Installation & Deployment

Open Report is distributed as a self-contained binary, ensuring zero-dependency installation across diverse enterprise environments.

### Automated Installation

The following bootstrap scripts handle binary acquisition, permission granting, and automatic **User PATH** configuration.

#### **Windows (PowerShell)**

Execute the following in an elevated PowerShell session to install the CLI and configure environment variables:

```powershell
irm https://github.com/Shaifhassan/open-report-cli-release/raw/main/install.ps1 | iex

```

#### **macOS / Linux (Bash/Zsh)**

Use the shell script to deploy the binary to `/usr/local/bin`. This may require `sudo` depending on your directory permissions:

```bash
curl -fsSL https://github.com/Shaifhassan/open-report-cli-release/raw/main/install.sh | sh

```

---

## Initialization

Before executing data operations, you must initialize the **Security Vault**. This step establishes the Master Password used to encrypt all subsequent database credentials.

```bash
open_report init

```

**The Initialization Flow:**

1. **Password Entry:** You will be prompted to enter a Master Password.
2. **Key Derivation:** The CLI generates a unique salt and derives a key via PBKDF2.
3. **Keychain Integration:** The key is securely handed off to the OS-level credential manager (Windows Credential Manager / macOS Keychain).

> [!TIP]
> **Verification:** Once initialized, you can verify your installation by running `open_report --version`.

---

## Get Started

Follow these steps to transition from a clean install to your first automated data export.

### 1. Register an Oracle Data Source

Add a new server configuration using the `add-oracle` subcommand. This registers the connection metadata and securely prompts for the database password.

**Syntax:**
`open_report servers add-oracle [NAME] [HOST] [USER] [SERVICE_NAME]`

**Example:**

```bash
open_report servers add-oracle DEMO_DB 10.0.0.5 admin_user prod_service

```

- **NAME:** A unique alias (e.g., `DEMO_DB`) used to reference this connection in future commands.
- **Security:** You will be prompted for the database password immediately after execution. It is never stored in history.

### 2. Execute a Data Dump

The `dump` command is the core engine for data extraction. It requires a connection alias (`-c`) and a SQL query (`-q`).

#### **Scenario A: Instant Data Inspection**

To preview data directly in your terminal, use the `show` output action:

```bash
open_report dump -c DEMO_DB -q "SELECT * FROM RESORT_LOG" show

```

#### **Scenario B: Enterprise Data Export**

To generate a production-ready file for external analysis, use the `delimited` output action. This defaults to a standard CSV format in your current working directory:

```bash
open_report dump -c DEMO_DB -q "SELECT * FROM RESORT_LOG" delimited

```

---

## Getting Help

Open Report features a deeply nested help system. You can append `--help` to any command or subcommand to view specific flags and usage examples.

- `open_report --help` (Global commands)
- `open_report dump --help` (Data extraction flags)
- `open_report servers --help` (Connection management)

---
