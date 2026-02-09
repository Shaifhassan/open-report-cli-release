## Session & Cache Management

Open Report uses an internal state tracker to maintain a record of all files generated during your current work cycle. This "Session-Aware" design allows for seamless integration between the **Extraction (`dump`)** and **Delivery (`deliver`)** phases.

### Core Concept: The "Automatic Hand-off"

When you execute a `dump` command, the CLI doesn't just save the file to your disk—it "tracks" the absolute path of that file in a hidden session file (`last_session.json`).

This allows you to run multiple reports in a row and then, with a single `deliver` command, send **all** those generated files to an FTP server or Email address in one batch. The CLI "remembers" the files so you don't have to.

---

### Session Commands

Manage your staging area using the `session` subcommand group.

#### **`list`**

Displays all files currently being tracked in the active session.

- **Command:** `open_report session list`
- **Visibility:** Shows the absolute path and verifies if the file still exists on the disk (using ✅ or ❌ indicators).

#### **`remove`**

Manually removes a specific file from the session tracking without deleting the actual file from your computer.

- **Command:** `open_report session remove "C:/Reports/daily_sales.csv"`
- **Use Case:** If you generated five reports but only want to deliver four of them.

#### **`clear`**

Wipes the entire session cache.

- **Command:** `open_report session clear`
- **Best Practice:** Run this at the start of a new batch script to ensure you aren't accidentally delivering files from a previous run.

---

### Enterprise Advantages

- **Batch Processing Efficiency:** Instead of writing complex scripts to find and name files for upload, the CLI handles the inventory management automatically.
- **Decoupled Workflows:** You can separate your **Data Logic** (creating the files) from your **Transport Logic** (sending the files). This makes your automation scripts much cleaner and easier to maintain.
- **Error Resilience:** The `session list` command provides an audit trail. If a delivery fails, you can quickly see exactly which files were supposed to be sent and verify their existence.
- **Stateless Automation:** In CI/CD pipelines (like GitHub Actions), session tracking ensures that only the files generated in the _current_ runner's lifecycle are processed for delivery.

---

### Workflow Example

1. **Clear old state:** `open_report session clear`
2. **Generate Report 1:** `open_report dump -c DB1 -q "..." delimited` (Tracked ✅)
3. **Generate Report 2:** `open_report dump -c DB2 -q "..." json` (Tracked ✅)
4. **Review:** `open_report session list`
5. **Final Step:** `open_report deliver ftp ....` (Sends both files automatically)

---
