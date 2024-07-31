#!/bin/bash

# NetSleuth: Advanced IP Intelligence Gatherer (Interactive Edition)

# Global variables
declare -A COLOR
COLOR[RED]='\033[0;31m'
COLOR[GREEN]='\033[0;32m'
COLOR[YELLOW]='\033[0;33m'
COLOR[BLUE]='\033[0;34m'
COLOR[NC]='\033[0m' # No Color

function getData {
    local filenames=("$@")
    local addresses=()
    local filteredAddresses=()
    local results=()

    # Extract and deduplicate IP addresses
    for filename in "${filenames[@]}"; do
        if [[ ! -f "$filename" ]]; then
            echo -e "${COLOR[RED]}Error: Could not find the specified file: $filename${COLOR[NC]}" >&2
            exit 1
        fi
        mapfile -t -O ${#addresses[@]} addresses < <(grep -oE '(\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\b' "$filename" | sort -u)
    done

    # Filter out private and reserved IP addresses
    local private_regex='^(0\.|10\.|127\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)'
    filteredAddresses=($(printf '%s\n' "${addresses[@]}" | grep -vE "$private_regex"))

    local total=${#filteredAddresses[@]}
    local i=0

    for filteredAddress in "${filteredAddresses[@]}"; do
        progressBar $i $total "Fetching IP data"
        ((i++))

        local url="https://ipinfo.io/$filteredAddress/json"
        [[ -n "$apiToken" ]] && url+="?token=$apiToken"

        local rawData
        rawData=$(curl -s "$url" | jq -r '[.ip, .hostname // "N/A", .country // "N/A", .region // "N/A", .city // "N/A", .postal // "N/A", (.loc // "N/A,N/A"), .org // "N/A"] | join(",")')

        if [[ $? -ne 0 ]]; then
            echo -e "${COLOR[RED]}Error parsing address: $filteredAddress${COLOR[NC]}" >&2
            continue
        fi

        local addressCount=$(printf '%s\n' "${addresses[@]}" | grep -c "^$filteredAddress$")
        results+=("$rawData,$addressCount")
    done

    results=("IP Address,Hostname,Country,Region,City,Postal Code,Latitude,Longitude,ASN,Count" "${results[@]}")
    printf '%s\n' "${results[@]}"
}

function printData {
    local -n results=$1
    local IFS=$'\n'
    local rows=(${results[*]})
    local widths=($(head -n1 <<< "${rows[*]}" | awk -F, '{for(i=1;i<=NF;i++) print length($i)}'))

    printf "${COLOR[BLUE]}%s${COLOR[NC]}\n" "${rows[0]}"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '-'

    for row in "${rows[@]:1}"; do
        IFS=',' read -ra cells <<< "$row"
        for i in "${!cells[@]}"; do
            printf "%-*s | " "${widths[i]}" "${cells[i]}"
        done
        echo
    done
}

function writeData {
    local outfile=$1
    shift
    local -n data=$1

    if [[ ! -w $(dirname "$outfile") ]]; then
        echo -e "${COLOR[RED]}Error: Cannot write to the specified file: $outfile${COLOR[NC]}" >&2
        exit 1
    fi

    printf '%s\n' "${data[@]}" > "$outfile"
    echo -e "${COLOR[GREEN]}Data successfully written to $outfile${COLOR[NC]}"
}

function progressBar {
    local count=$1
    local total=$2
    local status=$3
    local bar_len=40
    local filled_len=$((count * bar_len / total))
    local bar=$(printf '%*s' "$filled_len" | tr ' ' '█')
    local empty=$(printf '%*s' $((bar_len - filled_len)) | tr ' ' '░')
    printf "\r${COLOR[YELLOW]}[%s%s] %3d%% %s${COLOR[NC]}" "$bar" "$empty" $((count * 100 / total)) "$status"
}

function interactiveMenu {
    local filenames=()
    local writeToFile=0
    local apiToken=""
    local outfile=""

    while true; do
        echo -e "\n${COLOR[BLUE]}NetSleuth: Advanced IP Intelligence Gatherer${COLOR[NC]}"
        echo "1. Add input file"
        echo "2. Set API token"
        echo "3. Set output file"
        echo "4. Run analysis"
        echo "5. Exit"
        
        read -p "Enter your choice (1-5): " choice

        case $choice in
            1)
                read -p "Enter the filename: " filename
                if [[ -f "$filename" ]]; then
                    filenames+=("$filename")
                    echo -e "${COLOR[GREEN]}File added successfully.${COLOR[NC]}"
                else
                    echo -e "${COLOR[RED]}File not found. Please try again.${COLOR[NC]}"
                fi
                ;;
            2)
                read -p "Enter your API token (press Enter to skip): " apiToken
                ;;
            3)
                read -p "Enter the output filename: " outfile
                writeToFile=1
                ;;
            4)
                if [[ ${#filenames[@]} -eq 0 ]]; then
                    echo -e "${COLOR[RED]}Error: No input files specified${COLOR[NC]}"
                else
                    local output
                    mapfile -t output < <(getData "${filenames[@]}" "$apiToken")

                    if [[ $writeToFile -eq 1 && -n "$outfile" ]]; then
                        writeData "$outfile" output
                    else
                        printData output
                    fi
                    
                    read -p "Press Enter to continue..."
                fi
                ;;
            5)
                echo "Exiting NetSleuth. Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${COLOR[RED]}Invalid choice. Please try again.${COLOR[NC]}"
                ;;
        esac
    done
}

interactiveMenu