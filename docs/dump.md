## Introduction to Dump Command

The `dump` utility is the core engine for high-performance data retrieval within Open Report. It is designed to bridge the gap between complex Oracle environments and modern data formats, supporting everything from simple SQL strings to encrypted batch compositions.

### The Execution Lifecycle

To ensure maximum security and data integrity, every `dump` command follows a strict internal sequence:

1. **Identity Resolution:** The CLI locates your server alias within the secure configuration.
2. **Credential Decryption:** The database password is securely retrieved from the OS Keychain.
3. **Query Composition:** SQL strings, local files, or encrypted folders are merged into an execution plan.
4. **Parameter Injection:** Dynamic variables and "Smart Mappings" are bound to the SQL context.
5. **Streaming Export:** Data is processed and streamed into your chosen format (CSV, JSON, etc.).

### Global Basic Options

These flags are the foundation of every extraction task.

| Flag            | Shorthand | Description                                                 |
| --------------- | --------- | ----------------------------------------------------------- |
| `--conn`        | `-c`      | The server alias (defined in `servers add-oracle`).         |
| `--query`       | `-q`      | A raw SQL string to execute directly.                       |
| `--query-file`  | `-f`      | Path to a local `.sql` file containing your query.          |
| `--param`       | `-p`      | Variables passed in `key=value` format.                     |
| `--file-name`   |           | Custom path or name for the generated export.               |
| `--append-file` |           | Appends results to an existing file instead of overwriting. |

> [!TIP]
> Use the `--help` flag at any level (e.g., `open_report dump delimited --help`) to view advanced tuning options for specific formats.

---

## Output Subcommands

The `dump` command must be paired with an output subcommand. This determines how the CLI fetches, formats, and presents your data.

#### **`delimited` (CSV/TSV)**

The industry standard for data analysts and spreadsheet integration.

- **Example:** `open_report dump -c PROD -q "SELECT * FROM DUAL" delimited --delimiter ","`
- **Feature:** Use `--no-show-header` to generate "clean" data files, perfect for appending to existing logs.

#### **`json`**

Generates structured, machine-readable JSON arrays for web services or modern NoSQL databases.

- **Example:** `open_report dump -c PROD -f ./report.sql json --indentation 2`

#### **`fixed-width`**

Required for legacy banking or enterprise system integrations that demand specific character alignments.

- **Options:** Define column widths with `--widths 10,20,5` and use `--right-align-numeric` for financial formatting.

#### **`show`**

A high-speed "Preview Mode." It renders your query results as a clean, formatted table directly in your terminal without writing a file to disk.

- **Example:** `open_report dump -c PROD -q "SELECT * FROM EMPLOYEES" show`

---

## Output Directory (Workspace Management)

Open Report eliminates the need to manage random file paths by maintaining a global **Workspace**. This is the "home base" where all your reports land by default.

### `output-path` | Inspecting the Workspace

Verify where your automated systems are currently writing data.

```bash
open_report dump output-path
# Output: ℹ️ Info: Default output directory: C:/Users/Admin/Reports

```

### `set-output-dir` | Updating the Workspace

Relocate your reporting hub to a shared network drive or a dedicated server volume.

```bash
open_report dump set-output-dir "D:/Enterprise/Data/Reports"
# Output: ✅ Success: Default output directory updated.

```

---

## Output File Management

Open Report uses a **Hierarchical Path Engine** to determine exactly where a file should be saved. This gives you the flexibility of global defaults with the power of specific overrides.

### The Resolution Hierarchy

1. **Absolute Override:** If you provide a full path (e.g., `C:/Exports/data.csv`), the Workspace is ignored.
2. **Relative Anchor:** If you provide a partial path (e.g., `daily/report.csv`), it is saved inside your Workspace.
3. **Automated Naming:** If no file name is provided, the CLI generates a timestamped file inside the Workspace.

### Usage Scenarios

| Scenario          | Command Example                               | Resulting Path (Workspace: `/app/data`) |
| ----------------- | --------------------------------------------- | --------------------------------------- |
| **Auto-Generate** | `... delimited`                               | `/app/data/dump_PROD_20260210_0800.csv` |
| **Simple Name**   | `... --file-name "audit.csv" delimited`       | `/app/data/audit.csv`                   |
| **Sub-folder**    | `... --file-name "finance/jan.csv" delimited` | `/app/data/finance/jan.csv`             |
| **Absolute**      | `... --file-name "D:/log.csv" delimited`      | `D:/log.csv`                            |

### Operational Best Practices

