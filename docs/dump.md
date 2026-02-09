## Data Extraction (`dump`)

The `dump` utility is designed for high-performance data retrieval. It supports parameterized queries, multi-file merging, and specialized integration for Oracle Opera PMS environments.

### The Execution Flow

The `dump` command follows a specific sequence to ensure data integrity and security:

1. **Identity Resolution:** Locates the server alias in your secure config.
2. **Credential Decryption:** Retrieves the database password from the OS Keychain.
3. **Query Composition:** Merges SQL strings, files, or folders into a single execution plan.
4. **Parameter Injection:** Binds dynamic variables to the SQL execution context.
5. **Output Generation:** Streams data into the requested format (CSV, JSON, etc.).

---

### Global Extraction Options

These flags are available to all subcommands under `dump`.

| Flag            | Shorthand | Description                                              |
| --------------- | --------- | -------------------------------------------------------- |
| `--conn`        | `-c`      | The server alias defined in `servers add-oracle`.        |
| `--query`       | `-q`      | A raw SQL string to execute.                             |
| `--query-file`  | `-f`      | Path to a `.sql` file.                                   |
| `--param`       | `-p`      | Pass variables using `key=value` syntax.                 |
| `--file-name`   |           | Custom path/name for the export.                         |
| `--append-file` |           | Appends data to an existing file instead of overwriting. |

---

### Output Subcommands

#### **1. `delimited` (CSV/TSV)**

The most common export format for data analysts.

- **Example:** `open_report dump -c PROD -q "SELECT * FROM DUAL" delimited --delimiter ","`
- **Key Option:** `--no-show-header` to suppress column names (useful for append operations).

#### **2. `json`**

Generates a machine-readable JSON array of records.

- **Example:** `open_report dump -c PROD -f ./report.sql json --indentation 2`

#### **3. `fixed-width`**

Used for legacy system integrations requiring specific character lengths.

- **Options:**
- `--widths`: A comma-separated list of integers (e.g., `10,20,5`).
- `--right-align-numeric`: Automatically aligns numbers to the right.

- **Example:** `open_report dump -c PROD -1 ./report.sql fixed-width --widths 10,20,5`

#### **4. `show`**

A "Preview Mode" that prints the data to the terminal in a clean tabular format without creating a file.

---

## Database Initialization

Open Report includes native support for **Opera PMS (Oracle Hospitality)** session initialization.

When using the `--initialize-db` flag, the CLI automatically executes the necessary `app_context` initialization before running your report.

- **Secure Prompting:** If `--username` or `--password` or `--resort` are omitted, the CLI will prompt for them securely.
- **Command Example:**

```bash
open_report dump -c OPERA_PROD -q "SELECT * FROM v_resv_name" --initialize-db -u MYUSER -r HOTEL01 delimited

```

> [!NOTE]
> if `--password` is skipped a secure input will be prompted to enter the password.
> avoid typing clear password

---

---

## Smart Parameter Mapping

Open Report features an intelligent mapping system designed to reduce redundancy in your commands. The CLI automatically synchronizes global parameters (`-p`) with specialized flags (like `--resort` or `--username` or `--password`), allowing you to define your context once.

### How it Works

When the `--initialize-db` flag is active, the CLI performs a "pre-flight" check on your parameters. If it detects specific keys in your `-p` list that match required session variables, it maps them automatically.

This means you can avoid passing duplicate flags for the same information.

#### **Redundant (Traditional) Syntax:**

In older versions or standard CLIs, you might have to repeat yourself:

```bash
# Don't do this - it's repetitive!
# here your repeating the same resort in parameter and also for initializing purpose
open_report dump -c DEMO -q "SELECT..." -p resort="DEMO" -r "DEMO" --initialize-db

```

#### **Smart Resolved Syntax:**

Open Report simplifies this. If you define it in your parameters, the session initialization "borrows" that value:

