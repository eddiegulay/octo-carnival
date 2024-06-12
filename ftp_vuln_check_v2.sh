#!/bin/bash

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN="$1"

# Resolve the domain to an IP address
IP=$(dig +short "$DOMAIN" | tail -n 1)

# Check if IP address is resolved
if [ -z "$IP" ]; then
    echo "Failed to resolve domain $DOMAIN to an IP address."
    exit 1
fi

echo "Domain $DOMAIN resolved to IP address $IP"

# Step 1: Identify if the IP address has FTP server
echo "Checking for FTP server on $IP..."
nmap -p 21 --open -oG - "$IP" | awk '/21\/open/{print $2}' >ftp_servers.txt

# Check if FTP server was found
if [ ! -s ftp_servers.txt ]; then
    echo "No FTP server found on $IP."
    exit 1
fi

echo "Found FTP server on $IP"

# Loop through each FTP server (in this case, just one)
while read -r IP; do
    echo "Processing FTP server: $IP"

    # Step 2: Check for anonymous login
    echo "Checking for anonymous login on $IP..."
    anon_result=$(msfconsole -q -x "use auxiliary/scanner/ftp/anonymous; set RHOSTS $IP; run; exit" | tee anon_check_$IP.txt)
    if grep -q "Anonymous FTP login allowed" <<<"$anon_result"; then
        echo "Anonymous login allowed on $IP"
    else
        echo "Anonymous login not allowed on $IP"
    fi

    # Step 3: Retrieve server details using Nmap
    echo "Retrieving server details for $IP using Nmap..."
    sudo nmap -sV -p 21 "$IP" -oN nmap_version_$IP.txt

    # Extract server details from Nmap output
    FTP_VERSION=$(grep "21/tcp open" nmap_version_$IP.txt | awk -F' ' '{print $5, $6, $7}')
    echo "FTP server version for $IP: $FTP_VERSION"

    # Step 4: Check for vulnerabilities
    if [ -n "$FTP_VERSION" ]; then
        echo "Checking for vulnerabilities for FTP server version: $FTP_VERSION..."
        vulnerability_result=$(msfconsole -q -x "search name:\"$FTP_VERSION\" type:exploit; exit" | tee vulnerability_$IP.txt)

        # List found vulnerabilities
        echo "Vulnerabilities for $IP:"
        if grep -q "exploit/" vulnerability_$IP.txt; then
            grep "exploit/" vulnerability_$IP.txt
        else
            echo "No vulnerabilities found for $FTP_VERSION on $IP"
        fi
    else
        echo "Could not determine FTP server version for $IP"
    fi

done <ftp_servers.txt

echo "Script completed."
