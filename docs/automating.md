## Advanced Automation & Orchestration

Open Report is designed for "headless" operation, making it ideal for integration with system schedulers. Below are templates for automating your data pipeline in both Windows and Linux environments.

### 1. Environment Variables

For maximum portability across Dev, UAT, and Production environments, use **Environment Variables**. This allows you to change server aliases without modifying the scripts themselves.

| Variable    | Description                                                   |
| ----------- | ------------------------------------------------------------- |
| `OR_CONN`   | The target database server alias (e.g., `PROD_DB`).           |
| `OR_DEST`   | The destination delivery server alias (e.g., `SFTP_VAULT`).   |
| `OR_MASTER` | Your Master Password (only for non-interactive environments). |

---

### 2. Windows Automation Templates

#### **Option A: PowerShell Script (`nightly_sync.ps1`)**

PowerShell is recommended for modern Windows environments due to its robust error handling and date manipulation.

```powershell
# 1. Setup variables
$Resort = "DEMO"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$File = "Report_$Timestamp.csv"

# 2. Execution
open_report session clear
open_report dump -c $env:OR_CONN `
    -q "SELECT * FROM RESERVATION_GENERAL_VIEW WHERE resort = :r" `
    -p resort=$Resort --initialize-db -u "SUPERVISOR" --password "[SECURE_TOKEN]" `
    delimited --file-name $File

# 3. Delivery
open_report deliver sftp $env:OR_DEST "/remote/reports"

```

#### **Option B: Batch Script (`nightly_sync.bat`)**

Use this for a "no-dependency" approach that works on all Windows versions.

```batch
@echo off
SET OR_CONN=PROD_DB
SET OR_DEST=SFTP_VAULT

echo Running OpenReport Sync...
open_report session clear

:: The ^ character allows for multi-line commands in Batch
open_report dump ^
  -c %OR_CONN% ^
  -q "SELECT * FROM DUAL" ^
  --initialize-db -u "ADMIN" --password "[SECURE_TOKEN]" --resort "DEMO" ^
  delimited

open_report deliver sftp %OR_DEST% "/remote/path"
echo Done.

```

---

### 3. Linux Automation Template (`sync.sh`)

Standard shell script for Linux/macOS environments.

```bash
#!/bin/bash
export OR_CONN="PROD_DB"

# Clear, Extract, and Deliver
open_report session clear
open_report dump -c $OR_CONN -q "SELECT * FROM DUAL" delimited --file-name "data_$(date +%F).csv"
open_report deliver sftp "MY_SFTP" "/uploads"

```

---

### 4. Scheduling Tasks

Once your script is ready, use the following commands to schedule them to run automatically.

#### **Windows (via Command Line)**

Use `schtasks` to create a task that runs every night at 11:30 PM.

```cmd
schtasks /create /tn "OpenReport_Daily" /tr "C:\Scripts\nightly_sync.bat" /sc daily /st 23:30

```

#### **Linux (via Crontab)**

Open your crontab with `crontab -e` and add the following line to run at midnight:

```bash
0 0 * * * /bin/bash /home/user/scripts/sync.sh

```

---

### 5. Best Practices for Automation

- **Use Secure Tokens:** Never put plaintext passwords in your scripts. Use `open_report dump enc_password` to generate tokens first.
- **Logging:** Always redirect your script output to a log file to audit failures.
- _Batch:_ `myscript.bat >> C:\logs\report.log 2>&1`

- **Session Management:** Always include `open_report session clear` at the start of your script to ensure you don't re-upload yesterday's files.

---

\*Powered by **Xkyeron**\*