```bash
# Enterprise Grade - Clean and concise
# if a parameter is defined with the same name duplicating for initialize purpose
open_report dump -c DEMO -q "SELECT..." -p resort="DEMO" -p username="SUPERVISOR" --initialize-db show

```

### Automatic Resolution Priority

The CLI resolves session variables in the following order of priority:

1. **Explicit Flags:** If you use `-r` or `-u`, these take the highest priority.
2. **Smart Parameters:** If flags are missing, it looks for `resort`, `username`, or `password` inside your `-p` declarations.
3. **Interactive Prompt:** If the value is still missing, the CLI will securely prompt you for the input.

---

### Benefits for Automation

- **Single Source of Truth:** You only need to manage one list of variables in your calling scripts or batch files.
- **Cleaner Logs:** Reduces the length of the commands stored in your shell history or log files.
- **Framework Compatibility:** Makes it easier to integrate with scheduling tools that pass data as generic key-value pairs.

> [!NOTE]
> **Security Reminder:** While `password` can be resolved via Smart Mapping, we recommend using the **Master Password Vault** or **Encrypted String** methods for production passwords to ensure they are never visible in plaintext in your command history.

---

---

---

## Dynamic Parameter Resolution

Open Report allows for advanced parameter parsing where values can be resolved dynamically via database function calls before the main query executes. This is particularly useful for workflows that depend on system variables like the **Business Date**.

### Usage with Database Functions

You can pass a database expression as a parameter value by using the `@[]` syntax. The CLI will resolve the expression within the `@[]` brackets against the database first, then inject the result into your main query.

#### **Enterprise Example: Opera Business Date**

Instead of manually typing today's date, you can instruct Open Report to fetch it from the PMS system automatically:

```bash
open_report dump \
  -c DEMO \
  -q "SELECT RESV_NAME_ID FROM RESERVATION_GENERAL_VIEW WHERE resort = :resort AND arrival = TO_DATE(:p_date, 'YYYY-MM-DD')" \
  -p resort="DEMO" \
  -p p_date="@[to_char(pms_p.business_date, 'YYYY-MM-DD')]" \
  --initialize-db -u SUPERVISOR \
  show

```

```bash
# add calculations to resolve the date dynamically
-p p_date="@[to_char(pms_p.business_date + 1, 'YYYY-MM-DD')]"
```

### Breakdown of the Logic:

1. **Context Initialization:** The `--initialize-db` flag ensures the session is logged in (e.g., as `SUPERVISOR`) so that packages like `pms_p` are accessible.
2. **The Dynamic Filter:** The CLI detects `@[...]`, executes `SELECT to_char(pms_p.business_date, 'YYYY-MM-DD') FROM DUAL`, and captures the result.
3. **Variable Injection:** The resolved date is then bound to the `:p_date` placeholder in your main query.
4. **Result:** Your report always runs for the current system business date without manual intervention.

---

### Parameter Parsing Rules

| Parameter Format | Description                             | Example                         |
| ---------------- | --------------------------------------- | ------------------------------- |
| **Static**       | Hardcoded string or number              | `-p resort="SAIV"`              |
| **Dynamic**      | Resolved via DB function using `@[...]` | `-p p_date="@[trunc(sysdate)]"` |
| **Escaped**      | Handles spaces and special characters   | `-p filter="In House"`          |

> [!TIP]
> **Performance Note:** Dynamic parameters require an extra round-trip to the database to resolve the function. For bulk automation, ensure your function calls are optimized and index-friendly.

---

## Session Lifecycle Hooks (Before/After)

To support complex reporting workflows, Open Report allows you to execute "Hooks"—SQL statements that run immediately before the data extraction begins and immediately after it completes.

### Automatic PL/SQL Wrapping

To keep commands clean and developer-friendly, the CLI is "Smart." You do not need to include `BEGIN` and `END;` keywords. Open Report automatically wraps your statements in an anonymous PL/SQL block, ensuring they execute correctly within the Oracle session.

#### **Key Use Cases**

