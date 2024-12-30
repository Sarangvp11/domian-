#!/bin/bash

# Function to clear the screen
clear_screen() {
    printf "\033c"
}

# Function to print colored messages
print_message() {
    local message="$1"
    local color="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

# Function to animate figlet with lolcat
animate_figlet_lolcat() {
    local text="SUBDOMAIN FINDER"
    while true; do
        clear_screen
        figlet "$text" | lolcat
        echo "Press Enter to continue..."
        sleep 0.6  # Adjust sleep duration for animation speed
        
    done
    
}

# Start animation in the background
animate_figlet_lolcat &
animation_pid=$!

# Wait for user input to stop animation and continue script
read -p "Press Enter to continue..."

# Kill the animation process
kill $animation_pid > /dev/null 2>&1

# Proceed with the rest of the script
echo "
###########################################################
# Subdomain Tool
# Author: [S@R@NG_VP]
# Description: This script discovers subdomains for a given domain
# Usage: ./SubdomainFinder.sh -d example.com
###########################################################
"

# Function to print colored messages
print_message() {
    local message="$1"
    local color="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

# Function to display a spinner while performing long operations
spinner() {
    local delay=0.1
    local spinstr='|/-\'
    while [[ -d /proc/$1 ]]; do
        printf "\e[92m[%c]\e[0m" "$spinstr"
        local temp=${spinstr#?}
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
}

# Function to discover subdomains and check their live status
discover_subdomains() {
    local domain="$1"
    local output_file="$2"

    print_message "This script finds subdomains for the domain '$domain' and checks which ones are live." "92"
    echo

    # Perform asset discovery and probing
    print_message "[+] Discovering subdomains..." "93"
    assetfinder -subs-only "$domain" > subs &
    spinner $!

    print_message "[+] Checking for live subdomains..." "93"
    cat subs | httprobe > live &
    spinner $!

    # Sort and remove duplicates from the live subdomains list
    print_message "[+] Sorting and removing duplicates..." "93"
    sort -u live > "$output_file" &
    spinner $!

    # Output the sorted list of live subdomains with typewriter effect and colored text
    print_message "[+] Sorted list of live subdomains saved to '$output_file':" "94"
    cat "$output_file"
}

# Function for user interaction and input validation
get_domain_input() {
    local domain="$1"

    if [[ -z "$domain" ]]; then
        read -p "Enter the domain (e.g., example.com): " domain
        if [[ -z "$domain" ]]; then
            print_message "Domain name cannot be empty." "91"
            exit 1
        fi
    fi

    if ! valid_domain_format "$domain"; then
        print_message "Invalid domain format. Make sure the domain is correct (e.g., example.com)." "91"
        exit 1
    fi

    echo "$domain"
}

# Function to validate domain format
valid_domain_format() {
    local domain="$1"
    local regex='^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'  # Basic regex for domain format

    if [[ "$domain" =~ $regex ]]; then
        return 0  # Valid domain format
    else
        return 1  # Invalid domain format
    fi
}

# Function to prompt for confirmation before executing
confirm_execution() {
    local domain="$1"

    read -p "Proceed with discovering subdomains for '$domain'? (y/n): " choice
    case "$choice" in
        y|Y )
            return 0
            ;;
        n|N )
            print_message "Operation aborted by user." "91"
            exit 1
            ;;
        * )
            print_message "Invalid choice. Please enter 'y' or 'n'." "91"
            confirm_execution "$domain"
            ;;
    esac
}

# Function to show usage of the script
show_usage() {
    echo -e "\e[94mUsage: $0 [OPTIONS]\e[0m"
    echo -e "\e[94mOptions:\e[0m"
    echo -e "\e[94m  -d, --domain <domain>   Specify the domain to discover subdomains (e.g., example.com)\e[0m"
    echo -e "\e[94m  -h, --help              Show this help message and exit\e[0m"
    echo
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--domain)
            domain="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_message "Unknown option: $1" "91"
            show_usage
            exit 1
            ;;
    esac
done

# Get domain input from user
domain=$(get_domain_input "$domain")

# Prompt for confirmation before executing
confirm_execution "$domain"

# Output file for sorted list of live subdomains
output_file="sorted_subdomains.txt"

# Call function to discover subdomains and check live status
discover_subdomains "$domain" "$output_file"
cat "$output_file"
# Display the contents of the sorted subdomains file
print_message "\n[+] Contents of '$output_file':\n" "94"

function loading_icon() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( '—' "\\" '|' '/' )

    echo -n "${loading_message} "

    # This part is to make the cursor not blink -]id_'Fq3)JX|N4az4&C2fmo9Er6.\T7
    # on top of the animation while it lasts
    tput civis
    trap "tput cnorm" EXIT
    while [ "${load_interval}" -ne "${elapsed}" ]; do
        for frame in "${loading_animation[@]}" ; do
            printf "%s\b" "${frame}"
            sleep 0.25
        done
        elapsed=$(( elapsed + 1 ))
    done
    printf " \b\n"
}

loading_icon 60 "\nThank you for using the Subdomain Finder!\n" "92"
