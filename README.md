# VM Workstation Setup

Automated VM configuration using Ansible. Sets up development environment with packages, user files, and system settings optimized for remote access. Now includes optional SSH and NoMachine installation with interactive configuration.

## Prerequisites

Install on the target VM before running:

```bash
# Fedora/RHEL/CentOS - Install required packages
sudo dnf install ansible git python3 python3-yaml

# Verify installation
ansible --version
ansible-lint --version
python3 --version
```

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/jewzaam/workstation-setup
cd workstation-setup
```

### 2. Configure Your Setup (Interactive)
```bash
# Run interactive configuration picker
make configure

# Or show current configuration
make show-config
```

### 3. Run Complete Setup
```bash
# Using Makefile (recommended)
make run

# Or run with current configuration
make run-config

# Or direct ansible command
cd ansible
ansible-playbook site.yml --ask-become-pass
```

## Configuration Options

### Interactive Configuration
The `make configure` command launches an interactive picker that lets you select which components to install:

- **packages** - Install development packages (Python, Go, Git, Cursor, etc.)
- **files** - Deploy configuration files (.bashrc, .vimrc, .screenrc, etc.)
- **system_config** - Configure GNOME for remote access performance
- **ssh** - Install and configure SSH server for remote access
- **nomachine** - Install NoMachine for graphical remote desktop access

### Manual Configuration
Edit `config.yml` to customize your setup:

```yaml
# Core components (always installed)
packages: true
files: true
system_config: true

# Optional components
ssh: false
nomachine: false
```

## Usage Examples

### Basic Development Setup
```bash
make configure  # Select packages, files, system_config
make run-config # Run with current configuration
```

### Home VM with Remote Access
```bash
make configure  # Select all components including SSH and NoMachine
make run-config # Run with current configuration
```

### Work VM (No Remote Access)
```bash
make configure  # Select only packages, files, system_config
make run-config # Run with current configuration
```

### Run With Configuration
```bash
make configure   # choose components
make run         # runs with current selections
```

### Run with Custom Tags
```bash
make run TAGS=packages,files,system-config
make run TAGS=ssh,nomachine
```

## What Gets Automated

### Core Components (Default)
- **Development**: python3, golang, git, vim, meld, tig
- **System**: screen, curl, wget  
- **Editor**: Cursor (AI-powered code editor)
- **Configuration**: .bashrc, .vimrc, .screenrc, git config
- **GNOME**: Optimized for remote access performance

### Optional Components

#### SSH Server (Optional)
- **Packages**: openssh-server, openssh-clients
- **Service**: Start and enable sshd
- **Firewall**: Add SSH service to firewall
- **Access**: Port 22 for remote SSH access

#### NoMachine (Optional)
- **Download**: Latest NoMachine RPM from official site
- **Install**: RPM installation with proper dependencies
- **Service**: nxserver service management
- **Access**: Port 4000 for graphical remote desktop

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
├── config.yml             # Configuration file (gitignored)
├── configure.py           # Interactive picker
└── ansible/               # Ansible playbook (static)
    ├── site.yml           # Main playbook
    ├── README.md          # Detailed Ansible docs
    └── roles/             # Organized by function
        ├── packages/      # Package installation
        ├── files/         # Configuration files
        ├── system-config/ # GNOME optimization
        ├── ssh/          # SSH server setup
        └── nomachine/    # NoMachine installation
```

## Makefile Targets

```bash
make help              # Show available targets
make configure         # Interactive configuration picker
make show-config       # Show current configuration
make run-config        # Run with current configuration
make lint              # Code quality checks
make check-deps        # Check system dependencies
make dry-run           # Preview changes
make run               # Complete VM setup (uses config)
make run               # Complete VM setup (uses config)
```

## Remote Access Options

### SSH Access (if enabled)
```bash
# From remote machine
ssh username@vm-ip-address
```

### NoMachine Access (if enabled)
```bash
# From remote machine
# Connect to: vm-ip-address:4000
# Or use nxclient application
```

### SPICE Access (for libvirt VMs)
See `VM-Management.md` for detailed SPICE tunneling setup.

## Requirements Reference

**Original automation requirements:**
- Idempotent execution
- Ansible-based automation  
- Runs locally on target VM
- Assumes repository is checked out
- **New**: Configuration-driven component selection via tags
- **New**: Optional SSH and NoMachine installation
- **New**: Static Ansible content with tag-based execution