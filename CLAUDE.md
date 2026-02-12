# Claude Context: VM Workstation Setup Repository

> **⚠️ IMPORTANT: Keep this documentation current!** This file should be updated whenever changes are made to the repository structure, configuration, or functionality. It serves as the primary context for Claude Code working with this codebase.

## Repository Overview
This is an **Ansible-based automation repository** for setting up development workstations on Red Hat family distributions (Fedora, RHEL, CentOS). It's designed to be run locally on the target VM to configure development environments with optional remote access capabilities.

## Core Purpose
- **Automated VM configuration** using Ansible playbooks
- **Development environment setup** with packages, tools, and configurations
- **Optional remote access** via SSH and NoMachine
- **File sharing** via Samba
- **User experience optimization** for remote development

## Architecture & Flow

### 1. Configuration Management
- **`configure.py`**: Interactive Python script that discovers available Ansible roles and lets users select components
- **`config.yml`**: Generated configuration file (gitignored) containing boolean selections for each component
- **Dynamic discovery**: Scans `ansible/site.yml` to find available roles and automatically generates descriptions

### 2. Makefile Structure
The main `Makefile` includes modular makefiles:
- **`make/ansible.mk`**: Core Ansible operations (`run`, `run-debug`)
- **`make/config.mk`**: Configuration management (`configure`, `show-config`)
- **`make/samba.mk`**: Samba-specific operations (`samba-password`)
- **`make/env.mk`**: Environment setup (virtual environment, dependencies)
- **`make/lint.mk`**: Code quality checks (`lint-python`, `lint-ansible`, `lint-samba-template`, `lint-claude-settings`)

### 3. Ansible Structure
- **`ansible/site.yml`**: Main playbook that orchestrates all roles
- **`ansible/group_vars/all.yml`**: Centralized variables and configuration
- **`ansible/roles/`: Modular roles for different components

## Key Components & Roles

### Core Development Roles (Always Available)
1. **`packages`**: Installs essential development tools (Python, Go, Git, Vim, etc.)
2. **`files`**: Deploys user configuration files (.bashrc, .vimrc, .screenrc, etc.)
3. **`git`**: Configures Git with aliases, colors, and tools
4. **`system_config`**: Optimizes GNOME for remote access performance
5. **`cursor`**: Installs Cursor AI-powered code editor
   - **MCP Server Management**: Automatically installs and updates Model Context Protocol (MCP) servers
   - **Git-based Installation**: Clones MCP server repositories to `/opt/mcp-servers/` for durability
   - **Automatic Updates**: Pulls latest changes and reinstalls when role is run again
   - **Individual Reminders**: Each MCP server can have its own post-installation reminder message
   - **Configuration**: MCP servers defined in `ansible/group_vars/all.yml` with enable/disable control
6. **`claude_code`**: Installs Claude Code CLI and configures user environment
   - **Installation**: Downloads and installs Claude Code CLI via native installer
   - **Configuration Deployment**: Deploys `CLAUDE.md` (global instructions) and `settings.json` (user preferences)
   - **Settings Management**: Configures permissions, plugins, UI preferences, and custom status line
   - **Skills Deployment**: Installs custom Claude Code skills for enhanced workflows
   - **Cross-platform**: Uses Python-based status line that works on Windows/Linux/macOS

### Optional Remote Access Roles
7. **`ssh`**: Sets up SSH server for remote terminal access
8. **`nomachine`**: Installs NoMachine for graphical remote desktop
9. **`samba`**: Configures file sharing accessible from Windows/Linux/macOS
10. **`gnome_extensions`**: Installs and configures GNOME Shell extensions

## MCP Servers Configuration

The cursor role includes comprehensive MCP (Model Context Protocol) server management:

### Configuration Structure
MCP servers are configured in `ansible/group_vars/all.yml` under `mcp_servers_list`:
```yaml
mcp_servers_general:
  base_dir: "/opt/mcp-servers"  # Installation directory for all MCP servers
  reminder: "Restart Cursor to detect newly installed MCP servers. For updates, restart Cursor or restart MCP servers within Cursor."
mcp_servers_list:
  - name: "server-name"
    repo: "https://github.com/username/repo.git"
    branch: "main"  # Per-server branch configuration
    install_command: "make install-cursor"
    install_directory: ""  # Optional, defaults to cloned directory
    enabled: true
    reminder: "Post-installation reminder message"
```

