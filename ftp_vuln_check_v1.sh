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
    msfconsole -q -x "use auxiliary/scanner/ftp/anonymous; set RHOSTS $IP; run; exit" | tee anon_check_$IP.txt
    grep -q "Anonymous FTP login allowed" anon_check_$IP.txt && echo "Anonymous login allowed on $IP" || echo "Anonymous login not allowed on $IP"

    # Step 3: Retrieve server details
    echo "Retrieving server details for $IP..."
    msfconsole -q -x "use auxiliary/scanner/ftp/ftp_version; set RHOSTS $IP; run; exit" | tee version_info_$IP.txt

    # Extract server details
    FTP_VERSION=$(grep "Banner" version_info_$IP.txt | awk -F'Banner: ' '{print $2}')
    echo "FTP server version for $IP: $FTP_VERSION"

    # Step 4: Check for vulnerabilities
    echo "Checking for vulnerabilities for FTP server version: $FTP_VERSION..."
    msfconsole -q -x "search name:$FTP_VERSION type:exploit; exit" | tee vulnerability_$IP.txt

    # List found vulnerabilities
    echo "Vulnerabilities for $IP:"
    grep "exploit/" vulnerability_$IP.txt || echo "No vulnerabilities found for $FTP_VERSION on $IP"

done <ftp_servers.txt

echo "Script completed."
