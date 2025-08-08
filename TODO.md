The following is context from a Cursor session on optimizing search exclusions.  This appears to have made a positive change but it's not a complete solution for filesystem spikes.  We should incorporate this into the "cursor" role at some point.

---


I'll walk you through configuring Cursor's file watcher and search exclusions via CLI for automation with Ansible. Let me first check Cursor's configuration structure and then provide you with the CLI approach. Ran tool

```shell
find ~/.config -name "*cursor*" -type d 2>/dev/null
```

```shell
find ~ -name "*cursor*" -type d 2>/dev/null | head -10
```

```shell
ls -la ~/.config/Cursor/User/
```

```shell
find ~/.config/Cursor/User -name "settings.json" -o -name "*.json" | grep -E "(settings|keybindings)" | head -5
```

Ran tool Read file: /home/jewzaam/.config/Cursor/User/settings.json Perfect\! Now I'll walk you through Option 2 \- configuring Cursor's file watcher and search exclusions via CLI for automation.

## Option 2: Configure Cursor File Exclusions via CLI

### Understanding Cursor's Configuration

Cursor stores its settings in `~/.config/Cursor/User/settings.json`. This is a standard VS Code-style JSON configuration file that can be modified programmatically.

### CLI Method to Configure File Exclusions

Ran tool Here's the complete CLI approach:

### 1\. Create a Script to Update Cursor Settings

First, let's create a script that merges the performance settings into your existing Cursor configuration:

```shell
#!/bin/bash
# cursor-performance-config.sh

CURSOR_SETTINGS="$HOME/.config/Cursor/User/settings.json"
BACKUP_FILE="$HOME/.config/Cursor/User/settings.json.backup.$(date +%Y%m%d_%H%M%S)"

# Backup existing settings
cp "$CURSOR_SETTINGS" "$BACKUP_FILE"

# Create temporary file with the performance settings
cat > /tmp/cursor_performance_settings.json << 'EOF'
{
  "files.watcherExclude": {
    "**/__pycache__/**": true,
    "**/venv/**": true,
    "**/node_modules/**": true,
    "**/htmlcov/**": true,
    "**/*.pyc": true,
    "**/.pytest_cache/**": true,
    "**/coverage.xml": true,
    "**/.coverage": true,
    "**/dist/**": true,
    "**/build/**": true,
    "**/*.egg-info/**": true
  },
  "search.exclude": {
    "**/__pycache__": true,
    "**/venv": true,
    "**/node_modules": true,
    "**/htmlcov": true,
    "**/.pytest_cache": true,
    "**/dist": true,
    "**/build": true,
    "**/*.egg-info": true
  },
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true
  }
}
EOF

# Merge the settings using jq
jq -s '.[0] * .[1]' "$CURSOR_SETTINGS" /tmp/cursor_performance_settings.json > /tmp/merged_settings.json

# Replace the original settings file
mv /tmp/merged_settings.json "$CURSOR_SETTINGS"

# Clean up
rm /tmp/cursor_performance_settings.json

echo "Cursor settings updated. Backup saved to: $BACKUP_FILE"
echo "Restart Cursor for changes to take effect."
```

### 2\. One-liner CLI Command

For a simple one-liner approach using `jq`:

```shell
# Install jq if not present
sudo dnf install jq -y  # For Fedora
# or sudo apt install jq -y  # For Ubuntu/Debian

# Update Cursor settings with performance optimizations
jq '. + {
  "files.watcherExclude": {
    "**/__pycache__/**": true,
    "**/venv/**": true,
    "**/node_modules/**": true,
    "**/htmlcov/**": true,
    "**/*.pyc": true,
    "**/.pytest_cache/**": true,
    "**/coverage.xml": true,
    "**/.coverage": true,
    "**/dist/**": true,
    "**/build/**": true,
    "**/*.egg-info/**": true
  },
  "search.exclude": {
    "**/__pycache__": true,
    "**/venv": true,
    "**/node_modules": true,
    "**/htmlcov": true,
    "**/.pytest_cache": true,
    "**/dist": true,
    "**/build": true,
    "**/*.egg-info": true
  },
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true
  }
}' ~/.config/Cursor/User/settings.json > /tmp/new_settings.json && mv /tmp/new_settings.json ~/.config/Cursor/User/settings.json
```

### 3\. Ansible Playbook Example

Ran tool Here's a complete Ansible playbook to automate this:

