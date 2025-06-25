# Bash Programs Collection

A collection of useful bash scripts for system administration and automation.

---

## `create_vm` - KVM Debian VM Creation Script

A comprehensive bash script for creating Debian virtual machines on KVM/libvirt hypervisors with cloud-init configuration.

### Features

- **Automated VM Creation**: Creates Debian 11 or 12 VMs with minimal user input
- **Cloud-init Integration**: Automatic system configuration and user setup
- **Flexible SSH Key Management**: Support for local keys, GitHub, GitLab, or custom key files
- **Network Configuration**: DHCP or static IP configuration
- **Prerequisites Checking**: Validates system requirements before execution
- **Comprehensive Error Handling**: Clear error messages and validation
- **Customizable Resources**: Configurable RAM, CPU, disk size, and storage location
- **Security Focused**: SSH key-only authentication, password login disabled
- **Multi-Distribution Support**: Works on both Debian and Fedora hosts

### Prerequisites

The script automatically detects your Linux distribution and checks for required components with distribution-specific package names.

#### Supported Distributions
- **Debian/Ubuntu**: Uses `apt` package manager
- **Fedora/RHEL/CentOS/Rocky/AlmaLinux**: Uses `dnf` package manager

#### Required Packages

**Debian/Ubuntu:**
- `libvirt-clients` (virsh command)
- `virtinst` (virt-install command)
- `qemu-utils` (qemu-img command)
- `genisoimage` (ISO creation)
- `curl` (downloading images and SSH keys)
- `iproute2` (ip command)

**Fedora/RHEL/CentOS/Rocky/AlmaLinux:**
- `libvirt-client` (virsh command)
- `virt-install` (virt-install command)
- `qemu-img` (qemu-img command)
- `genisoimage` (ISO creation)
- `curl` (downloading images and SSH keys)
- `iproute` (ip command)

#### Required Services
- Libvirt services must be running:
  - **Modern libvirt** (Fedora 35+): `virtqemud`, `virtnetworkd` (modular daemons)
  - **Legacy libvirt** (older systems): `libvirtd` (monolithic daemon)
  - The script automatically detects which services are available and working

#### User Permissions
- User must be in `libvirt` group or run as root

#### System Requirements
- KVM support enabled (`/dev/kvm` must exist)
- Sufficient disk space for VM images
- Network interface specified must exist

### Installation

1. Check prerequisites:
```bash
./create_vm --check-only
```

2. Install missing components if needed:

**For Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install libvirt-clients virtinst qemu-utils genisoimage curl

# Add user to libvirt group
sudo usermod -a -G libvirt $USER
# Log out and back in for group changes to take effect

# Start libvirt service
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

**For Fedora/RHEL/CentOS/Rocky/AlmaLinux:**
```bash
sudo dnf install libvirt-client virt-install qemu-img genisoimage curl

# Add user to libvirt group
sudo usermod -a -G libvirt $USER
# Log out and back in for group changes to take effect

# Start libvirt service
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

### Usage

#### Basic Syntax
```bash
./create_vm <vm-name> <disk-size> <network-interface> [OPTIONS]
```

#### Required Parameters
- `vm-name`: Name of the virtual machine
- `disk-size`: Size of the VM disk (e.g., 20G, 1024M)
- `network-interface`: Network interface name (e.g., virbr0, br0)

#### Optional Parameters
- `--ram <size>`: RAM size in MB (default: 2048)
- `--cpus <count>`: Number of CPUs (default: 2)
- `--user <username>`: VM username (default: current user)
- `--ssh-keys-github <user>`: Pull SSH keys from GitHub
- `--ssh-keys-gitlab <user>`: Pull SSH keys from GitLab
- `--ssh-key-file <path>`: Use custom SSH key file
- `--static-ip <ip/cidr>`: Static IP configuration (e.g., 192.168.1.100/24)
- `--gateway <ip>`: Gateway IP (required with static IP)
- `--dns <ip>`: DNS server (default: 8.8.8.8)
- `--storage-path <path>`: VM storage directory (default: /var/lib/libvirt/images/)
- `--debian-version <ver>`: Debian version - 11 or 12 (default: 12)
- `--autostart`: Enable VM autostart
- `--console`: Setup serial console access
- `--user-data <file>`: Custom cloud-init user-data file
- `--check-only`: Only check prerequisites and exit
- `--help`: Show help message

#### Examples

**Basic VM Creation:**
```bash
./create_vm myvm 20G virbr0
```

**Advanced VM with Custom Configuration:**
```bash
./create_vm webserver 50G br0 \
  --ram 4096 \
  --cpus 4 \
  --user admin \
  --ssh-keys-github myusername \
  --autostart \
  --console
