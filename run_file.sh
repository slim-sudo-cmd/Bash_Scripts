#!/usr/bin/env bash

# >>> Version 1.1r 
# >>> Runs file i.e python,C,C++,Bash and Assembly
# >>> Makefile is its dependency file 

# ===============================
# COLOR CODE
# ==============================
RED='\033[0;31m'
MANG='\033[1;35m'
SKYB='\033[1;36m'
NC='\033[0;0m' # -> reset if no color printed
# >>> handles user inputs
input_handler(){
    local prompt=$1
    local condition_func=$2
    local err_msg=$3
    local -n output_val=$4
    local input
    while true ; do 
        read -rp $'\n'">>> [+] $prompt" input
        if [[ -z "$condition_func" ]] || "$condition_func" "$input" ;then 
            output_val="$input"
            return 0
        fi
        echo -e "$MANG\n>>> [!] ${err_msg} !! ${NC}\n" 
    done
}

# >>> handles strings inputs
str_input_handler(){
    local str=$1
    [[ "$str" =~ ^[a-zA-Z0-9._[:space:]-]+$ ]] && (( ${#str} -ge 3 && ${#str} -le 15 ))
}

# >>> handles integer inputs 
int_input_handler(){
    local ints=$1
    (( ints >= 0 && ints <= 3 )) 
}

# ============================
# HOME
# ============================

# >>> handles home intro
home_intro(){
    echo -e "\n============ • Run • File • ============\n"
    local file_name=$1
    local file
    if [[ -z "$file_name" ]] ;then         
        input_handler "Enter File Name :" str_input_handler "Enter a valid file Name" file_name 
    fi
    case "$file_name" in  
        *.py)
            echo -e "\n>>> [*] PYTHON File Detected ✓\n\n>>> [+] Initiating PYFLAKES Debugger ..."
            sleep 1
            pyflakes3 "$file_name" 2>&1  || { echo -e "\n>>> [!] Oops Pyflakes initiation FAILED !!" ; exit 1; }
            echo -e "\n>>> [+] Initiationg COMPILER...Runnin....\n"
            sleep 1
            python3 "$file_name" || { echo -e "$MANG\n>>> [!] Oops Compiling Issues ! ${NC}\n" ; exit 1; }
            ;;
        *.c)
            echo -e "\n>>> [*] C File Detected ✓\n\n>>> [+] Initiating Gcc Compiler...\n"
            sleep 1
            make -f /home/slim/bash/Makefile valgrind_c c="$PWD/$file_name" || { echo -e "$MANG\n>>> [!] Gcc ran to a Problem !!${NC}\n" ; exit 1; }
            ;;
        *.cpp)
            echo -e "\n>>> [*] C++ File Detected ✓\n\n>>> [+] Initiating G++ Compiler...\n"
            sleep 1
            make -f /home/slim/bash/Makefile valgrind_cpp cpp="$PWD/$file_name"  || { echo -e "${MANG}\n>>> [!] Gcc ran to a Problem !! ${NC}" ; exit 1; };;
        *.s)
            echo -e "\n>> [+] Assembly File Detected ✓\n\n>>> [+] Initiating Gcc Compiler for Assembly..."
            sleep 1
            target_base=$(basename "$file_name" .s)
            make -f /home/slim/bash/Makefile run_asm asm="$PWD/$file_name" TARGET="$target_base" || { echo -e "${MANG}>>> [!] Gcc for Assembly ran to a Problem !!${NC}" ; exit 1;} ;;
        *.sh|*)
            echo -e "\n>>> [*] BASH File Detected ✓\n\n>>> [+] Initializing Bash Checker"
            if  bash -n "$file_name" ==  0  ;then
                echo -e "\n${SKYB}>>> [√] Syntax Bugs: 0 ${NC}"
                ./"$file_name"
            fi
    esac
}


# >>> Handles file name arguments
home_intro "$1"