- **Initialization:** Populating temporary tables or setting session variables.
- **Audit Logging:** Inserting a record into an audit table before the report starts.
- **Cleanup:** Truncating temp tables or closing sessions after data is fetched.

---

### Implementation Example

In this scenario, we generate temporary data, run our report, and then clean up the database.

```bash
open_report dump -c PROD_DB \
  --before-statement "pms_p.populate_temp_report_data(:resort)" \
  -q "SELECT * FROM temp_report_results" \
  -p resort="SAIV" \
  --after-statement "pms_p.clear_temp_data" \
  delimited

```

### How it Works Under the Hood

When you pass these flags, the CLI orchestrates the execution as follows:

1. **Before Statement:** Executed as `BEGIN [your_statement]; END;`. If this fails, the process halts to prevent incorrect data reporting.
2. **Main Query:** The data is fetched and stored in the requested format.
3. **After Statement:** Executed as `BEGIN [your_statement]; END;`. This runs regardless of whether the main query succeeded (unless there was a connection failure), ensuring your environment stays clean.

---

### Best Practices

- **Atomic Actions:** Keep before/after statements concise. For complex logic, call a stored procedure rather than writing long SQL strings.
- **Parameter Passing:** You can use the same `:placeholders` in your hooks that you use in your main query.
- **Error Handling:** Use the `logger` at `DEBUG` level to see the full PL/SQL block if a hook fails.

---

Understood. For the documentation, we should focus purely on the user interface (the CLI) and how an administrator would use it to manage their workspace.

Here is the enterprise-grade documentation for **Workspace Path Management**.

---

## Workspace Path Management

Open Report maintains a "Home" for all your data exports. Instead of manually editing configuration files, you can use the built-in CLI commands to inspect or redirect your default reporting hub.

### `output-path` View Current Workspace

To verify the active directory where files will be saved by default, use the `output-path` utility. This is essential for auditing automated systems.

**Command:**

```bash
open_report dump output-path

```

**Expected Output:**

```text
ℹ️ Info: Default output directory: C:/Users/Admin/Reports

```

### `set-output-dir` Update Default Workspace

To relocate your reporting hub to a different drive, a network share, or a dedicated server folder, use the `set-output-dir` command.

**Command:**

```bash
open_report dump set-output-dir "D:/Enterprise/Data/Reports"

```

**Expected Output:**

```text
✅ Success: Default output directory updated to: D:/Enterprise/Data/Reports

```

---

## Output File Management

Once your workspace is set, the CLI intelligently handles the `--file-name` flag based on whether you provide a name, a relative path, or a full system path.

### The Workspace Hierarchy

The CLI resolves the final destination of a file based on a specific priority sequence:

1. **Absolute Override:** If a full system path is provided, it is used exactly as written.
2. **Relative Anchor:** If a partial path is provided, it is appended to the `default_output_dir` defined in your config.
3. **Automated Naming:** If no name is provided, a timestamped file is generated inside the `default_output_dir`.

---

### Using the `--file-name` Flag

You can control the output location on a per-command basis using the `--file-name` flag.

#### **Scenario A: Absolute Paths (System Override)**

Use this for specific, one-off exports to shared drives or system folders.

```bash
# Data will be saved exactly at the specified location
open_report dump -c PROD -q "SELECT..." --file-name "D:/Shared/Finance/Final_Report.csv" delimited

```

#### **Scenario B: Relative Paths (Sub-folders)**

Use this to organize reports into sub-directories within your workspace. Open Report will automatically create any missing folders.

```bash
# If workspace is "C:/Reports", file will land in "C:/Reports/Daily/sales.csv"
open_report dump -c PROD -q "SELECT..." --file-name "Daily/sales.csv" delimited

```

#### **Scenario C: Filename Only**

Simply providing a name anchors it to the root of your workspace.

```bash
# File will land in "[Workspace]/quick_export.csv"
open_report dump -c PROD -q "SELECT..." --file-name "quick_export.csv" delimited

```