```

**VM with Static IP:**
```bash
./create_vm database 100G virbr0 \
  --static-ip 192.168.1.100/24 \
  --gateway 192.168.1.1 \
  --dns 192.168.1.1 \
  --ram 8192 \
  --cpus 4
```

**VM with Custom Storage and GitLab Keys:**
```bash
./create_vm development 30G virbr0 \
  --storage-path /home/vms \
  --ssh-keys-gitlab myusername \
  --debian-version 11
```

**VM with Custom Cloud-Init Configuration:**
```bash
./create_vm custom 25G virbr0 \
  --user-data /path/to/custom-user-data.yaml \
  --user developer
```

### SSH Key Sources

#### Local SSH Keys (Default)
The script automatically uses the first available SSH public key from:
- `~/.ssh/id_rsa.pub`
- `~/.ssh/id_ed25519.pub`
- `~/.ssh/id_ecdsa.pub`

#### GitHub SSH Keys
```bash
./create_vm myvm 20G virbr0 --ssh-keys-github yourusername
```
Fetches public keys from: `https://github.com/yourusername.keys`

#### GitLab SSH Keys
```bash
./create_vm myvm 20G virbr0 --ssh-keys-gitlab yourusername
```
Fetches public keys from: `https://gitlab.com/yourusername.keys`

#### Custom SSH Key File
```bash
./create_vm myvm 20G virbr0 --ssh-key-file /path/to/custom.pub
```

### Network Configuration

#### DHCP (Default)
VMs automatically obtain IP addresses via DHCP from the specified network interface.

#### Static IP
```bash
./create_vm myvm 20G virbr0 \
  --static-ip 192.168.1.100/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8
```

### VM Management

After creation, manage your VMs with standard virsh commands:

```bash
# List all VMs
virsh list --all

# Start VM
virsh start myvm

# Stop VM
virsh shutdown myvm

# Force stop VM
virsh destroy myvm

# Connect to VM console
virsh console myvm

# Get VM info
virsh dominfo myvm

# Remove VM (this will delete the VM definition and disks)
virsh undefine myvm --remove-all-storage
```

### SSH Access

All VMs are configured with:
- SSH key-only authentication
- Password authentication disabled
- User has sudo privileges without password
- UFW firewall enabled with SSH allowed

Connect to your VM:
```bash
ssh username@vm-ip-address
```

### Custom Cloud-Init Configuration

Create a custom `user-data.yaml` file and use the `--user-data` parameter:

```yaml
#cloud-config
users:
  - name: myuser
    groups: sudo, docker
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... your-key-here

packages:
  - docker.io
  - nginx
  - postgresql

runcmd:
  - systemctl enable docker
  - systemctl start docker
```

### Troubleshooting

#### Prerequisites Check
```bash
./create_vm --check-only
```

#### Common Issues

1. **Permission Denied**: Ensure user is in libvirt group
2. **Network Interface Not Found**: Check available interfaces with `ip link show`
3. **VM Already Exists**: Choose a different VM name or remove existing VM
4. **Insufficient Disk Space**: Check available space in storage directory
5. **SSH Keys Not Found**: Verify SSH key source (local file, GitHub/GitLab username)

