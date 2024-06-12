#!/bin/bash

# Enable debug mode
set -x

# Check if input file exists
if [ ! -f sites.txt ]; then
    echo "sites.txt not found!"
    exit 1
fi

# Check if sites.txt is empty
if [ -s sites.txt ]; then
    echo "sites.txt is empty! No domains to process."
else
    # Clear nslookup_results.txt
    > nslookup_results.txt

    # Loop through sites.txt
    while IFS= read -r domain; do
        echo "Performing nslookup for $domain..."
        nslookup_result=$(nslookup $domain)

        # Check for successful nslookup execution (exit code 0)
        if [ $? -eq 0 ]; then
            echo "Results for $domain:" >> nslookup_results.txt
            echo "$nslookup_result" >> nslookup_results.txt
        else
            echo "Error: nslookup failed for $domain" >> nslookup_results.txt
        fi
        echo "" >> nslookup_results.txt
    done < sites.txt
fi

echo "nslookup completed !!"
