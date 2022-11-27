source "proxmox" "truenas" {
  # ============================
  # Proxmox Connection Settings
  # ============================
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true # ignore self signed certs

  # ============================
  # General Settings
  # ============================
  node       = "${var.proxmox_node}"
  vm_id      = "${var.vm_id}"
  vm_name    = "${var.vm_name}"
  qemu_agent = false # Disable guest agent

  # ============================
  # ISO Settings
  # ============================  
  iso_file    = "${var.iso_file}"
  unmount_iso = true # Unmount the iso from the CD drive

  # ============================
  # Resource Settings
  # ============================
  cores  = "4"    # Minimum cpu requirement as per the official doc
  memory = "8192" # Minimum ram requirement as per the official doc

  # ============================
  # Disk Settings
  # ============================
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size         = "16G"
    storage_pool      = "${var.storage_pool}"
    storage_pool_type = "${var.storage_pool_type}"
  }

  # =============================================
  # NETWORK
  # =============================================
  network_adapters {
    bridge   = "${var.vmbridge}"
    firewall = false
    model    = "virtio"
  }

  # ============================
  # Boot Settings
  # ============================
  boot      = "c"
  boot_wait = "30s"
  boot_command = [
    # Select the "Install/Upgrade" option
    "<enter>",
    "<wait1>",

    # Select the only disk present to install the OS on
    "<spacebar>", "<enter>",
    "<wait1>",
    "<enter>",

    # Enter the root password
    "${var.truenas_root_password}", "<wait1>", "<tab>",
    "${var.truenas_root_password}", "<wait1>", "<enter>",
    "<wait1>",

    # Boot via BIOS
    "<enter>",

    # Wait for OS installation
    "<wait120>",

    # Install complete, select OK
    "<enter>",

    # Shutdown system
    "<down>", "<down>", "<down>", "<enter>",

    # Wait for system shutdown
    "<wait30>",
  ]

  ssh_username = "root"
  communicator = "none"
}

build {
  name    = "truenas-13.0-1"
  sources = ["source.proxmox.truenas"]
}