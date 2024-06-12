#!/bin/bash

# Check if input file exists
if [ ! -f sites.txt ]; then
    echo "sites.txt not found!"
    exit 1
fi

# Create or clear the results file
> results.txt

# Read each line from sites.txt
while IFS= read -r site
do
    echo "Scanning $site for open FTP port..."

    # Scan for open FTP port (21)
    open_port=$(nmap -p 21 --open -oG - $site | grep 21/open)

    if [ -n "$open_port" ]; then
        echo "$site has an open FTP port. Checking for anonymous login..."

        # Check for anonymous FTP login
        anon_login=$(nmap -p 21 --script ftp-anon $site | grep "Anonymous FTP login allowed")

        if [ -n "$anon_login" ]; then
            echo "$site allows anonymous FTP login" | tee -a results.txt
        else
            echo "$site does not allow anonymous FTP login" | tee -a results.txt
        fi
    else
        echo "$site does not have an open FTP port" | tee -a results.txt
    fi

    echo "-----------------------------------" >> results.txt
done < sites.txt

echo "Scan complete. Results saved in results.txt"