#### Debug Mode
For detailed debugging, modify the script to add:
```bash
set -x  # Enable debug mode
```

### Security Considerations

- SSH password authentication is disabled
- Root login is disabled
- UFW firewall is enabled by default
- User account has sudo access without password (modify user-data if needed)
- VM disks are created with appropriate permissions

---

## `ntfy_cli` - Notification CLI Tool

A simple bash script for sending notifications via ntfy.sh service.

### Features

- **Simple Notifications**: Send messages to ntfy topics
- **Token Authentication**: Supports bearer token authentication
- **Configurable**: Uses configuration file for server settings
- **Secure**: Automatically unsets sensitive variables after use

### Prerequisites

- `curl` command must be available
- Access to an ntfy server (self-hosted or ntfy.sh)
- Valid authentication token (if required by server)

### Configuration

Create a configuration file at `~/.config/ntfy/.token` with the following content:

```bash
# Your ntfy server token
ntfy_cli_token=tk_your_token_here

# Your ntfy server URL (without https://)
ntfy_server=ntfy.example.com

# Default topic to send messages to
ntfy_topic=alerts
```

#### Configuration File Permissions
For security, set appropriate permissions on the configuration file:
```bash
chmod 600 ~/.config/ntfy/.token
```

### Usage

#### Basic Syntax
```bash
./ntfy_cli "Your message here"
```

#### Examples

**Simple Notification:**
```bash
./ntfy_cli "System backup completed successfully"
```

**VM Deployment Notification:**
```bash
./ntfy_cli "VM 'webserver' deployment finished"
```

**System Alert:**
```bash
./ntfy_cli "Disk usage above 90% on server01"
```

**Integration with Other Scripts:**
```bash
# After VM creation
./create_vm myvm 20G virbr0 && ./ntfy_cli "VM 'myvm' created successfully"

# System monitoring
if [ $(df / | tail -1 | awk '{print $5}' | sed 's/%//') -gt 90 ]; then
    ./ntfy_cli "WARNING: Root filesystem usage above 90%"
fi
```

### Configuration Options

#### Server Configuration
- **ntfy_server**: Your ntfy server hostname (without protocol)
- **ntfy_topic**: Default topic for notifications
- **ntfy_cli_token**: Authentication token for the server

#### Supported ntfy Servers
- **ntfy.sh**: Public service (ntfy.sh)
- **Self-hosted**: Your own ntfy server instance

### Troubleshooting

#### Common Issues

1. **Configuration File Missing**: Ensure `~/.config/ntfy/.token` exists
2. **Permission Denied**: Check file permissions (should be 600)
3. **Network Issues**: Verify server connectivity with `curl`
4. **Authentication Failed**: Verify token is correct and has proper permissions
5. **Topic Not Found**: Ensure topic exists or can be created

#### Testing Configuration
Test your configuration manually:
```bash
# Test server connectivity
curl -s https://your-ntfy-server.com/your-topic

# Test with authentication
curl -d "test message" -H "Authorization: Bearer your-token" https://your-ntfy-server.com/your-topic
```

#### Debug Mode
For debugging, you can modify the script to show more information:
```bash
# Add to the beginning of ntfy_cli script
set -x  # Enable debug mode
```

### Security Considerations

- **Token Security**: Configuration file automatically unsets sensitive variables after use
- **File Permissions**: Configuration file should have restricted permissions (600)
- **Network Security**: Uses HTTPS for secure communication
- **No Logging**: Sensitive tokens are not logged or stored in command history

---

## File Structure

```
bash/programs/
├── create_vm                      # VM creation script
├── ntfy_cli                       # Notification CLI tool
├── example-user-data.yaml         # Example cloud-init configuration
├── README.md                      # This documentation
└── cache/                         # Created automatically for image caching
    └── debian-*-generic-amd64.qcow2  # Downloaded Debian images
```

## License

These scripts are provided as-is for educational and production use. Modify as needed for your environment.

## Contributing

Feel free to submit issues and enhancement requests!
