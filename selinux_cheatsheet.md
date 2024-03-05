# SELinux Cheat Sheet
--------------------------------------

  Utilizing **SELinux** *(**Security-Enhanced Linux**)* effectively can significantly enhance the security posture of your operating system. 

  **SELinux** operates by <u>enforcing mandatory access control</u> *(**MAC**)* <u>policies</u> that restric users and processes to only the resources they're explicitly allowed to access. 
#
-------------------------------------
Here's a cheat sheet with basic commands, code snippets, and comments to help you  manage **SELinux** on your system.
# 
-------------------------------------

### 1. Checking SELinux Status

- **Check if SELinux is enabled:**
  ```bash
  sestatus
  ```
  This command shows the current SELinux status and the enforced mode.

### 2. Managing SELinux Modes

- **Set SELinux to enforcing mode (actively enforcing policies):**
  ```bash
  sudo setenforce 1
  ```
- **Set SELinux to permissive mode (logs actions that would have been blocked):**
  ```bash
  sudo setenforce 0
  ```
- **Disable SELinux (not recommended for secure environments):**
  - You need to edit `/etc/selinux/config` and set `SELINUX=disabled`, then reboot.

### 3. Managing Policies

- **List all SELinux boolean settings:**
  ```bash
  getsebool -a
  ```
- **Change a SELinux boolean setting (temporarily):**
  ```bash
  sudo setsebool httpd_can_network_connect 1
  ```
  Replace `httpd_can_network_connect` with the boolean you wish to change.

- **Change a SELinux boolean setting (persistently across reboots):**
  ```bash
  sudo setsebool -P httpd_can_network_connect 1
  ```

### 4. Managing File Contexts

- **View the SELinux context of a file:**
  ```bash
  ls -Z /path/to/file
  ```
- **Change the SELinux context of a file:**
  ```bash
  sudo chcon -t httpd_sys_content_t /path/to/file
  ```
  This is temporary and will revert if the file system is relabeled or if the file is modified.

- **Permanently change the context of a file using semanage:**
  ```bash
  sudo semanage fcontext -a -t httpd_sys_content_t "/path/to/file"
  sudo restorecon -v /path/to/file
  ```
  This makes the change persistent across file modifications and system relabels.

### 5. Troubleshooting and Logs

- **Search for SELinux-related logs:**
  ```bash
  ausearch -m avc -ts recent
  ```
  This command searches for AVC (Access Vector Cache) denials that have occurred recently.

- **Generate and apply a module to allow previously denied actions:**
  ```bash
  ausearch -m avc -ts recent | audit2allow -M mymodule
  sudo semodule -i mymodule.pp
  ```
  This creates and installs a custom module named `mymodule` to allow actions that were previously denied, based on recent AVC denials.

### Notes

- Changing SELinux policies and contexts should be done with caution, as incorrect settings can result in services not functioning correctly.
- Always back up SELinux policies and important configurations before making significant changes.
- Use `restorecon` to revert files to their default context if you encounter issues after changing contexts.
- The `audit2allow` tool is powerful but use it judiciously. Automatically allowing all denied actions can weaken your security stance.
#
-----------------------------------------
This cheat sheet provides a starting point for managing SELinux on your system. SELinux is a complex tool, and its effective use requires a good understanding of your system's security needs and how SELinux policies work.