```
---
- name: Configure Cursor for optimal performance
  hosts: localhost
  vars:
    cursor_config_dir: "{{ ansible_env.HOME }}/.config/Cursor/User"
    cursor_settings_file: "{{ cursor_config_dir }}/settings.json"
    
  tasks:
    - name: Ensure jq is installed
      package:
        name: jq
        state: present
      become: yes

    - name: Create Cursor config directory if it doesn't exist
      file:
        path: "{{ cursor_config_dir }}"
        state: directory
        mode: '0755'

    - name: Check if Cursor settings file exists
      stat:
        path: "{{ cursor_settings_file }}"
      register: settings_file

    - name: Create empty settings file if it doesn't exist
      copy:
        content: "{}"
        dest: "{{ cursor_settings_file }}"
        mode: '0644'
      when: not settings_file.stat.exists

    - name: Backup existing Cursor settings
      copy:
        src: "{{ cursor_settings_file }}"
        dest: "{{ cursor_settings_file }}.backup.{{ ansible_date_time.epoch }}"
        mode: '0644'

    - name: Create performance settings template
      copy:
        content: |
          {
            "files.watcherExclude": {
              "**/__pycache__/**": true,
              "**/venv/**": true,
              "**/node_modules/**": true,
              "**/htmlcov/**": true,
              "**/*.pyc": true,
              "**/.pytest_cache/**": true,
              "**/coverage.xml": true,
              "**/.coverage": true,
              "**/dist/**": true,
              "**/build/**": true,
              "**/*.egg-info/**": true
            },
            "search.exclude": {
              "**/__pycache__": true,
              "**/venv": true,
              "**/node_modules": true,
              "**/htmlcov": true,
              "**/.pytest_cache": true,
              "**/dist": true,
              "**/build": true,
              "**/*.egg-info": true
            },
            "files.exclude": {
              "**/__pycache__": true,
              "**/*.pyc": true
            }
          }
        dest: /tmp/cursor_performance_settings.json
        mode: '0644'

    - name: Merge performance settings with existing Cursor settings
      shell: |
        jq -s '.[0] * .[1]' "{{ cursor_settings_file }}" /tmp/cursor_performance_settings.json > /tmp/merged_settings.json
        mv /tmp/merged_settings.json "{{ cursor_settings_file }}"
      args:
        executable: /bin/bash

    - name: Clean up temporary files
      file:
        path: /tmp/cursor_performance_settings.json
        state: absent

    - name: Display completion message
      debug:
        msg: "Cursor performance settings applied. Please restart Cursor for changes to take effect."
```

### 4\. Quick Test of the Current Approach

Let me test this on your system:

```shell
# Test the jq approach on your current settings
jq '. + {
  "files.watcherExclude": {
    "**/__pycache__/**": true,
    "**/venv/**": true,
    "**/htmlcov/**": true,
    "**/*.pyc": true
  },
  "search.exclude": {
    "**/__pycache__": true,
    "**/venv": true,
    "**/htmlcov": true
  }
}' ~/.config/Cursor/User/settings.json
```

### 5\. Running the Solution

**Option A: Script approach**

1. Save the script as `cursor-performance-config.sh`  
2. Make it executable: `chmod +x cursor-performance-config.sh`  
3. Run it: `./cursor-performance-config.sh`

**Option B: Ansible approach**

1. Save the playbook as `cursor-performance.yml`  
2. Run: `ansible-playbook cursor-performance.yml`

**Option C: Direct CLI**

```shell
# Backup first
cp ~/.config/Cursor/User/settings.json ~/.config/Cursor/User/settings.json.backup

# Apply performance settings
jq '. + {"files.watcherExclude":{"**/__pycache__/**":true,"**/venv/**":true,"**/htmlcov/**":true,"**/*.pyc":true},"search.exclude":{"**/__pycache__":true,"**/venv":true,"**/htmlcov":true}}' ~/.config/Cursor/User/settings.json > /tmp/new_settings.json && mv /tmp/new_settings.json ~/.config/Cursor/User/settings.json
```

### Key Benefits of This Approach:

1. **Fully Automated**: Can be integrated into your Ansible infrastructure  
2. **Preserves Existing Settings**: Merges with your current configuration  
3. **Backup Creation**: Automatically backs up existing settings  
4. **Idempotent**: Safe to run multiple times  
5. **CLI-based**: No GUI interaction required

After applying these settings, Cursor will ignore these heavy directories when:

- Watching for file changes (reduces disk I/O)  
- Performing searches (faster search results)  
- Indexing files (reduces memory usage)

This should significantly reduce the disk activity that's causing your performance issues, especially when opening new chats or navigating the interface.  
