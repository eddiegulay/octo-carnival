import requests
from bs4 import BeautifulSoup
import tldextract
import time
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor, as_completed

# Function to get domain from URL
def get_domain(url):
    try:
        ext = tldextract.extract(url)
        return ext.domain + '.' + ext.suffix
    except Exception as e:
        print(f"Error extracting domain from {url}: {e}")
        return None

# Function to fetch and parse links from a URL
def fetch_links(url):
    try:
        # Disable SSL certificate verification
        response = requests.get(url, timeout=10, verify=False)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        links = [a.get('href') for a in soup.find_all('a', href=True)]
        return links
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return []

# Function to clean and validate links
def clean_links(links, base_url):
    cleaned_links = []
    for link in links:
        if link.startswith('http'):
            cleaned_links.append(link)
        elif link.startswith('/'):
            parsed_base_url = urlparse(base_url)
            cleaned_links.append(f"{parsed_base_url.scheme}://{parsed_base_url.netloc}{link}")
    return cleaned_links

# Function to check if a domain belongs to Tanzania
# List of valid Tanzanian top-level domains
tanzanian_tlds = ['.tz', '.co.tz', '.org', '.or.tz', '.net']

# Function to check if a domain belongs to Tanzania
def is_tanzanian_domain(domain):
    # Extract the TLD from the domain
    tld = domain.split('.')[-1]
    # Check if the TLD is in the list of Tanzanian TLDs
    return tld in tanzanian_tlds


# Function to crawl a single domain
def crawl_single_domain(seed, discovered_domains, lock):
    print(f"Crawling {seed}")
    links = fetch_links(seed)
    cleaned_links = clean_links(links, seed)
    for link in cleaned_links:
        domain = get_domain(link)
        if domain and is_tanzanian_domain(domain):
            with lock:
                if domain not in discovered_domains:
                    discovered_domains.add(domain)
                    print(f"Discovered domain: {domain}")
    time.sleep(1)  # Delay to avoid being blocked

# Function to crawl domains using multithreading
def crawl_domains(seed_domains, output_file):
    discovered_domains = set()
    lock = threading.Lock()

    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(crawl_single_domain, seed, discovered_domains, lock) for seed in seed_domains]
        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Error in thread: {e}")

    # Write discovered domains to file
    with open(output_file, 'w') as f:
        for domain in discovered_domains:
            f.write(domain + '\n')

if __name__ == "__main__":
    import threading

    # Read seed domains from file
    try:
        with open('sites.txt', 'r') as file:
            seed_domains = [f"https://{line.strip()}" for line in file.readlines()]
    except FileNotFoundError as e:
        print(f"Error: {e}")
        seed_domains = []

    # Check if there are any seed domains to crawl
    if not seed_domains:
        print("No seed domains found. Exiting.")
    else:
        # Output file to store discovered domains
        output_file = "discovered_domains.txt"

        try:
            # Start crawling
            crawl_domains(seed_domains, output_file)
            print(f"Discovered domains saved to {output_file}")
        except Exception as e:
            print(f"An error occurred during the crawling process: {e}")
