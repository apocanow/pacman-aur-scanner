# 🏗️ Technical Architecture - Pacman AUR Scanner

## General Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    User                                      │
│             pacman -S package-name                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │   Alias (optional)         │
        │ alias pacman=sudo pacman-aur
        └────────────┬───────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │  Wrapper: /usr/local/bin/pacman-aur│
        │                                     │
        │  1. Parse arguments               │
        │  2. Detect -S command (install)   │
        │  3. Extract package names         │
        └────────────┬──────────────────────┘
                     │
            ┌────────┴────────┐
            │ -S detected?    │
            └────────┬────────┘
                     │
         ┌───────────┴────────────┐
         │                        │
         ▼                        ▼
    YES: SCAN             NO: DIRECT TO PACMAN
         │                        │
         ├─→ For each pkg         │
         │   ├─ aur-scan check    │
         │   ├─ Analyze result    │
         │   └─ Is safe?          │
         │      ├─ YES: continue  │
         │      └─ NO: block      │
         │                        │
         └───────────┬────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  /usr/bin/pacman           │
        │  (normal installation)     │
        └────────────────────────────┘
```

---

## 📦 Components

### 1. Installation Script
**File**: `install-aur-scanner-protection.sh`

**Responsibilities**:
- Detect/install AUR helper (paru or yay)
- Install aur-scanner-git from AUR
- Create wrapper in `/usr/local/bin/pacman-aur`
- Configure optional alias

**Installation Flow**:
```
1. Start
   ├─ Detect paru/yay
   ├─ Install if missing
   ├─ Install aur-scanner-git
   ├─ Verify files
   ├─ Create wrapper
   ├─ Ask for alias
   ├─ Run test
   └─ Show summary
```

---

### 2. Wrapper (Middleware)
**Location**: `/usr/local/bin/pacman-aur`

**Function**: Intercept Pacman commands and apply scanning

**Pseudocode**:
```bash
FOR EACH argument in $@:
  IF argument == "-S":
    SET INSTALLING = true
  ELSE IF INSTALLING == true AND argument doesn't start with "-":
    ADD argument to PACKAGES

IF INSTALLING and PACKAGES has values:
  FOR EACH package in PACKAGES:
    OUTPUT = aur-scan check package
    
    IF package not in AUR:
      PRINT "Is official, skipping scan"
      CONTINUE
    
    IF detected:
      - "security issues"
      - "malicious"
      - "CRYPTO"
    THEN:
      PRINT error
      EXIT with code 1
    
    ELSE:
      PRINT "Package safe"

EXECUTE /usr/bin/pacman with all original arguments
```

---

### 3. Scanning Tool (External)
**Tool**: `aur-scanner` (aur-scanner-git)

**How it works**:
```
$ aur-scan check package-name

Possible result:
- "Not found: Package... not found in AUR" (official package)
- "security issues detected" (problems found)
- Clean output (package safe)
```

**Integration**:
- Wrapper executes: `aur-scan check $package`
- Captures STDOUT and STDERR
- Analyzes result with grep
- Decides whether to allow or block

---

## 🔄 Workflows

### Workflow 1: Clean Installation
```
User runs: pacman -S firefox

    Wrapper receives
         ↓
Detects -S and package
         ↓
Executes: aur-scan check firefox
         ↓
Result: "Not found... not found in AUR"
         ↓
Conclusion: Is official package
         ↓
Continues without scanning
         ↓
Executes: /usr/bin/pacman -S firefox
```

### Workflow 2: Safe AUR Package
```
User runs: pacman -S visual-studio-code-bin

    Wrapper receives
         ↓
Detects -S and package
         ↓
Executes: aur-scan check visual-studio-code-bin
         ↓
Result: Clean output
         ↓
Conclusion: Safe package
         ↓
Executes: /usr/bin/pacman -S visual-studio-code-bin
```

### Workflow 3: Suspicious AUR Package
```
User runs: pacman -S malicious-package

    Wrapper receives
         ↓
Detects -S and package
         ↓
Executes: aur-scan check malicious-package
         ↓
Result: "security issues detected"
         ↓
Conclusion: ❌ Package blocked
         ↓
Exit code 1
         ↓
Installation canceled
```

### Workflow 4: Non-Install Operation
```
User runs: pacman -Qi firefox

    Wrapper receives
         ↓
Detects: NO -S
         ↓
No scanning
         ↓
Executes: /usr/bin/pacman -Qi firefox
         ↓
