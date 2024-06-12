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


# Domain Discovery Scripts

**domain_discovery/crawler.py:**  
This script is a simple web crawler that fetches and parses links from a given URL. It uses the requests library to send HTTP requests and BeautifulSoup to parse the HTML response. The script reads a list of seed domains from a file, fetches links from each domain, cleans and validates the links, and then checks if the domain of each link is not already in the discovered domains set. If it's not, it adds the domain to the set and prints it. The script then writes the discovered domains to an output file.

## Domain Discovery Scripts Documentation

### crawler.py

**Description:**  
This script is a simple web crawler that fetches and parses links from a given URL. It uses the requests library to send HTTP requests and BeautifulSoup to parse the HTML response.

**How to Run:**  
```bash
python crawler.py
```

### Key Functions

- `get_domain(url)`: Extracts the domain from a URL.
  
- `fetch_links(url)`: Sends a GET request to a URL and parses the response to extract all links.
  
- `clean_links(links, base_url)`: Cleans and validates a list of links.
  
- `crawl_domains(seed_domains, output_file)`: Crawls a list of seed domains and writes the discovered domains to an output file.

### conditional_crawler.py

**Description:**  
This script is similar to `crawler.py`, but it uses multithreading to crawl multiple domains concurrently. It also includes a function to check if a domain belongs to Tanzania by checking its top-level domain (TLD) against a list of valid Tanzanian TLDs.

**How to Run:**  
```bash
python conditional_crawler.py
```

### Key Functions

- `get_domain(url)`: Extracts the domain from a URL.
  
- `fetch_links(url)`: Sends a GET request to a URL and parses the response to extract all links.
  
- `clean_links(links, base_url)`: Cleans and validates a list of links.
  
- `is_tanzanian_domain(domain)`: Checks if a domain belongs to Tanzania.
  
- `crawl_single_domain(seed, discovered_domains, lock)`: Crawls a single domain and adds discovered domains to a set using multithreading.
  
- `crawl_domains(seed_domains, output_file)`: Crawls a list of seed domains using multithreading and writes the discovered domains to an output file.
