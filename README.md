# linuxsi - System Information Script

This Bash script provides a quick overview of system information, including CPU load, memory usage, disk information, external IP addresses, and more. The script is designed to be run in a terminal environment.

### Requirements

- **lm-sensors:** Install using:
  ```bash
  # Debian
  apt-get install lm-sensors

  # RHEL
  yum install lm_sensors
  ```

- **lsb_release:** Install using:
  ```bash
  # Debian
  apt-get install lsb-core

  # RHEL
  yum install redhat-lsb-core
  ```

#### Optional Requirement

- **Fail2ban:** The script checks for the existence and readability of Fail2ban logs.

## Installation

1. **SSH Configuration:**
    ```bash
    vim /etc/ssh/sshd_config
    ```
    Set `PrintMotd no`.

2. **Edit the Login Configuration:**
    ```bash
    vim /etc/pam.d/login
    ```
    Comment out the line `# session optional pam_motd.so`.

3. **Add to Profile:**
    ```bash
    vim /etc/profile
    ```
    Add `/path/to/script.sh` at the bottom.

4. **Drop the Script:**
    Drop the script file at `/path/to/script.sh`.

## Usage

Simply execute the script in a terminal:
```bash
bash /path/to/script.sh
```

## Notes

- The script provides information on CPU load, memory usage, disk utilization, external IP addresses, and more.
- It includes a timeout feature to avoid long hangs during SSH login.

## Disclaimer

This script is provided as-is and may require adjustments based on your system configuration. Use it at your own risk.
