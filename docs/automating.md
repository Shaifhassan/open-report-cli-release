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

#### **Option C: PowerShell Script & Batch Automation (`Back_office_export.ps1`)**

Sample powershell script to run a automatic back office file

```powershell
# Run-Backoffice Export.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ----- Working directory -----
$WorkingDir = 'D:\BOF'
Set-Location $WorkingDir
Write-Host "Changed working directory to $WorkingDir" -ForegroundColor Green

# 1. Setup configuration
# to get SecureToken Password for the user name use
# ./open_report.exe encrypt password
# and enter the Password for Username
$Config = [ordered]@{
    ExePath     = '.\open_report.exe'
    Resort      = 'DEMO'
    FileNameTmpl= 'RV{0}_{1}.ndf'
    UserName    = 'SUPERVISOR'
    SecureToken = 'gAAAAABqauuoOMVKsNIIjKjqXDt_MwDyxHr4jfsWd_s8y0hBP7zL_vbu3Su4bZkWHny4ZkT7MGemYfVLqJB5JAp-Mll2aByxtA=='
}

# Resolve Date & File Name
$YesterdayDate = (Get-Date).AddDays(-1)
$YesterdayStr  = $YesterdayDate.ToString('yyyy-MM-dd')
$FileName      = [string]::Format($Config.FileNameTmpl, $Config.Resort, $YesterdayDate.ToString('yyyyMMdd'))

# Fix: Ensure single quotes are included around the date string for PL/SQL
$BeforeStatement = "BEGIN BOF_VIEW_REF.SET_TRANSFER_DATE(TO_DATE('$YesterdayStr', 'YYYY-MM-DD')); END;"

# Define the runs
$Runs = @(
    @{
        QueryFile = "$PWD/sql/01_header.sql"
        Widths    = '32,6,474'
        Append    = $false
    },
    @{
        QueryFile = "$PWD/sql/02_main.sql"
        Widths    = '10,5,7,8,2,1,14,18,1,1,5,5,15,94,5,18,18,14,15,15,15,15'
        Append    = $true
    }
)

# Base arguments matching your original batch command structure
$baseArgs = @(
    'dump',
    '-c', $Config.Resort,
    '--before-statement', $BeforeStatement,
    '-p', "resort=$($Config.Resort)",
    '-p', "username=$($Config.UserName)",
    '-p', "password=$($Config.SecureToken)",
    '-p', "p_date=$YesterdayStr",
    '--initialize-db',
    '--file-name', "$FileName"
)

# ----- Execute each run -----
$runIndex = 0
foreach ($run in $Runs) {
    $runIndex++

    # Construct complete argument list for this run
    $cmdArgs = @()
    $cmdArgs += $baseArgs
    $cmdArgs += @('--query-file', $run.QueryFile)

    if ($run.Append) {
        $cmdArgs += '--append-file'
    }

    $cmdArgs += @(
        'fixed-width',
        '--widths', $run.Widths,
        '--right-align-numeric'
    )

    Write-Host ("Run #{0}: {1} {2}" -f $runIndex, $Config.ExePath, ($cmdArgs -join ' ')) -ForegroundColor DarkGray

    # Execute external tool with argument splatting
    & $Config.ExePath @cmdArgs

    if ($LASTEXITCODE -ne 0) {
        throw "open_report exited with code $LASTEXITCODE on run #$runIndex"
    }
}
```

for automation create a `batch file` and run to run the powershell script

```batch
@echo off
setlocal
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%bof_export.ps1"
if errorlevel 1 pause
endlocal
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
