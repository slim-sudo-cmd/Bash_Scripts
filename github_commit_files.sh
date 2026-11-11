#!/usr/bin/env bash

# ---------------------------
# ERROR COLOR CODE
# ---------------------------

MANG='\033[1;35m'
YELL='\033[1;33m'
NC='\033[0;0m' # -> reset if no color printed
SKYB='\033[1;36m'

file_path=$(pwd)
file_data="${1:-}"
username="${2:-}" 
repository_name="${3:-}"

# ----------------------------
# USER INPUTS 
# ----------------------------

#>>> Takes in user inputs
file_inputs(){
    local prompt=$1
    local condition_func=$2
    local err_msg=$3
    local -n output_val=$4
    local input
    while true ; do
        echo -e "$prompt"
        read -rp ">>> [?] Res :" input
        if [[ -z "$condition_func" ]] || "$condition_func" "$input" ; then
            output_val="$input"
            return 0
        fi
        echo -e "\n${MANG}>>> $err_msg !!${NC}"
        continue
    done
}

# >>> Checks length of file name
file_name_checker(){
    local file_name=$1
    [[ "$file_name" =~ ^[a-zA-Z0-9._[:space:]-]+$ ]] && (( ${#file_name} >= 3 && ${#file_name} <= 15 ))
}

# >>> Checks file path validity
directory_path_checker(){
    local file_path=$1
    [[ "$file_path" =~ ^/?([a-zA-Z0-9._\ -]+/?)+$ ]]
}

# >>> Handles username validity
username_checker(){
    local username=$1
    if (( ${#username} < 1 || ${#username} > 39 )) ; then
        return 1
    fi
    if [[ ! "$username" =~ [a-zA-Z0-9-]+$ ]] ; then 
        return 1
    fi
    if [[ "$username" =~  ^- ]] || [[ "$username" =~ -$ ]] ; then 
        return 1
    fi
    return 0
}

# >>> Handles single variable inputs eg menu options
menu_options(){
    local user_input=$1
    [[ "$user_input" =~ ^[0-2]$ ]] 
}

# >>> Handles continue option
github_actions(){
    local file_data=$1
    if [[ -n "$file_data" ]] ; then 
        if [[ -f "$file_data" ]]; then 
            commit_single_file "$file_data" "$username" "$repository_name"
            return 0
        fi
        if [[ -d "$file_data" ]] ;then
            commit_multiple_files "$file_data" "$username" "$repository_name"
            return 0
        fi
    fi
    local cont_opt
    file_inputs "\n>>> [+] Continue with ;\n>> 1: Commit Single File \n>> 2: Commit Multiple Files\n>> 0: Close Program\n\n" menu_options "Enter a valid input" cont_opt
    case "$cont_opt" in 
        1)
            commit_single_file "$file_data" "$username" "$repository_name" 
            return 0
            ;;
        2)
            commit_multiple_files "$file_data" "$username" "$repository_name" 
            return 0
            ;;
        0)
            echo -e "\n========= • GOOD • BYE ===========\n"
            return 0;;
    esac
}

# -----------------------------
# GITHUB COMMIT & PUSH FILE
# -----------------------------

# >>> Handles single file addition
commit_single_file(){
    local file_name=$1
    while true; do
        if [[ -z "$file_name" ]]; then 
            file_inputs "\n>>> Enter File Name @ $file_path" file_name_checker "Enter a valid File Name" file_name 
        fi
        if [[ ! -f "$file_name" ]]; then
            echo -e "\n${MANG}FILE DOESN'T EXIST !!${NC}\n"
            continue
        fi
        if [[ -z "$username" ]]; then
            file_inputs "\n>>> Enter GitHub Username" file_name_checker "Enter a valid Username" username
        fi
        if [[ -z "$repository_name" ]]; then 
            file_inputs "\n>>> Enter GitHub Repository Name" username_checker "Enter a valid Repository Name" repository_name
        fi
        break   
    done
    echo -e "\n${YELL}>>> [*] Initializing GitHub Connection ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then 
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}"
        exit 1
    fi
    git init 
    git branch -M main
    sleep 2
    echo -e "${YELL}>>> [*] Adding File ...${NC}"
    git add -v "$file_name" || { echo -e "\n${MANG}ERROR : Issue while adding File to GITHUB !!" ; exit 1; }
    sleep 2

    echo -e "\n${YELL}>>> [+] Connection To Github Resporitory ...${NC}"
    sleep 2
    echo -e "\n${YELL}>>> [+] Checking Repository Status ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable, Check Your Network Connections !!${NC}"
        exit 1         
    fi
    git status || { echo -e "${MANG}ERROR : Couldn't Display Resporitory Status ${NC}" ; exit 1; }
    sleep 2 

    # >>> checking for previous commits firts
    if git diff --cached --quiet && git diff --quiet ; then 
        echo -e "\n${SKYB}>>> [-] No Changes to Commit.Proceed with Existing Commits${NC}"
        exit 1
    else
        echo -e "\n${YELL}>>> [+] Commiting The File To GitHub ...${NC}"
        git commit -m "Add Scripts Automatically" "$file_name" || { echo -e "\n${MANG}ERROR : Failed to commit the FILE${NC}" ; exit 1 ; }
    fi
    sleep 2
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}" 
        exit 1         
    fi
    echo -e "\n${YELL}>>> [+] Linking To GitHub Repository Name ...${NC}"
    if git remote get-url origin &>/dev/null; then
        git remote set-url origin https://github.com/"$username"/"$repository_name" || { echo -e "\n${MANG}Error : Couldn't Update Github Remote Url !!${NC}" ; exit 1; }
    else
        git remote add origin https://github.com/"$username"/"$repository_name" || { echo -e "\n${MANG}ERROR : Couldn't Link to GITHUB !!${NC}" ; exit 1; }
    fi
    sleep 2 
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then 
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}"
        exit 1        
    fi
    if ! git pull origin main --rebase ; then 
        git rebase --abort &> /dev/null 
        git merge --abort &> /dev/null
        rm -rf .git/MERGE_HEAD &> /dev/null
        echo -e "\n${YELL}>>> [-] Aborting Rebase and Exiting Safely.${NC}\n"
        exit 1   
    fi
    echo -e "\n${YELL}>>> [*] Pushing File For Backup ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then 
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable, Check Your Network Connections !!${NC}" 
        exit 1
    fi
    git push -u origin main || { echo -e "\n${MANG}ERROR : Couldn't Push File For Backup !!${NC}" ; exit 1; } 
    sleep 2
    echo -e "\n${YELL}>>> [+] $file_name Submitted to GitHub Successfully √${NC}"
    return 0
}