---

### Comparison Table: Path Resolution

| Input Flag           | Configuration Root | Resolved Result                         |
| -------------------- | ------------------ | --------------------------------------- |
| _None_               | `/app/data`        | `/app/data/dump_PROD_20260209_1200.csv` |
| `audit.csv`          | `/app/data`        | `/app/data/audit.csv`                   |
| `fin/jan.csv`        | `/app/data`        | `/app/data/fin/jan.csv`                 |
| `C:/Exports/log.csv` | `/app/data`        | `C:/Exports/log.csv` (Root Ignored)     |

---

### Operational Best Practices

> [!IMPORTANT]
> **Directory Auto-Creation:** Open Report uses "Deep-Path" creation. If you specify `--file-name "year/month/day/report.csv"`, the CLI will recursively create every folder in that chain if they do not exist.

- **UNC Paths:** For Windows server environments, you can set your output directory to a network share: `open_report dump set-output-dir "\\FILE-SERVER-01\Public\Reports"`.
<!-- - **CI/CD Integration:** When running in GitHub Actions, set your output directory to `./dist` to easily capture the reports as build artifacts. -->

---

## Batch Query Execution (Query Folders)

Open Report provides a streamlined way to execute multiple SQL scripts as a single unified dataset. This is ideal for "Union Reporting" where data is split across different tables but needs to be exported as one cohesive file.

### How it Works

When you use the `--query-folder` flag, Open Report performs the following:

1. **Discovery:** Scans the designated folder for files matching your extension (default: `.sql`).
2. **Merging:** Reads all discovered files and concatenates them into one large execution string, separated by newlines.
3. **Unified Execution:** Sends the combined script to the Oracle engine as a single block.

> [!IMPORTANT]
> **Column Mapping:** Since the scripts are merged, if your queries are intended to form a single dataset, the number of columns and their data types **must match exactly** across all files in the folder.

### Query Path Resolution

Just like output files, query files and folders support both **Absolute** and **Relative** paths:

- **Absolute Paths:** If you provide a full path (e.g., `C:/SQL/Monthly`), the CLI looks exactly there.
- **Relative Paths:** If you provide a partial path (e.g., `queries/reports`), the CLI anchors it to your **Default Workspace** (the directory set via `set-output-dir`).

---

### Enterprise Example: History & Future Union

Imagine you have two separate SQL files in a folder named `inventory_stats`:

1. `01_history.sql`: Fetches data from `RESV_HISTORY_VIEW`.
2. `02_forecast.sql`: Fetches data from `RESV_FORECAST_VIEW`.

**Command:**

```bash
open_report dump -c PROD --query-folder "inventory_stats" delimited

```

**Resolution Logic:**
Open Report finds the folder inside your workspace, joins the two scripts, and produces a single CSV containing both historical and future records.

---

### Filter and Extension Options

You can fine-tune which files are picked up using the filter and extension flags.

| Flag              | Description                                        | Example                       |
| ----------------- | -------------------------------------------------- | ----------------------------- |
| `--query-folder`  | The directory containing your SQL scripts.         | `--query-folder "sales"`      |
| `--extensions`    | The file type to look for (Default: `sql`).        | `--extensions "txt"`          |
| `--folder-filter` | A glob pattern to filter filenames (Default: `*`). | `--folder-filter "finance_*"` |

**Example (Filtering for specific files):**

```bash
# Only merge files starting with 'finance_' and ending in .sql
open_report dump -c PROD --query-folder "reports" --folder-filter "finance_*" delimited

```

---

### Best Practices for Batch Queries

- **Sequential Naming:** Use numeric prefixes (e.g., `01_`, `02_`) if the order of execution matters for your data union.
- **Workspace Anchoring:** Keep your SQL templates inside your defined `default_output_dir` so you can use short, relative paths in your automation scripts.
- **Validation:** Use the `show` subcommand first to verify that the combined queries don't produce a syntax error before exporting to a file.

---
