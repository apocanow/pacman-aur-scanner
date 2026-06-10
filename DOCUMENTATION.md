# 📚 Complete Documentation - Pacman AUR Scanner

## 📋 Table of Contents

1. [General Description](#general-description)
2. [Why Use This?](#why-use-this)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Features](#features)
7. [Troubleshooting](#troubleshooting)
8. [Frequently Asked Questions](#frequently-asked-questions)

---

## General Description

**Pacman AUR Scanner** is a project that automatically integrates **aur-scanner** with the **Pacman** package manager on Arch Linux-based systems (CachyOS, Arch Linux, etc.).

This project provides an installation script that:
- 🛡️ Automatically scans AUR packages for security issues
- 🔐 Prevents installation of malicious or suspicious packages
- 🚀 Creates a transparent wrapper for Pacman
- ⚙️ Integrates non-intrusively into your workflow

---

## Why Use This?

The **AUR (Arch User Repository)** is a community repository where anyone can share packages. While very useful, it also presents security risks:

- ⚠️ **Malicious code**: Some PKGBUILD scripts may contain malicious code
- 🔍 **Lack of centralized review**: No security guarantee
- 💻 **Unverified code execution**: Scripts run during installation

**aur-scanner** is a tool that analyzes AUR packages for suspicious patterns. This project automates that process to occur every time you install a package.

---

## Prerequisites

Before running the installation script, make sure you have:

- ✅ Arch Linux-based system (CachyOS, Arch Linux, Manjaro, etc.)
- ✅ Access to terminal with `sudo` permissions
- ✅ Internet connection
- ✅ One of these AUR helpers:
  - **paru** (recommended)
  - **yay**
  - If you don't have one, the script will install it automatically

### Check if you have an AUR helper

```bash
# Check for paru
command -v paru && echo "✅ paru installed"

# Check for yay
command -v yay && echo "✅ yay installed"
```

---

## Installation

### Step 1: Download the Script

```bash
# Option A: Clone the repository
git clone https://github.com/apocanow/pacman-aur-scanner.git
cd pacman-aur-scanner

# Option B: Download only the script
curl -O https://raw.githubusercontent.com/apocanow/pacman-aur-scanner/main/install-aur-scanner-protection.sh
```

### Step 2: Make Executable

```bash
chmod +x install-aur-scanner-protection.sh
```

### Step 3: Run the Script

```bash
./install-aur-scanner-protection.sh
```

The script will automatically perform the following steps:

1. **Detects** your AUR helper (paru/yay) or installs it
2. **Installs** aur-scanner-git from the AUR
3. **Creates** the wrapper `pacman-aur` in `/usr/local/bin/`
4. **Asks** if you want to create an alias for `pacman` (optional)
5. **Verifies** that everything works correctly

### Step 4: Configure Alias (Optional)

If you didn't answer "yes" during installation, you can manually add the alias:

```bash
echo "alias pacman='sudo pacman-aur'" >> ~/.bashrc
source ~/.bashrc
```

For **Zsh**:
```bash
echo "alias pacman='sudo pacman-aur'" >> ~/.zshrc
source ~/.zshrc
```

---

## Usage

### Option 1: With Alias Configured (Recommended)

If you configured the alias, use Pacman normally:

```bash
# Install a package (will be automatically scanned)
pacman -S package-name

# Update the system
pacman -Syu
```

### Option 2: Without Alias

Use the `pacman-aur` command directly:

```bash
# Install a package
sudo pacman-aur -S package-name

# Update the system
sudo pacman-aur -Syu
```

### Practical Examples

```bash
# Install a package from the official repository
pacman -S firefox

# Install a package from the AUR
pacman -S visual-studio-code-bin

# Install multiple packages at once
pacman -S git base-devel

# Update the entire system
pacman -Syu
```

---

## Features

### 🔍 Automatic Scanning

The wrapper automatically runs `aur-scanner` when you try to install AUR packages.

**Workflow:**

```
user → pacman -S package
         ↓
    wrapper detects -S
         ↓
  aur-scanner verifies package
         ↓
  Problems detected?
  ├─→ YES: Blocks installation ❌
  └─→ NO: Continues with pacman ✅
```

### 🛡️ Intelligent Protection

The script searches for security patterns:

- 🚨 Security issues detected
- 🔒 Malicious code identified
- 🔐 Suspicious cryptography libraries (CRYPTO)

### 📦 Repository Packages

Official Arch repository packages are automatically skipped (no scan needed).

### ⚡ Transparent

The wrapper is completely transparent:
- Maintains all Pacman options
- Doesn't change your workflow
- You can use any Pacman command normally

---

## Troubleshooting

### Problem: Script won't run

```bash
# Error: "Permission denied"
chmod +x install-aur-scanner-protection.sh
./install-aur-scanner-protection.sh
```

### Problem: paru or yay not found

The script will install `paru` automatically. If something fails:

```bash
# Install paru manually
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si
```

### Problem: aur-scanner won't install

```bash
# Install manually
paru -S aur-scanner-git

# Verify installation
aur-scan --version
```

### Problem: Alias doesn't work

```bash
# Check if it's in the file
cat ~/.bashrc | grep alias

# If not present, add it manually
echo "alias pacman='sudo pacman-aur'" >> ~/.bashrc

# Reload configuration
source ~/.bashrc

# Verify it works
alias | grep pacman
```

### Problem: Error message during installation

If `aur-scanner` rejects a package you trust:

```bash
# See the detailed analysis
aur-scan check package-name

# Install without the wrapper (be careful)
sudo pacman -S package-name
```

---

## Frequently Asked Questions

### Is it safe to use this script?

✅ Yes. The script is **open source** and you can review its contents before running it.

### What happens if scanning rejects a package?

The script shows the error from `aur-scanner`. You have two options:

1. **Trust the package**: Install it without the wrapper
   ```bash
   sudo pacman -S package-name
   ```

2. **Review the package**: Check the AUR page

### Can I uninstall this?

✅ Yes, easily:

```bash
# Remove the wrapper
sudo rm /usr/local/bin/pacman-aur

# Remove the alias (if you added it)
# Edit ~/.bashrc and remove the line: alias pacman='sudo pacman-aur'

# Uninstall aur-scanner (optional)
paru -R aur-scanner-git
```

### Does it work with Pacman GUI?

No. The wrapper only works in the terminal. GUI Pacman applications won't use the wrapper.

### Will it slow down my system?

Minimally. The scan takes a few seconds per package, but only runs during installation.

### Can I use this on other distributions?

No. This script is designed specifically for Arch Linux-based systems with Pacman.

### How do I update the wrapper?

Simply run the installation script again:

```bash
./install-aur-scanner-protection.sh
```

It will overwrite the previous wrapper.

---

## 📞 Support

If you encounter issues or have suggestions:

1. 📖 Review this documentation
2. 🔍 Check the [troubleshooting guide](#troubleshooting)
3. 🐛 Open an issue on GitHub
4. 📧 Contact the developer

---

**Last Updated**: June 2026  
**Version**: 1.0  
**License**: Open to community