Shows information
```

---

## 📋 Argument Parsing

The wrapper detects patterns:

```bash
# Detects -S:
pacman -S package1        # YES
pacman -Sy                # YES
pacman -Syu               # YES
pacman -S package1 package2  # YES (multiple)

# Doesn't detect:
pacman -R package         # NO (remove)
pacman -Q                 # NO (query)
pacman -Qi package        # NO (query info)
```

**Logic**:
```bash
INSTALLING=false
PACKAGES=""

FOR each arg:
  IF arg == "-S":
    INSTALLING = true
  ELSE IF INSTALLING and arg doesn't start with "-":
    Add arg to PACKAGES
```

---

## 🔐 Problem Detection

The wrapper searches for these patterns in aur-scan output:

| Pattern | Severity | Action |
|---------|----------|--------|
| `security issues detected` | CRITICAL | Block |
| `malicious` | CRITICAL | Block |
| `CRYPTO` | HIGH | Block |
| `Not found... in AUR` | INFORMATION | Skip scan |
| Clean output | SAFE | Allow |

---

## 📁 File Structure

```
pacman-aur-scanner/
├── README.md                              # Introduction
├── DOCUMENTATION.md                       # Complete docs
├── QUICK_START.md                        # Quick start
├── ARCHITECTURE.md                       # This file
├── install-aur-scanner-protection.sh     # Main script
└── esquema1.jpg                          # Visual diagram
```

---

## ⚙️ Permissions and Locations

| Component | Location | Permissions | User |
|-----------|----------|-------------|------|
| Installation script | `~/` | 755 | User |
| Wrapper | `/usr/local/bin/pacman-aur` | 755 | root |
| Alias | `~/.bashrc` or `~/.zshrc` | 644 | User |
| aur-scanner-git | `/usr/bin/aur-scan*` | 755 | root |

---

## 🔧 Variables and Configuration

### Wrapper Variables

```bash
INSTALLING=false     # Flag if -S detected
PACKAGES=""          # Stores package names
AUR_HELPER="paru"    # Detected helper
OUTPUT=""            # aur-scan output
```

### Script Configuration

```bash
set -e               # Exit on error
WRAPPER=...          # Wrapper contents
REPLY                # User response
```

---

## 🚨 Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Helper not found | Not installed | Script installs it |
| aur-scan missing | Not installed properly | Install manually |
| Permission denied | Insufficient permissions | Use sudo |
| Alias doesn't work | Not reloaded | `source ~/.bashrc` |

---

## 📊 Sequence Diagram

```
User        Bash/Shell      Wrapper         aur-scan        Pacman
   │               │              │               │               │
   ├─ pacman -S pkg ─────┐        │               │               │
   │                     │        │               │               │
   │                     ├───→ Receive args       │               │
   │                     │        │               │               │
   │                     ├───→ Parse -S           │               │
   │                     │        │               │               │
   │                     ├───→ Call aur-scan ──────────────┐    │
   │                     │        │               │          │    │
   │                     │        │    Return result        │    │
   │                     ├──← ←──────────────────┘          │    │
   │                     │        │               │          │    │
   │                     ├───→ Analyze           │          │    │
   │                     │        │               │          │    │
   │                     ├───→ Is safe?           │          │    │
   │                     │        │               │          │    │
   │                     ├──→ Execute pacman ─────────────────────────┐
   │                     │        │               │          │    │
   │                     ├──← Result ─────────────────────────────────┘
   │                     │        │               │          │    │
   │  ←─ Result ────────┤        │               │          │    │
   │                     │        │               │          │    │
```

---

## 🎯 Design Considerations

### ✅ Advantages of Current Design

1. **Non-intrusive**: The wrapper is an intermediate layer
2. **Transparent**: User sees no difference in UX
3. **Reversible**: Easy to uninstall
4. **Modular**: Doesn't modify original Pacman
5. **Scalable**: Easy to add more validations

### ⚠️ Known Limitations

1. **Doesn't work with GUIs**: Terminal only
2. **Alias only in current shell**: Requires source in new sessions
3. **No real-time detection**: Only during installation
4. **aur-scanner dependency**: If changes, requires update

---

## 🔮 Possible Future Improvements

1. Automatic aur-scanner updates
2. Scan result caching
3. Custom rule configuration
4. systemd hooks integration
5. Audit dashboard
6. Multiple shell support

---

## 📚 References

- **Pacman**: https://wiki.archlinux.org/title/Pacman
- **AUR**: https://aur.archlinux.org/
- **aur-scanner**: https://github.com/archlinux/aur-scanner
- **Bash**: https://www.gnu.org/software/bash/manual/

