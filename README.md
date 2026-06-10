# Pacman AUR Scanner 🛡️

> Automatic aur-scanner integration for Pacman. Scans AUR packages for malware and security vulnerabilities.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Shell](https://img.shields.io/badge/Language-Shell-green.svg)](https://www.gnu.org/software/bash/)
[![Platform: Arch Linux](https://img.shields.io/badge/Platform-Arch%20Linux-blue.svg)](https://www.archlinux.org/)

---

## 🎯 What is This?

A script that automates the installation and configuration of **aur-scanner** with Pacman, creating a transparent wrapper that:

- ✅ Automatically scans each AUR package before installing
- ✅ Blocks malicious or suspicious packages
- ✅ Maintains your normal workflow
- ✅ Integrates without changing the commands you already use

```
pacman -S aur-package
        ↓
   wrapper detects
        ↓
  aur-scanner analyzes
        ↓
   Is it safe? → Install / Block
```

---

## 🚀 Quick Installation

### 1️⃣ Download the Script

```bash
git clone https://github.com/apocanow/pacman-aur-scanner.git
cd pacman-aur-scanner
```

### 2️⃣ Make Executable

```bash
chmod +x install-aur-scanner-protection.sh
```

### 3️⃣ Run

```bash
./install-aur-scanner-protection.sh
```

The script will ask if you want an alias. **Answer "y"** for convenience.

### 4️⃣ Reload Configuration

```bash
source ~/.bashrc
```

---

## 💻 Usage

```bash
# Install packages with automatic scanning
pacman -S package-name

# Update the system
pacman -Syu

# Any Pacman command works normally
pacman -R package
pacman -Qi package
```

---

## 📋 What Does the Script Do?

1. **Detects** your AUR helper (paru/yay)
2. **Installs** aur-scanner-git from the AUR
3. **Creates** a wrapper in `/usr/local/bin/pacman-aur`
4. **Configures** an automatic alias (optional)
5. **Verifies** that everything works

---

## 🔐 Security Features

The wrapper automatically searches for:

- 🚨 **Security issues** identified by aur-scanner
- 🔒 **Malicious code** in PKGBUILD scripts
- 🔐 **Suspicious cryptographic patterns**
- ⚡ **Package integrity**

If it detects something, **it blocks installation** and shows the details.

---

## 📚 Documentation

- **[Complete Documentation](DOCUMENTATION.md)** - Detailed guide with examples
- **[Quick Start](QUICK_START.md)** - Installation in 5 minutes
- **[Architecture](ARCHITECTURE.md)** - Technical deep dive
- **[Troubleshooting](DOCUMENTATION.md#troubleshooting)** - FAQ and common errors

---

## 🛠️ Requirements

- ✅ **Arch Linux**-based system (CachyOS, Manjaro, etc.)
- ✅ Access to `sudo`
- ✅ Internet connection
- ✅ **paru** or **yay** (installed automatically if not present)

---

## ❓ Frequently Asked Questions

### Is it safe?
✅ Yes. Everything is open source. You can review the script before running it.

### What if it rejects a package?
You can review why it was rejected and if needed, install it without the wrapper:
```bash
sudo pacman -S package-name
```

### How do I uninstall it?
```bash
sudo rm /usr/local/bin/pacman-aur
# Edit ~/.bashrc and remove the alias if you added it
```

### Does it slow down the system?
Minimally. The scan takes seconds and only happens during installations.

---

## 🎨 Architecture

```
install-aur-scanner-protection.sh
    ├─ Detect AUR helper (paru/yay)
    ├─ Install aur-scanner-git
    ├─ Create wrapper: /usr/local/bin/pacman-aur
    │   ├─ Detect -S commands (install)
    │   ├─ Run aur-scan check
    │   ├─ Analyze results
    │   └─ Run pacman normally if safe
    └─ Configure alias (optional)
```

---

## 📝 Usage Example

```bash
$ pacman -S lolcat
🔍 Scanning lolcat with aur-scanner...
(package analysis...)
✅ Package lolcat: scan passed
✅ Verification completed. Continuing...
(normal Pacman installation)
```

---

## 📞 Support & Contributions

- 🐛 **Report bugs**: Open an [issue](https://github.com/apocanow/pacman-aur-scanner/issues)
- 💡 **Suggestions**: Discuss in [discussions](https://github.com/apocanow/pacman-aur-scanner/discussions)
- 🤝 **Contribute**: Pull requests are welcome

---

## 📄 License

This project is open-source and available for the community.

---

## 🙏 Credits

- Based on **aur-scanner**: Security analysis tool for AUR packages
- Inspired by Arch Linux security best practices

---

<div align="center">

**🛡️ Protect your system. Install Pacman AUR Scanner.**

[View Complete Documentation](DOCUMENTATION.md) • [Quick Start](QUICK_START.md) • [Architecture](ARCHITECTURE.md)

</div>