> [!IMPORTANT]
> **Deep-Path Creation:** Open Report is "Path Aware." If you specify a file in a folder that doesn't exist (e.g., `2026/Q1/Sales.csv`), the CLI will recursively create the entire folder structure for you automatically.

- **UNC Paths:** For Windows environments, you can point your workspace directly to a network share: `open_report dump set-output-dir "\\FILE-SERVER\Public\Reports"`.
- **Automation:** When running in scripts, rely on the **Auto-Generate** feature to prevent file name collisions during high-frequency reporting.

---

Here is the refactored **Section 5: Using Parameters**, designed to match the professional flow of the previous sections.

---

## Using Parameters

Open Report supports **Bind Variables**, allowing you to create reusable SQL templates without hardcoding values. By using parameters, you improve security (preventing SQL injection) and allow the same query file to be used across different contexts or dates.

### Using Placeholders in SQL

In your SQL strings or `.sql` files, define parameters using the colon (`:`) prefix followed by a variable name.

**Example Query (`sales_report.sql`):**

```sql
SELECT transaction_id, amount, status
FROM pms_transactions
WHERE resort = :p_resort and transaction_date = :p_date
```

### Passing Parameters in the CLI

You can satisfy these placeholders using the `-p` or `--param` flags. Open Report allows you to pass an unlimited number of parameters in a single command.

**Syntax:**

```bash
open_report dump -c PROD -f sales_report.sql -p p_resort=DEMO -p p_date=2026-01-01 delimited

```

---

### Handling Multiple Parameters

Each parameter requires its own flag. This explicit mapping ensures that complex queries remain readable and easy to debug.

```bash
open_report dump -c PROD -q "SELECT * FROM users WHERE role = :r AND dept = :d" \
  -p r=ADMIN \
  -p d=FINANCE \
  show

```

### When to Use Quoted Strings

The CLI intelligently parses your input, but there are specific rules for handling spaces and special characters:

- **Simple Values:** If your value has no spaces (e.g., `p_resort=DEMO`), quotes are optional.
- **Values with Spaces:** If the value contains spaces, you **must** wrap the `key=value` pair or the value itself in quotes.
- **Complex Strings:** For values containing symbols like `&`, `|`, or `;`, quoting is required to prevent the shell from interpreting them.

**Correct Usage:**

```bash
# Correct: Multi-word strings
-p p_name="John Doe"

# Correct: Wrapping the entire pair
"-p p_status=IN HOUSE"

# Incorrect: This will fail as 'House' will be treated as a new command
-p p_status=In House

```

### Parameter Best Practices

> [!TIP]
> **Case Sensitivity:** While SQL keywords are usually case-insensitive, the **values** you pass (like `'DEMO'` vs `'demo'`) often depend on your database settings. Always match the case stored in your tables.

- **Standard Naming:** Use a consistent prefix for your parameters (like `p_`) to distinguish them from standard SQL columns.
- **Dry Runs:** Use the `show` command to verify your parameters are fetching the correct data before exporting a 100MB CSV file.

---

Here is the refactored documentation for **Sections 6 through 8**. I have optimized the flow to transition logically from setting up the session to automating variable resolution.

---

## Database Initialization

Open Report includes native, deep integration for **Oracle Hospitality (Opera PMS)** environments. This ensures that any query requiring an active application session (App Context) can be executed without writing custom PL/SQL wrapper scripts.

### The Initialization Workflow

When the `--initialize-db` flag is active, the CLI executes the necessary session handshakes (typically `pms_p.initialize`) before your main query runs.

- **Secure Prompting:** If credentials (`--username`, `--password`, or `--resort`) are omitted, the CLI will pause and prompt for them securely.
- **Encrypted Input:** Passwords entered during interactive prompts are never masked with asterisks and are never stored in your terminal history.

**Command Example:**

```bash
open_report dump -c OPERA_PROD \
  -q "SELECT * FROM resv_general_view where resort = pms_p.resort" \
  --initialize-db -u MYUSER -r HOTEL01 \
  delimited

```

> [!WARNING]
> **Avoid Plaintext Passwords:** Whenever possible, avoid typing your password directly in the command. If you skip the `--password` flag, the CLI will provide a secure hidden input prompt.

