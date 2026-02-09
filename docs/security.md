## Security & Architecture

Open Report is built on a **Zero-Knowledge** security model. This ensures that sensitive database credentials are never stored in plaintext and are inaccessible to unauthorized users or processes, even if the configuration files are compromised.

### Encryption Standard

The CLI utilizes industry-standard **PBKDF2-HMAC-SHA256** (Password-Based Key Derivation Function 2) to secure your data. This process involves:

- **Unique Salting:** Every installation generates a unique, cryptographically-strong salt, preventing rainbow table attacks.
- **Key Stretching:** High-iteration hashing makes brute-force attempts computationally expensive and impractical.

### Secure Credential Storage

Open Report leverages native OS-level security features to manage the **Master Password**:

- **Platform Integration:** On Windows, credentials are encapsulated within the **Windows Credential Manager**. On macOS and Linux, the tool integrates with the **System Keychain** or **Secret Service API**.
- **Hardware Encryption:** By using the OS Keychain, the Master Password benefits from hardware-backed security modules (such as TPM or Apple T2) where available.
- **Scoped Access:** Only the authenticated system user can unlock the keychain to provide the Master Password for query execution.

---

### Best Practices for Enterprise Security

> [!WARNING]
> **Loss of Master Password:** Because Open Report uses high-entropy encryption, the Master Password cannot be "recovered" if lost. We recommend storing a backup of your Master Password in a corporate-approved Vault.

---