# >>> commit multiple files
commit_multiple_files(){
    local directory_path=$1
    while true; do
        if [[ -z "$directory_path" ]]; then 
            file_inputs " Enter File Name @ $file_path :" directory_path_checker "Enter a valid File Path" directory_path
        fi 
        if [[ ! -d "$directory_path" ]]; then
            echo -e "\n${MANG}DIRECTORY PATH DOESN'T EXIST !!${NC}\n"
            continue 
        fi 
        if [[ -z "$username" ]]; then
            file_inputs "\n>>> Enter GitHub Username :" file_name_checker "Enter a valid Username" username 
        fi
        if [[ -z "$repository_name" ]]; then
            file_inputs "\n>>> Enter GitHub Repository Name :" username_checker "Enter a valid Repository Name" repository_name
        fi
        break        
    done
    echo -e "\n${YELL}>>> [+] Moving & Checking File Availabe at : $directory_path${NC}"
    cd "$directory_path" || { echo -e "\n${MANG}ERROR : Issue while transitioning to : $directory_path${NC}" ; exit 1 ; }
    echo -e "\n${YELL}>>> [*] Initializing GitHub Connection ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}"
        exit 1         
    fi
    git init
    git branch -M main 
    sleep 2
    echo -e "${YELL}>>> [*] Adding Multiple Files ...${NC}"
    git add -v . || { echo -e "\n${MANG}ERROR : Issue while adding Multiple File${NC}" ; exit 1 ; }
    sleep 2
    echo -e "\n${YELL}>>> [*] Connection To Github Resporitory ...${NC}"
    sleep 2
    echo -e "\n${YELL}>>> [*] Checking Repository Status ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}" 
        exit 1        
    fi
    git status || { echo -e "${MANG}ERROR : Couldn't Display Resporitory Status ${NC}" ; exit 1; }
    sleep 2
    # >>> checking for previous commits firts 
    if git diff --cached --quiet && git diff --quiet ; then  
        echo -e "\n${SKYB}>>> [-] No Changes to Commit.Proceed with Existing Commits${NC}"
        exit 1
    else
        echo -e "\n${YELL}>>> [+] Commiting The File To GitHub ...${NC}" 
        git commit -m "Add Scripts Automatically" "$directory_path" || { echo -e "\n${MANG}ERROR : Failed to commit the FILE${NC}" ; exit 1 ; }        
    fi  
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then 
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable, Check Your Network Connections !!${NC}" 
        exit 1
    fi
    if git remote get-url origin &>/dev/null ; then
        git remote set-url origin https://github.com/"$username"/"$repository_name" || { echo -e "\n${MANG}ERROR : Couldn't Link to Github !!" ; exit 1; }
    else
        git remote add origin https://github.com/"$username"/"$repository_name" || { echo -e "\n${MANG}ERROR : Couldn't Link to GITHUB !!${NC}" ; exit 1; }
    fi
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}"
        exit 1        
    fi
    if ! git pull origin main --rebase ; then 
        echo -e "\n${MANG}Error : A File name at $directory_path caused a Conflict With the Remote Repository !!${NC}"
        git rebase --abort &> /dev/null
        git merge --abort &> /dev/null
        rm -rf .git/MERGE_HEAD &> /dev/null
        echo -e "\n${YELL}>>> [-] Aborting Rebase and Exiting Safely.${NC}\n"
        exit 1
    fi
    echo -e "\n${YELL}>>> [*] Pushing File For Backup ...${NC}"
    if ! curl -sI -m 5 --retry 3 https://github.com &> /dev/null; then
        echo -e "\n${MANG}>>> [!] ERROR : Network Unreachable,Check Your Network Connections !!${NC}"
        exit 1         
    fi
    git push -u origin main || { echo -e "\n${MANG}ERROR : Couldn't Push File For Back up !!${NC}" ; exit 1; }
    echo -e "\n${YELL}>>> [+] Files in $directory_path\n>>> [+] All Files Submitted to GitHub Successfully √${NC}"
    return 0
}  