### Installation Behavior
- **First Run**: Clones repository to `{{ mcp_servers_general.base_dir }}/{server-name}/` and runs install command
- **Subsequent Runs**: Pulls latest changes from configured branch and reinstalls
- **Git Validation**: Ensures repository integrity, correct remote URL, and configured branch per server
- **Failure Handling**: Fails fast on any git issues or installation errors

### Reminder System
- **Individual Reminders**: Each MCP server can have its own reminder message
- **Automatic Display**: Reminders shown when cursor role is enabled via `make configure --reminders`
- **User Guidance**: Provides specific post-installation steps for each server

### Durability & Isolation
- **Installation Location**: `{{ mcp_servers_general.base_dir }}` - outside user directories for durability
- **Virtual Environments**: Each server creates its own venv during installation
- **User Isolation**: Servers won't be accidentally modified during development work

## Claude Code Configuration

The claude_code role deploys comprehensive configuration to `~/.claude/`:

### Configuration Files Deployed
- **`CLAUDE.md`**: Global instructions and guidelines for Claude Code behavior
  - Located: `ansible/roles/claude_code/files/claude/CLAUDE.md`
  - Contains communication style, code standards, documentation requirements, review processes

- **`settings.json`**: User preferences and configuration
  - Located: `ansible/roles/claude_code/files/claude/settings.json`
  - Includes:
    - **Permissions**: Auto-approved commands and tools (Bash patterns, MCP tools)
    - **Default Mode**: `acceptEdits` for automatic edit acceptance
    - **Plugins**: Enabled skill plugins (jira@ai-helpers, git@ai-helpers)
    - **UI Settings**: `spinnerTipsEnabled: false` to disable spinner tips
    - **Status Line**: Python-based command showing model, token usage, context percentage, and agent name (cross-platform)

- **`skills/`**: Custom Claude Code skills directory
  - Deployed from: `ansible/roles/claude_code/files/claude/skills/`
  - Skills are user-defined commands for specialized workflows

### Deployment Behavior
- **Settings Merge**: Intelligently merges repo settings into global settings
  - Arrays are merged by union (e.g., permissions are combined)
  - Objects are deep merged recursively
  - Scalar value conflicts cause deployment to fail with clear error message
  - Global settings are never modified if conflicts are detected
- **Force Update**: Controlled by `claude_code_config_force_update` variable (default: false)
- **Backup**: Disabled (set `backup: false` to avoid cluttering home directory)
- **Idempotent**: Can run multiple times without issues

## How Everything Connects

### Configuration Flow
```
User runs 'make configure' 
    ↓
configure.py discovers roles from site.yml
    ↓
Interactive picker shows available components
    ↓
User selects components (creates config.yml)
    ↓
make run reads config.yml and generates ansible-playbook command with --tags
    ↓
Ansible executes only selected roles
```

### Make Target Dependencies
- **`make configure`** → `pip-install-dev` → Sets up Python environment
- **`make run`** → `collections` → Installs Ansible collections → Runs playbook with selected tags
- **`make run-config`** → Same as `run` but explicitly uses current config
- **`make samba-password`** → Direct Samba password management

### Ansible Execution Flow
1. **Pre-tasks**: OS family validation (Red Hat only)
2. **Role execution**: Only runs roles with matching tags from config.yml
3. **Post-execution**: Shows reminders for enabled components

## Key Files & Their Purposes

### Configuration Files
- **`config.yml`**: User selections (gitignored, generated by configure.py)
- **`ansible/group_vars/all.yml`**: Centralized variables, package lists, file definitions, MCP server configuration
- **`ansible/ansible.cfg`**: Ansible configuration
- **`ansible/roles/claude_code/files/claude/CLAUDE.md`**: Global Claude Code instructions (deployed to `~/.claude/`)
- **`ansible/roles/claude_code/files/claude/settings.json`**: Claude Code user preferences (deployed to `~/.claude/`)

