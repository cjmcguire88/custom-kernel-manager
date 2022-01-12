# custom-kernel-manager

## Distro agnostic kernel manager written in Bash

Undergoing a major rewrite in a different repo. I am making it more modular so
it will be easier to maintain. I am also making it so that the bulk of the
operations it carries out will be done as a normal user. Many of the functions
do not require root privilege, thus we shouldn't operate as root until
absolutely necessary. Once finished all updates will be pushed to this repo.

Usage: `kernel -flag {OPTARG}`

### Overview

"kernel" can download, name, patch, configure, compile and install any kernel
version you'd like. Any kernel tarball downloaded will be cryptographically
verified, retrieving the PGP keys using the Web Key Directory (WKD) protocol if
they are not already in the keyring. It has a configuration file that contains
various settings that can be customized for different setups. It will handle
every part of the process including various methods of configuration and
generation of initramfs. It will allow you to copy your current kernels
configuration if so desired and will track any changes made to kernel configs
by date and kernel in the same directory where backups are kept. You can create
a script named hooks in $HOME/.config/kernel containing any post install
procedures you may want to run such as graphics driver installation, updating
bootloaders or even generating a unified kernel image from the kernel that was
installed. If the hooks file is present kernel will ask if you'd like to run it
after a successful installation. Kernel can also safely remove (allows you to
review and confirm the exact files it will remove), backup and restore kernels
as well. When patching you have 2 options which are, create a directory named
"patches" containing the patches you wish to apply in $HOME/.config/kernel or
create a file named "patchfile" containing links to patches in
$HOME/.config/kernel and kernel will download them for you. It can also
retrieve the changelog for any version passed to it and display it in your
viewer of choice. When run without any arguments kernel will output various
information about installed kernels and backups on the system.

### Flags

-d   Downloads the kernel version passed as an argument. (Downloads to SRC_DIR)  
-i   Install a specific kernel version. (Requires argument e.g. 5.15.1)  
-b   Create a .tar.gz archive of the kernel source directory. Can be restored with -a.  
-m   Modify kernel config and optionally recompile and install kernel. (Requires argument e.g. 5.15.1-NAME)  
-r   Remove a kernel from system. (Requires argument e.g. 5.15.1-NAME)  
-a   Restore a kernel that was backed up then removed. (Requires argument e.g. 5.15.1-NAME)  
-c   View the kernel changelog for a specific kernel version. (Requires argument e.g. 5.15.1)  
-p   Dump a directory containing the patches listed in patchfile (used for testing patchfile).  
-u   Update the kernel to the latest stable on kernel.org if newer than current kernel.  
-n   Create a new kernel. Choose between stable and LTS.  
-h   Show help dialogue.  

### Installation

Clone the repo.  
`mkdir -p $HOME/.config/kernel`  
`cp kernel.conf $HOME/.config/kernel`  
Edit kernel.conf if needed  
Copy kernel script to directory in PATH (e.g. $HOME/.local/bin  
Create patchfile or directory if using patches  
Create hooks file if desired.  
