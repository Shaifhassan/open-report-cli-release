## Encryption & Vault Management

Open Report provides a specialized utility suite for securing sensitive data. While the CLI handles connection encryption automatically, the `encrypt` module allows users to manually protect passwords and package SQL scripts into secure, encrypted `.zsql` archives.

### Secure Credential Injection

The `password` command allows you to generate secure, encrypted tokens for use in automation scripts, ensuring that plaintext passwords never appear in shell histories or batch files.

- **Command:** `open_report encrypt password`
- **Workflow:** 1. The CLI prompts for a password (input is hidden).

2.  The string is encrypted using the local **Security Vault**.
3.  A secure token is returned for use in `--password` flags.

---

## Secure Credential Injection

When automating reports (e.g., via Task Scheduler or Cron), passing a plaintext password or tokens via the command line is a security risk. Open Report provides a dedicated utility to encrypt passwords into "Secure Tokens" that only your CLI installation can decrypt.

### Generating a Secure Token

Use the `password` utility to convert a plaintext password into an encrypted string.

```bash
open_report encrypt password

```

**Process:**

- You will be prompted: `Enter Password: ` (Input will be hidden).
- The CLI uses your unique **Master Password** and **Installation Salt** to encrypt the string.

```
✅ Success: Password encrypted successfully
--- Your encrypted password ---
[SECURE_TOKEN_XXXXX]
```

### Using the Token in Automation

Once you have the token, you can use it in your `--initialize-db` workflow. The CLI automatically detects that the string is encrypted and decrypts it in memory right before the handshake.

#### **Method A: Via Smart Parameters (Recommended)**

```bash
open_report dump -c PROD -q "SELECT..." -p resort="DEMO" -p password="[SECURE_TOKEN_XXXXX]" --initialize-db

```

#### **Method B: Via Explicit Flag**

```bash
open_report dump -c PROD -q "SELECT..." --password "[SECURE_TOKEN_XXXXX]" --initialize-db

```

#### Key Security Advantages

- **History Obfuscation:** If someone scrolls through your terminal history or logs, they will only see the encrypted token, not your actual database password.
- **Non-Portable Tokens:** Because the encryption is tied to your specific OS Keychain and Master Password, the token is useless if stolen and moved to a different machine.
- **Pipeline Integration:** This method allows you to safely store your "passwords" inside `.bat` or `.sh` files within your repository without exposing credentials to other developers.

> [!WARNING]
> **Encryption Context:** The `password` command uses a system-defined salt. If you change your Master Password or move to a new machine, you will need to re-generate these tokens as the encryption context will have changed.

---

## Secure Query Archives (.zsql)

The `query` command introduces the `.zsql` format an encrypted archive that bundles one or more SQL files into a single secure vault. This is ideal for distributing proprietary reporting logic across teams without exposing the underlying SQL.

#### **Key Features**

- **Bundling:** Package multiple `.sql` files into a single `.zsql` archive.
- **Optional Protection:** Use the `--protect` flag to add an additional layer of password protection to the archive.
- **Path Intelligence:** Like data exports, archives are automatically saved to your **Default Workspace** unless an absolute path is provided.

#### **Command Syntax**

```bash
open_report encrypt query -f [FILE1] -f [FILE2] -o [ARCHIVE_NAME]

```

#### **Enterprise Usage Example**

Encrypting a set of financial audit scripts with an additional password:

```bash
open_report encrypt query \
  -f ./queries/audit_history.sql \
  -f ./queries/audit_future.sql \
  --output-name "Feb_Audit_Vault" \
  --protect

```

---

### Command Reference

| Flag            | Shorthand | Description                                                          |
| --------------- | --------- | -------------------------------------------------------------------- |
| `--query-file`  | `-f`      | Path to the SQL file(s) to be encrypted. Can be used multiple times. |
| `--output-name` | `-o`      | The name of the resulting `.zsql` file.                              |
| `--protect`     | `-p`      | Prompt for a password to secure the archive.                         |

### Technical Note: The .zsql Format

The `.zsql` format uses the same **PBKDF2-HMAC-SHA256** standards as the core CLI.

- **Standard Encryption:** Uses your installation's unique Master Password.
- **Protected Encryption:** If `--protect` is used, the archive requires both the installation key and the archive-specific password to unlock, providing "Two-Factor" logic for your SQL files.

**Process:**

- When `protect` flag is on you will be prompted: `Enter password to protect the archive: ` (Input will be hidden).
- The CLI uses your unique **Master Password** and **Installation Salt** to encrypt the string.

```
✅ Success: Encrypted query archive created at: [OUTPUT_PATH]
--- Your zSQL key ---
[SECURE_TOKEN_XXXXX]
```

### Using the Token in Automation

Once you have the token, you can use it in your `dump` workflow. instead of passing standard query you can now use the `z-sql-file` and `z-sql-key` flags to pass the newly created zSql files.

#### **Method A: For basic encrypted files**

```bash
open_report dump -c DEMO --z-sql-file "archive2.zsql" show

```

#### **Method B: For Password encrypted files**

```bash
open_report dump -c DEMO --z-sql-file "archive2.zsql" --z-sql-key "[SECURE_TOKEN_XXXXX]" show

```

### Best Practices for Query Security

> [!IMPORTANT]
> **One-Way Visibility:** To maintain high security, Open Report does not provide a public "decrypt" command for general users. `.zsql` files are intended to be consumed directly by the `dump` command for execution.

- **Version Control:** Store your `.sql` files in a private repository and only distribute the `.zsql` versions to end-users or production servers.
- **Key Rotation:** If a Master Password is changed, it is recommended to re-generate sensitive `.zsql` archives to ensure they remain compatible with the updated vault.

---

\*Powered by **Xkyeron**\*
