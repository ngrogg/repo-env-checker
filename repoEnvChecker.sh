#!/usr/bin/env bash

# Repo Env Checker
# A BASH script for checking git repos for .env files not in .gitignore
# By Nicholas Grogg
# Revision: 20260822

# Uncomment for exit on non-zero status from rightmost pipe command
set -o pipefail

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## Set text back to standard terminal font
normal=$(tput sgr0)

# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "check/Check" \
    "* Check a provided filepath for unignored .env files." \
    " " \
    "Ex. ./repoEnvChecker.sh check /path/to/git/repo" \
    " "
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Check" \
    "----------------------------------------------------" \
    " "

    ## Variables
    ### Filepath to check
    local filepath="$1"
    ### Array for env files, -a for indexed array with local keyword
    local -a env_files=()
    ### Array for gitignore files, -a for indexed array with local keyword
    local -a unignored_env_files=()

    ## Checks
    ### Is filepath empty? Does directory exist?
    if [[ -z "$filepath" || ! -d "$filepath" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "Filepath not provided or directory does not exist." \
        " " \
        "Running help script and exiting." \
        " " \
        "Re-run script with valid input${normal}" \
        " "

        helpFunction

        exit 1
    else
        printf "%s\n" \
        "${green}Filepath passed" \
        "----------------------------------------------------" \
        "Checking $filepath ${normal}" \
        " "
    fi

    ### Is directory a git repo? Exit if not
    if ! git -C "$filepath" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "filepath $filepath is not a git directory!" \
        " " \
        "Exiting!" \
        " "

        exit 1
    fi

    ## Find all .env files
    printf "%s\n" \
    "Env File check" \
    "----------------------------------------------------" \
    " "

    ### While loop to populate array, look for .env and .env.* files
    while IFS= read -r -d '' file; do
        env_files+=("$file")
    done < <(find "$filepath" -type f \( -name ".env" -o -name ".env.*" \) -print0)

    ### If no .env files found, exit
    if [[ ${#env_files[@]} -eq 0 ]]; then
        printf "%s\n" \
        "${green}No .env files found" \
        "----------------------------------------------------" \
        "Filepath $filepath clear" \
        " " \
        "Exiting ${normal}" \
        " "

        exit 0
    fi

    ## Check git ignore
    printf "%s\n" \
    "Found ${#env_files[@]} .env file(s)." \
    "----------------------------------------------------" \
    "Checking git ignore files" \
    " "

    ### Check each .env file against git rules, append to array if not
    for env_file in "${env_files[@]}"; do
        if ! git -C "$filepath" check-ignore -q "$env_file"; then
            unignored_env_files+=("$env_file")
        fi
    done

    ## Output results
    printf "%s\n" \
    "Check results" \
    "----------------------------------------------------" \
    " "

    ### If there's anything unignored alert
    if [[ ${#unignored_env_files[@]} -gt 0 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Unignored env files found!" \
        "----------------------------------------------------" \
        "The following env file(s) are NOT ignored by git:${normal}" \

        #### List files
        for unignored in "${unignored_env_files[@]}"; do
            printf "  - %s\n" "$unignored"
        done

    ### Else exist cleanly
    else
        printf "%s\n" \
        "${green}Env files are properly ignored" \
        "----------------------------------------------------" \
        "Exiting" \
        " "
    fi

}

# Main, read passed flags
printf "%s\n" \
"Repo Env Checker" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------" \
" "

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------" \
    " "

    helpFunction

    exit 0
    ;;
[Cc]heck)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------" \
    " "

    runProgram "$2"
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}" \
    " "

    helpFunction

    exit 1
    ;;
esac