### Scripts
- **`configure.py`**: Interactive configuration picker with InquirerPy, includes MCP server reminder display
- **`ansible/roles/*/tasks/main.yml`**: Role-specific automation tasks
- **`ansible/roles/*/templates/*.j2`**: Jinja2 templates for configuration files

### Make Targets
- **`configure`**: Interactive component selection
- **`show-config`**: Display current configuration
- **`run`**: Execute setup with current configuration
- **`run-debug`**: Execute with verbose debugging
- **`samba-password`**: Manage Samba user passwords
- **`lint`**: Run all code quality checks (Python, Ansible, Samba template, Claude settings)

## Dependencies & Requirements

### System Requirements
- Red Hat family distribution (Fedora, RHEL, CentOS)
- Python 3, Ansible, Git
- DNF package manager

### Python Dependencies
- **`InquirerPy`**: Interactive UI for configuration picker
- **`PyYAML`**: YAML configuration parsing
- **Virtual environment**: Managed via `make/env.mk`

### Ansible Collections
- **`ansible.posix`**: For firewalld operations
- **Collections installed locally** in `./collections/` directory

## Usage Patterns

### Typical Workflow
1. **Clone repository** on target VM
2. **Run `make configure`** to select components
3. **Run `make run`** to execute setup
4. **Optional**: Use `make samba-password` for file sharing

### Component Selection Examples
- **Development only**: packages, files, system_config, git
- **Remote access**: + ssh, nomachine
- **File sharing**: + samba
- **Full setup**: All components

### Tag-Based Execution
Ansible uses tags derived from role names:
- `packages`, `files`, `git`, `system-config`
- `ssh`, `nomachine`, `samba`, `gnome-extensions`
- `cursor`, `claude-code`

## Key Design Principles

1. **Idempotent**: Can run multiple times safely
2. **Modular**: Each role is independent and optional
3. **Configuration-driven**: User selects components interactively
4. **Local execution**: Designed to run on target VM
5. **Red Hat focused**: Optimized for Fedora/RHEL/CentOS
6. **User-centric**: Configures user environment, not system-wide

## Common Operations for LLMs

### Adding New Components
1. Create role in `ansible/roles/`
2. Add role to `ansible/site.yml` with appropriate tags
3. Add variables to `ansible/group_vars/all.yml`
4. Update `configure.py` descriptions if needed

### Adding New MCP Servers
1. Add server definition to `mcp_servers_list` in `ansible/group_vars/all.yml`
2. Include `name`, `repo`, `branch`, `install_command`, `enabled`, and optional `reminder`
3. Configure general settings in `mcp_servers_general` section (base_dir, reminder)
4. Server will be automatically installed/updated when cursor role runs
5. Reminders displayed via `make configure --reminders`

### Modifying Existing Components
1. Edit role tasks in `ansible/roles/*/tasks/main.yml`
2. Update variables in `ansible/group_vars/all.yml`
3. Modify templates in `ansible/roles/*/templates/`

### Configuration Changes
1. Edit `ansible/group_vars/all.yml` for global variables
2. Use `make configure` for interactive component selection
3. Run `make run` to apply changes

## Troubleshooting Notes

- **OS compatibility**: Only works on Red Hat family distributions
- **SELinux**: Samba role handles SELinux context setup
- **Firewall**: SSH and Samba roles automatically configure firewalld
- **GNOME extensions**: May require logout/login on Wayland
- **Samba passwords**: Separate from system passwords, managed via `make samba-password`
- **MCP server reminders**: Displayed when cursor role is enabled via `make configure --reminders`

## Quick Reference Commands

```bash
make configure          # Select components
make show-config       # Show current selection
make run               # Execute setup
make run-debug         # Execute with debugging
make samba-password    # Manage Samba passwords
make lint              # Run all code quality checks
make help              # Show all available targets
```

### MCP Server Management
```bash
make configure --reminders  # Show reminders for enabled components including MCP servers
# MCP servers are automatically installed/updated when cursor role is enabled
```

This repository provides a complete, automated solution for setting up development workstations with optional remote access capabilities, all managed through a clean Makefile interface and Ansible automation.