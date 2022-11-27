# Packer Template: PVE TrueNAS

A Packer template that creates a TrueNAS VM template on a Proxmox VE host.

## Requirements

- A Proxmox VE Host
- A machine with Hashicorp Packer
- A network connection between the PVE host and the builder machine

## Getting Started

- Clone this repo
- Download a TrueNAS ISO and upload it to your Proxmox server
- Create a `.auto.pkrvars.hcl` file and customize it
- Run the `packer init` command
- Run the `packer build` command

### Variables

Here's an empty sample for the `.auto.pkrvars.hcl` file, for you to customize:

```hcl
# ===============================================
# PROXMOX API CONNECTION
# ===============================================
proxmox_api_url          = ""
proxmox_api_token_id     = ""
proxmox_api_token_secret = ""
proxmox_node             = ""

# ===============================================
# ISO FILE CONFIGURATION
# ===============================================
iso_file = ""

# ===============================================
# TRUENAS CONFIGURATION
# ===============================================
truenas_root_password = ""

# ===============================================
# VM TEMPLATE CONFIGURATION
# ===============================================
vm_id   = ""
vm_name = ""

storage_pool      = ""
storage_pool_type = ""

vmbridge = ""
```

## Advanced Usage

For a more advanced usage, see the `templates/` directory. Inside, there are some jinja2 templated versions of the same `.pkr.hcl` files that allow for more granular customization.

They are intended to be formatted by an Ansible task, such as:

``` yaml
---
- name: Create a TrueNAS VM template
  hosts: localhost
  become: true
  gather_facts: false

  vars:
    proxmox_api_url: "https://1.2.3.4:8006/api2/json"
    proxmox_api_token_id: "your token id here"
    proxmox_api_token_secret: "your-token-secret-here"
    proxmox_api_insecure: true
    truenas_tpl_root_pass: test123
    truenas_tpl_node: pve01
    truenas_tpl_id: 1100
    truenas_tpl_iso: local:iso/TrueNAS-13.0-U3.1.iso
    truenas_tpl_disks:
      - size: 16G
        storage_pool: local-zfs
        storage_pool_type: zfspool
    opnsense_tpl_networks:
      - bridge: vmbr0
        firewall: false
        model: virtio

  tasks:
    - name: Clone the packer-proxmox_opnsense repo
      ansible.builtin.git:
        repo: https://github.com/mirceanton/packer-proxmox_truenas
        dest: /opt/packer-proxmox_truenas

    - name: Create template output directory
      ansible.builtin.file:
        path: /opt/packer-proxmox_truenas/template-output
        state: directory

    - name: Templatize resource file
      ansible.builtin.template:
        src: /opt/packer-proxmox_truenas/templates/main.pkr.hcl.j2
        dest: /opt/packer-proxmox_truenas/template-output/main.pkr.hcl

    - name: Copy the plugins file
      ansible.builtin.copy:
        src: /opt/packer-proxmox_truenas/plugins.pkr.hcl
        dest: /opt/packer-proxmox_truenas/template-output/plugins.pkr.hcl

    - name: Init the Packer project
      ansible.builtin.shell: |
        cd /opt/packer-proxmox_truenas/template-output/;
        packer init .
      changed_when: false

    - name: Run Packer
      ansible.builtin.shell: |
        cd /opt/packer-proxmox_truenas/template-output/;
        packer build .
      register: __packer_run

    - debug:
        var: __packer_run.stdout_lines
```

### Variables

For more details on certain variables, refer to the official provider [documentation](https://registry.terraform.io/providers/toowoxx/packer/latest/docs).

``` yaml
# Proxmox Connection Params
proxmox_api_url:                      # [Required] The URL for the Proxmox API endpoint
                                      # Format: https://a.b.c.d:8006/api2/json
pm_api_token_id:                      # [Required] The access token ID
pm_api_token_secret:                  # [Required] The access token secret
proxmox_api_insecure: true            # [Optional] Whether or not to ignore self signed certs.
truenas_tpl_node:                    # [Required] The name of the node on which to deploy the VM
truenas_tpl_id:                      # [Optional] The ID of the VM template
truenas_tpl_name: opnSense-tpl       # [Optional] The name of the VM template
truenas_tpl_iso:                     # [Required] The path to the ISO file, including the storage device
truenas_tpl_iso_unmount: true        # [Optional] Whether or not to unmount the ISO at the end
truenas_tpl_cpu_cores: 4             # [Optional] The number of threads to assign to the VM
truenas_tpl_memory: 8192             # [Optional] The amount of RAM in mb to assign to the VM
truenas_tpl_scsihw: virtio-scsi-pci  # [Optional] The type of SCSI hardware
truenas_tpl_boot_order: c            # [Optional] Device boot order (disk -> dvd -> network)
                                     # Options: floppy (a), hard disk (c), CD-ROM (d), or network (n).
truenas_tpl_boot_wait: 30s           # [Optional] The amount of time to wait for the installer to start
truenas_tpl_root_pass:               # [Required] The password to set for the root user
truenas_tpl_networks:                # [Required] List of network devices
  - bridge:           # [Required] The name of the network bridge to attach to. (vmbr0, vmbr1 etc)
    firewall: false   # [Optional] Whether or not to 
    model: virtio     # [Optional] The NIC model
truenas_tpl_disks:                   # [Required] List of disks to assign to the VM
  - size: 16G           # [Required] The name of the storage pool on which to store the disk
    storage_pool:       # [Required] The name of the storage pool on which to store the disk
    storage_pool_type:  # [Required] The type of the storage pool on which to store the disk
```

## License

MIT

## Author Information

A template developed by [Mircea-Pavel ANTON](https://www.mirceanton.com).
