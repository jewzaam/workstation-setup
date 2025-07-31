# VM Remote Access Setup Guide

## Problem
- VM running under user session libvirt (`qemu:///session`) with QEMU user networking
- Need graphical access to the VM from remote computer

## Solution
Use SSH tunneling to access VM's SPICE interface for graphical remote access.

## Prerequisites
- VM created and running under user session libvirt
- libvirtd service running on host
- `remote-viewer` installed on your local computer (`sudo dnf install virt-viewer`)

## Environment Variables
Set these on your local computer before following the guide:
```bash
export HOST_IP="192.168.1.100"        # Your VM host IP
export HOST_USER="jewzaam"             # Username on VM host
export VM_NAME="my-vm"                 # Your VM name
```

## Setup (Do Once)

### Before You Start
1. **Find your VM host IP (on the VM host):**
   ```bash
   ip route get 1.1.1.1 | head -1 | awk '{print $7}'
   # Or: hostname -I
   ```

2. **Ensure libvirtd is running (on the VM host):**
   ```bash
   sudo systemctl start libvirtd
   sudo systemctl enable libvirtd
   ```

3. **Start your VM (on the VM host):**
   ```bash
   virsh -c qemu:///session list --all
   virsh -c qemu:///session start $VM_NAME
   ```

### Step 1: Set up SSH Key Authentication
```bash
# On your local computer
ssh-keygen -t ed25519 -f ~/.ssh/id_o7000x1 -C "vm-access-o7000x1"
ssh-copy-id -i ~/.ssh/id_o7000x1.pub $HOST_USER@$HOST_IP
```

### Step 2: Configure SSH on Local Computer
Add to your local `~/.ssh/config` (substitute the actual values):
```
Host vm-host
    HostName 192.168.1.100  # Replace with $HOST_IP
    User jewzaam            # Replace with $HOST_USER
    IdentityFile ~/.ssh/id_o7000x1
    LocalForward 5901 localhost:5901
```

Or generate it automatically:
```bash
cat >> ~/.ssh/config << EOF
Host vm-host
    HostName $HOST_IP
    User $HOST_USER
    IdentityFile ~/.ssh/id_o7000x1
    LocalForward 5901 localhost:5901
EOF
```

### Step 3: Create Convenience Script
Create `connect-vm-spice.sh`:
```bash
#!/bin/bash
echo "Starting SSH tunnel..."
ssh -f -N vm-host
sleep 2
echo "Launching SPICE viewer..."
remote-viewer spice://localhost:5901
echo "Closing tunnel..."
pkill -f "ssh.*vm-host"
```

```bash
chmod +x connect-vm-spice.sh
```

## Daily Usage

### Graphical Access (SPICE)
```bash
./connect-vm-spice.sh
```

Or one-liner:
```bash
ssh -f -N vm-host && sleep 2 && remote-viewer spice://localhost:5901 && pkill -f "ssh.*vm-host"
```

### Manual Tunnel (if needed)
```bash
# Start tunnel (keep running)
ssh -f -N vm-host

# Use SPICE viewer
remote-viewer spice://localhost:5901

# Stop tunnel when done
pkill -f "ssh.*vm-host"
```

## VM Details
- **VM Name**: `$VM_NAME`
- **Network**: QEMU user networking (10.0.2.15)
- **SPICE**: Host port 5901 → VM port 5901

---

## Appendix

### A. Alternative SPICE Access Methods
If you prefer not to use SSH config:

**Direct tunnel method:**
```bash
ssh -L 5901:localhost:5901 $HOST_USER@$HOST_IP
# Then: remote-viewer spice://localhost:5901
```

### B. Alternative Graphical Access

**VNC (if available on port 5900):**
```bash
ssh -L 5900:localhost:5900 $HOST_USER@$HOST_IP
vncviewer localhost:0
```

**virt-manager:**
```bash
ssh -L 16509:localhost:16509 $HOST_USER@$HOST_IP
# Connect to: qemu+ssh://$HOST_USER@localhost:16509/session
```

### C. Troubleshooting

**Check if SPICE tunnel is working:**
```bash
ss -tlnp | grep :5901  # SPICE
```

**VM console access:**
```bash
virsh -c qemu:///session console $VM_NAME  # Ctrl+] to exit
```

**Check VM status:**
```bash
virsh -c qemu:///session list --all
```

### D. Notes
- SPICE provides excellent performance for graphical access
- User networking isolates VM from host network (this is expected)
- For production, consider bridged networking instead 