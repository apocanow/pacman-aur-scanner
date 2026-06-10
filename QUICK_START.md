# ⚡ Quick Start Guide - 5 Minutes

## Express Installation

```bash
# 1. Download
git clone https://github.com/apocanow/pacman-aur-scanner.git
cd pacman-aur-scanner

# 2. Permissions
chmod +x install-aur-scanner-protection.sh

# 3. Run (answer "y" when prompted for alias)
./install-aur-scanner-protection.sh

# 4. Reload configuration
source ~/.bashrc
```

## Done! Use Pacman Normally

```bash
# Install packages (with automatic scanning)
pacman -S package-name

# Update system
pacman -Syu
```

## If Something Goes Wrong

| Problem | Solution |
|---------|----------|
| "Permission denied" | `chmod +x install-aur-scanner-protection.sh` |
| Helper AUR not found | The script installs it automatically |
| Alias doesn't work | `source ~/.bashrc` |
| Want to uninstall | `sudo rm /usr/local/bin/pacman-aur` |

## Useful Commands

```bash
# See what aur-scanner analyzes
aur-scan check package-name

# Install without scanning (if necessary)
sudo pacman -S package-name

# Restore original alias (if deleted)
echo "alias pacman='sudo pacman-aur'" >> ~/.bashrc
```

---

📖 For more details, read [`DOCUMENTATION.md`](DOCUMENTATION.md)
