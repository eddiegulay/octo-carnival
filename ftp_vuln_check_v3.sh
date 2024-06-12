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

# Create a report file
REPORT_FILE="scan_report_for_${IP}.txt"
echo "Scan Report for $IP" >"$REPORT_FILE"
echo "Domain: $DOMAIN" >>"$REPORT_FILE"
echo "Resolved IP: $IP" >>"$REPORT_FILE"
echo "-----------------------------------------" >>"$REPORT_FILE"
echo "                                          " >>"$REPORT_FILE"
echo "-----------------------------------------" >>"$REPORT_FILE"

# Step 1: Identify if the IP address has FTP server
echo "Checking for FTP server on $IP..."
nmap -p 21 --open -oG - "$IP" | awk '/21\/open/{print $2}' >ftp_servers.txt

# Check if FTP server was found
if [ ! -s ftp_servers.txt ]; then
    echo "No FTP server found on $IP." | tee -a "$REPORT_FILE"
    exit 1
fi

echo "Found FTP server on $IP" | tee -a "$REPORT_FILE"

# Loop through each FTP server (in this case, just one)
while read -r IP; do
    echo "-----------------------------------------" >>"$REPORT_FILE"
    echo "                                          " >>"$REPORT_FILE"
    echo "-----------------------------------------" >>"$REPORT_FILE"
    echo "Processing FTP server: $IP" | tee -a "$REPORT_FILE"

    # Step 2: Check for anonymous login
    echo "Checking for anonymous login on $IP..." | tee -a "$REPORT_FILE"
    anon_result=$(msfconsole -q -x "use auxiliary/scanner/ftp/anonymous; set RHOSTS $IP; run; exit")
    echo "$anon_result" >>"$REPORT_FILE"
    if grep -q "Anonymous FTP login allowed" <<<"$anon_result"; then
        echo "Anonymous login allowed on $IP" | tee -a "$REPORT_FILE"
    else
        echo "Anonymous login not allowed on $IP" | tee -a "$REPORT_FILE"
    fi

    echo "-----------------------------------------" >>"$REPORT_FILE"
    echo "                                          " >>"$REPORT_FILE"
    echo "-----------------------------------------" >>"$REPORT_FILE"

    # Step 3: Retrieve server details using Nmap
    echo "Retrieving server details for $IP using Nmap..." | tee -a "$REPORT_FILE"
    sudo nmap -sV -p 21 "$IP" -oN nmap_version_$IP.txt
    cat nmap_version_$IP.txt >>"$REPORT_FILE"

    # Extract server details from Nmap output
    FTP_VERSION=$(grep "21/tcp open" nmap_version_$IP.txt | awk -F' ' '{print $5, $6, $7}')
    echo "FTP server version for $IP: $FTP_VERSION" | tee -a "$REPORT_FILE"

    echo "-----------------------------------------" >>"$REPORT_FILE"
    echo "                                          " >>"$REPORT_FILE"
    echo "-----------------------------------------" >>"$REPORT_FILE"
    # Step 4: Check for vulnerabilities
    if [ -n "$FTP_VERSION" ]; then
        echo "Checking for vulnerabilities for FTP server version: $FTP_VERSION..." | tee -a "$REPORT_FILE"
        vulnerability_result=$(msfconsole -q -x "search name:\"$FTP_VERSION\" type:exploit; exit")
        echo "$vulnerability_result" >>"$REPORT_FILE"

        # List found vulnerabilities
        echo "Vulnerabilities for $IP:" | tee -a "$REPORT_FILE"
        if grep -q "exploit/" <<<"$vulnerability_result"; then
            grep "exploit/" <<<"$vulnerability_result" | tee -a "$REPORT_FILE"
        else
            echo "No vulnerabilities found for $FTP_VERSION on $IP" | tee -a "$REPORT_FILE"
        fi
    else
        echo "Could not determine FTP server version for $IP" | tee -a "$REPORT_FILE"
    fi

    # Cleanup intermediate files
    rm nmap_version_$IP.txt

done <ftp_servers.txt

# Cleanup intermediate files
rm ftp_servers.txt

echo "Script completed. Report saved to $REPORT_FILE."
