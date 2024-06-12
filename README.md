# FTP Exploit Automation Scripts

1. `ftp_exploit_v1_[auto_anonymous_login].sh`: This script tries to exploit an FTP server with anonymous login enabled. It automatically logs into the FTP server and uploads a file.
    ```sh
    ./ftp_exploit_v1_[auto_anonymous_login].sh domain_name.com
    ```

2. `ftp_exploit_v2_[attempt_to_read_writeable_directories].sh`: This script tries to exploit an FTP server with anonymous login enabled. It automatically logs into the FTP server and checks for writable directories.
    ```sh
    ./ftp_exploit_v2_[attempt_to_read_writeable_directories].sh domain_name.com
    ```

3. `ftp_exploit_v3_[succesfull_upload_file_to_writeable_dir].sh`: This script tries to exploit an FTP server with anonymous login enabled. It automatically logs into the FTP server, checks for writable directories, and injects a file into the first writable directory found.
    ```sh
    ./ftp_exploit_v3_[succesfull_upload_file_to_writeable_dir].sh domain_name.com
    ```

4. `ftp_exploit_v4_[injects_file_to_all_writable_directories].sh`: This script is not provided in the workspace, so I can't provide a description for it.

5. `ftp_exploit_v5_[tries_to_download_all_readable_files].sh`: This script tries to exploit an FTP server with anonymous login enabled. It automatically logs into the FTP server, checks for readable directories, and downloads all readable files.
    ```sh
    ./ftp_exploit_v5_[tries_to_download_all_readable_files].sh domain_name.com
    ```

# FTP Vulnerability Check Scripts

1. `ftp_vuln_check_v1.sh`: This script is not provided in the workspace, so I can't provide a description for it.

2. `ftp_vuln_check_v2.sh`: This script is not provided in the workspace, so I can't provide a description for it.

3. `ftp_vuln_check_v3_[Perform_general_ftp_enumeration].sh`: This script is not provided in the workspace, so I can't provide a description for it.

4. `ftp_vuln_check.sh`: This script is not provided in the workspace, so I can't provide a description for it.
