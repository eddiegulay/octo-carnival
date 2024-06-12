#!/bin/bash

# Check if input file exists
if [ ! -f sites.txt ]; then
    echo "sites.txt not found!"
    exit 1
fi

# Create or clear the results file
> results.txt

# Function to perform nslookup and test FTP server for a domain
test_ftp_server() {
    local domain="$1"
    local ip_address=""
    local open_port=""
    local anon_login=""

    # Perform nslookup to get the IP address
    ip_address=$(nslookup $domain | grep "Address:" | grep -v "#" | awk '{print $2}')

    if [ -n "$ip_address" ]; then
        echo "IP address for $domain: $ip_address"

        # Scan for open FTP port (21)
        open_port=$(nmap -p 21 --open -oG - $ip_address | grep 21/open)

        if [ -n "$open_port" ]; then
            echo "$domain ($ip_address) has an open FTP port. Checking for anonymous login..."

            # Check for anonymous FTP login
            anon_login=$(nmap -p 21 --script ftp-anon $ip_address | grep "Anonymous FTP login allowed")

            if [ -n "$anon_login" ]; then
                echo "$domain ($ip_address) allows anonymous FTP login" >> results.txt
            else
                echo "$domain ($ip_address) does not allow anonymous FTP login" >> results.txt
            fi
        else
            echo "$domain ($ip_address) does not have an open FTP port" >> results.txt
        fi

        echo "-----------------------------------" >> results.txt
    else
        echo "Failed to get IP address for $domain. Skipping..."
    fi
}

# Read each line from sites.txt and run test_ftp_server function in a separate background process
while IFS= read -r site
do
    test_ftp_server "$site" &
done < sites.txt

# Wait for all background processes to finish
wait

echo "Scan complete. Results saved in results.txt"