# --------------------------------------------------
# GITHUB MENU OPTIONS & HANDLING USER INPUTS
# --------------------------------------------------

# >>> Handles continue option 
github_actions(){
    local file_data=$1
    local username=$2
    local repository_name=$3
    if [[ -n "$file_data" ]]; then 
        if [[ -f "$file_data" ]]; then
           commit_single_file "$file_data" "$username" "$repository_name"
           return 0
        fi
        if [[ -d "$file_data" ]]; then
            commit_multiple_files "$file_data" "$username" "$repository_name" 
            return 0
        fi
    fi
    local cont_opt
    file_inputs "\n>>> [+] Continue with ;\n>> 1: Commit Single File \n>> 2: Commit Multiple Files\n>> 0: Close Program\n\n" menu_options "Enter a valid input" cont_opt  
    case "$cont_opt" in
        1)
            commit_single_file "$file_data" "$username" "$repository_name" 
            return 0
            ;;
        2)
            commit_multiple_files "$file_data" "$username" "$repository_name"
            return 0
            ;;
        0) 
            echo -e "\n========= • GOOD • BYE ===========\n"  
            return 0
            ;;              
    esac     
}

# >>> Handles github operations
github_operations(){
    echo -e "\n============ • GITHUB • ============\n"
    local file_data=$1
    local username=$2
    local repository_name=$3
    if [[ -n "$file_data" ]]; then
        github_actions "$file_data" "$username" "$repository_name"
    else
        echo -e "\n${SKYB}>>> [+] PRO TIP :\n\n>> Run the Script\n./{Script_name} {file_name/file_path} {username} {repository_name}${NC}"
        github_actions
    fi
    return 0
}

# >>> Handles operations with arguments
github_operations "$file_data" "$username" "$repository_name"


