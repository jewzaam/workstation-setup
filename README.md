# VM Workstation Setup

Automated VM configuration using Ansible. Sets up development environment with packages, dotfiles, and system settings optimized for remote access.

## Prerequisites

Install on the target VM before running:

```bash
# Fedora/RHEL/CentOS - Install required packages
sudo dnf install ansible ansible-lint git

# Verify installation
ansible --version
ansible-lint --version
```

## Usage

### 1. Clone Repository
```bash
git clone https://github.com/jewzaam/workstation-setup
cd workstation-setup
```

### 2. Verify Prerequisites
```bash
# Check if system is ready
make check-deps
```

### 3. Run Complete Setup
```bash
# Using Makefile (recommended)
make run

# Or direct ansible command
cd ansible
ansible-playbook site.yml --ask-become-pass
```

### 4. Run Specific Components (Optional)
```bash
# Using Makefile
make run-packages      # Packages only
make run-dotfiles      # Configuration files only
make run-system-config # System settings only

# Or direct ansible commands
cd ansible
ansible-playbook site.yml --tags packages --ask-become-pass
ansible-playbook site.yml --tags dotfiles --ask-become-pass
ansible-playbook site.yml --tags system-config --ask-become-pass
```

## What Gets Automated

### Packages Installed
- **Development**: python3, golang, git, vim, meld, tig
- **System**: screen, curl, wget  
- **Editor**: Cursor (AI-powered code editor)

### Configuration Files Deployed
- `.bashrc` - Bash environment with Go paths
- `.bashrc_prompt` - Custom colored prompt
- `.vimrc` - Vim settings for development
- `.screenrc` - GNU Screen configuration
- `.gitconfig` - Git configuration with meld

### System Settings
- **Screen lock disabled** - Prevents lockout during remote sessions
- **Idle/suspend disabled** - Keeps VM responsive
- **Power management optimized** - For remote access

## Manual Steps After Playbook

Install GNOME extensions via browser:
- [Dash in Panel](https://extensions.gnome.org/extension/7855/dash-in-panel/)
- [Notifications Alert](https://extensions.gnome.org/extension/258/notifications-alert-on-user-menu/)  
- [System Monitor Next](https://extensions.gnome.org/extension/3010/system-monitor-next/)

Configure System Monitor Next:
- CPU: Show Text = false, Graph Width = 50
- Memory: Show Text = false, Graph Width = 50
- Net: Show Text = false, Graph Width = 50

## Repository Structure

```
workstation-setup/
├── README.md              # This file
├── VM-Management.md       # Remote access guide
├── Makefile               # Build automation
└── ansible/               # Ansible playbook
    ├── site.yml           # Main playbook
    ├── README.md          # Detailed Ansible docs
    └── roles/             # Organized by function
```

## Makefile Targets

```bash
make help              # Show available targets
make lint              # Code quality checks
make check-deps        # Check system dependencies
make dry-run           # Preview changes
make run               # Complete VM setup
make run-packages      # Install packages only
make run-dotfiles      # Deploy config files only
make run-system-config # Apply system settings only
```

## Requirements Reference

**Original automation requirements:**
- Idempotent execution
- Ansible-based automation  
- Runs locally on target VM
- Assumes repository is checked out