> [!TIP]
> **Use Key as Passwords** use the `open_report encrypt password` command to get a key read more [here](encyption.md#secure-credential-injection).

---

## Smart Parameter Mapping

To reduce command-line clutter, Open Report features an **Intelligent Mapping System**. This allows you to define a value once and have it satisfy both your SQL placeholders and your session initialization requirements.

### Logic Synchronization

When `--initialize-db` is used, the CLI performs a "pre-flight" check on your parameters (`-p`). If it finds keys named `resort`, `username`, or `password`, it automatically satisfies the session requirements using those values.

#### **Redundant (Traditional) Syntax:**

```bash
# Don't do this - the 'DEMO' resort is repeated twice!
open_report dump -c PROD -p resort="DEMO" --resort "DEMO" --initialize-db

```

#### **Smart Resolved Syntax:**

```bash
# Enterprise Grade - Define it once in the parameters
open_report dump -c PROD -p resort="DEMO" -p username="SUPERVISOR" --initialize-db show

```

### Resolution Priority

The CLI uses a strict hierarchy to resolve session variables:

1. **Explicit Flags:** Direct flags like `-r` or `-u` always take the highest priority.
2. **Smart Parameters:** If flags are missing, the CLI scans the `-p` list for matching keys.
3. **Secure Prompt:** If the value is still missing, the CLI triggers an interactive prompt.

---

## Dynamic Parameter Resolution

Open Report supports **Dynamic Expression Parsing**. This allows parameter values to be resolved via database function calls _before_ the main query executes, enabling truly "set-and-forget" automation.

### The `@[]` Expression Syntax

By wrapping a value in `@[...]`, you instruct the CLI to execute that expression against the database first. The resulting value is then captured and injected into your main SQL statement.

#### **Example: Dynamic Business Date**

In PMS environments, reporting usually depends on the current "Business Date" rather than the calendar date. You can fetch this dynamically:

```bash
open_report dump -c PROD \
  -q "SELECT * FROM RESV_HISTORY WHERE resort = :resort AND arrival = :p_date" \
  -p resort="DEMO" \
  -p p_date="@[to_char(pms_p.business_date, 'YYYY-MM-DD')]" \
  --initialize-db show

```

**Advanced Calculations:**
You can also perform logic inside the brackets, such as fetching data for "Tomorrow":
`-p p_date="@[to_char(pms_p.business_date + 1, 'YYYY-MM-DD')]"`

### Resolution Lifecycle

1. **Context Init:** The CLI initializes the session so the database can access packages like `pms_p`.
2. **Expression Execution:** The CLI runs `SELECT [your_expression] FROM DUAL`.
3. **Result Capture:** The result is stored as a temporary string.
4. **Final Execution:** The main query is executed with the resolved dynamic value.

---

### Parameter Parsing Rules

| Format      | Syntax Example             | Use Case                                     |
| ----------- | -------------------------- | -------------------------------------------- |
| **Static**  | `-p resort="SAIV"`         | Known constants and IDs.                     |
| **Dynamic** | `-p d="@[trunc(sysdate)]"` | Dates, counters, or system variables.        |
| **Quoted**  | `-p msg="In House"`        | Values containing spaces or special symbols. |

> [!TIP]
> **Performance Tip:** Dynamic parameters require a tiny extra "round-trip" to the database. For complex automation, ensure the functions you use in `@[...]` are fast and optimized for performance.

> [!NOTE]
> **Dynamic Flexibility:** By defining placeholders inside your query (e.g., `:p_date`) rather than hardcoding logic, you gain the ability to switch between Static Values (manual dates) and Dynamic Resolution (system dates) directly from the command line without modifying the SQL file.

---

Here is the refactored documentation for **Sections 9 and 10** (originally 8-9 in your draft). I have updated the headings to match your new 11-step master list while maintaining the professional phrasing and layout.

---

## Session Lifecycle Hooks (Before/After)

To support complex reporting workflows, Open Report allows you to execute **Hooks**—SQL statements that run immediately before data extraction begins and immediately after it completes. This is essential for managing temporary database states without manual intervention.

### Automatic PL/SQL Wrapping

To keep your commands clean, the CLI is "Smart." You do not need to include `BEGIN` and `END;` keywords. Open Report automatically wraps your statements in an anonymous PL/SQL block, ensuring they execute correctly within the Oracle session.

**Key Use Cases:**

- **Initialization:** Populating Global Temporary Tables (GTTs) or setting session-specific variables.
- **Audit Logging:** Inserting records into an audit table to track the start of a report.
- **Cleanup:** Truncating temp tables or clearing session flags after the data is fetched.

---

### Implementation Example

In this scenario, we populate a temporary table using a parameter, run the report, and then clear the data.

```bash
open_report dump -c PROD_DB \
  --before-statement "pms_p.populate_temp_report_data(:resort)" \
  -q "SELECT * FROM temp_report_results" \
  -p resort="SAIV" \
  --after-statement "pms_p.clear_temp_data" \
  delimited

```

### Execution Logic

1. **Before Statement:** Executed as `BEGIN [your_statement]; END;`. If this fails, the process halts to prevent incorrect reporting.
2. **Main Query:** The primary data fetch is executed and streamed to your file.
3. **After Statement:** Executed as `BEGIN [your_statement]; END;`. This runs even if the main query fails (unless the connection is lost), ensuring your environment is always left clean.

---

## Batch Queries (Query Folders)

Open Report provides a streamlined way to execute multiple SQL scripts as a single, unified dataset. This "Union Orchestrator" is ideal for merging data split across different tables (e.g., History and Forecast) into one cohesive export.

### How it Works

When you use the `--query-folder` flag, the CLI performs the following steps:

1. **Discovery:** Scans the designated folder for files matching your extension (default: `.sql`).
2. **Merging:** Reads and concatenates all discovered files into one large execution string, separated by newlines.
3. **Unified Execution:** Sends the combined script to the Oracle engine as a single block.

> [!IMPORTANT]
> **Column Mapping:** Since the scripts are merged, if your queries are intended to form a single dataset, the number of columns and their data types **must match exactly** across all files in the folder.

---

### Enterprise Example: History & Future Union

Imagine a folder named `inventory_stats` containing `01_history.sql` and `02_forecast.sql`.

**Command:**

```bash
open_report dump -c PROD --query-folder "inventory_stats" delimited

```

**Resolution Logic:**
The CLI finds the folder, joins the scripts based on alphabetical order, and produces a single file containing both historical and future records.

### Filter and Extension Options

| Flag              | Description                                        | Example                       |
| ----------------- | -------------------------------------------------- | ----------------------------- |
| `--query-folder`  | The directory containing your SQL scripts.         | `--query-folder "sales"`      |
| `--extensions`    | The file type to look for (Default: `sql`).        | `--extensions "txt"`          |
| `--folder-filter` | A glob pattern to filter filenames (Default: `*`). | `--folder-filter "finance_*"` |

**Example (Filtered Batch):**

```bash
# Only merge files starting with 'finance_'
open_report dump -c PROD --query-folder "reports" --folder-filter "finance_*" delimited

```

### Best Practices for Batch Queries

- **Sequential Naming:** Use numeric prefixes (e.g., `01_main.sql`, `02_extra.sql`) to control the exact order of the data union.
- **Workspace Anchoring:** Keep your SQL templates inside your `default_output_dir` to use short, relative paths.
- **Validation:** Use the `show` subcommand first to verify that the combined query is syntactically correct before exporting a large file.

---

## Z SQL Queries (.zsql)

The `.zsql` format is a proprietary, encrypted "vault" for your SQL business logic. It allows you to package sensitive database queries so they can be executed by end-users or automated tasks without ever exposing the underlying SQL code or table structures.

### Execution from Vault

Instead of passing a plaintext `.sql` file, you can pass a `.zsql` archive created via the [`encrypt query`](encyption.md#secure-query-archives-zsql) utility . The CLI handles the on-the-fly decryption in memory, ensuring the SQL is never written to disk in its raw form.

**Command Example:**

```bash
# Executing an encrypted query archive
open_report dump -c PROD -f "finance_logic.zsql" delimited

```

---

### Key Advantages for Enterprise

- **Logic Protection:** Prevents unauthorized viewing or tampering with proprietary reporting logic.
- **Streamlined Distribution:** Bundle multiple complex SQL files into a single, portable `.zsql` archive.
- **Enhanced Security:** If the archive was created with the `--protect` flag, the CLI will prompt for the archive-specific password before execution, providing a layer of multi-factor authorization.
- **Integrity Validation:** The engine ensures the file hasn't been corrupted or modified since its creation.

### Handling Protected Archives

When running a `.zsql` file that was encrypted with an extra password, the CLI will trigger a secure prompt:

```text
open_report dump -c PROD -f "secure_report.zsql" show
🔑 Enter password to unlock archive: [HIDDEN_INPUT]

```

---

### Operational Flow Comparison

| Feature            | Standard SQL (`.sql`) | Encrypted Vault (`.zsql`)  |
| ------------------ | --------------------- | -------------------------- |
| **Visibility**     | Plaintext / Readable  | Encrypted / Hidden         |
| **Tamper Proof**   | No                    | Yes (Signature Validation) |
| **Multi-file**     | Single file per `-f`  | Can bundle multiple files  |
| **Password Layer** | None                  | Optional (via `--protect`) |

> [!NOTE]
> **Dynamic Flexibility:** Even when using `.zsql` archives, you retain the ability to use **Parameters** and **Dynamic Resolution**. Placeholders defined inside the encrypted SQL (e.g., `:p_resort`) are still satisfy-able via the standard `-p` flag in your command.

---

\*Powered by **Xkyeron**\*
