#!/usr/bin/env bash

# >>> handles getting user inputs
string_helper(){
    local prompt="$1"
    local condition_func="$2"
    local err_msg="$3"
    local -n output_val="$4"
    local input
    while true ; do
        read -rp $'\n>>> [+] '"$prompt" input
        if [[ -z "${condition_func}" ]] || "${condition_func}" "${input}" ; then
            output_val="${input}"
            return 0
        fi
        echo -e  "\n>>> [!] ${err_msg} !!" >&2
    done
}

# >>> handles user file name validity 
name_length_check_validity(){
    local str=$1
    if [[ -z "${str}" ]] || (( ${#str} <= 2 || ${#str} >= 50)); then
        return 1
    fi
    [[ "$str" =~ ^[a-zA-Z0-9._[:space:]-]+$ ]] 
}

# >>> handles creating python files 
python_file_create(){
    local file_name="$1"
    echo -e "\n>>> Creating PYTHON File named : $file_name"
    sleep 1
    echo -e "\n>>> Opening VIM Text Editor...\n"
    vim +'call append(0,"#!/usr/bin/env python3")' +'$' +startinsert "$file_name"
    echo -e "\n>>> [+] File : $file_name Was created & Saved Successfully"
    return 0
}

# >>> handles creating c files
c_file_create(){
    local file_name="$1"
    echo -e "\n>>> Creating C File named : $file_name"
    sleep 1
    echo -e "\n>>> Opening VIM Text Editor...\n"
    vim +'call append(0,"#include <stdio.h>")' +'$' +startinsert "$file_name"
    echo -e "\n>>> [+] File : $file_name Was created & Saved Successfully ✓"
    return 
}

# >>> handles creating c++ files
cpp_file_create(){
    local file_name="$1" 
    echo -e "\n>>> Creating C++ File named : $file_name"
    sleep 1 
    echo -e "\n>>> Opening VIM Text Editor...\n" 
    vim +'call append(0,"#include <iostream>")' +'$' +startinsert "$file_name" 
    echo -e "\n>>> [+] File : $file_name Was created & Saved Successfully ✓"
    return 
}

# >>> handles creating bash files
bash_file_create(){
    local file_name="$1"
    echo -e "\n>>> [+] Creating Bash File named :$file_name"
    sleep 1
    echo -e "\n>>> [+] Granting EXECUTABLE FILE PERMISSION..."
    chmod +x "$file_name" 
    sleep 1 
    echo -e "\n>>> [+] Opening VIM Text Editor..."
    sleep 2
    vim +'call append(0,"#!/usr/bin/env bash")' +'$' +startinsert "${file_name}" 
    echo -e "\n>>> [+] Re-Opening VIM Text Editor..."
    sleep 2
    /home/slim/bash/follow_up "${file_name}"
    echo -e "\n>>> [+] File : $file_name Was created & Saved Successfully √"
    return 
}

# >>> lets connect and check file if its exist
file_name_check(){
    local file_name="$1"
    while true ; do
        echo -e "\n============ • File Name • ============\n"
        if [[ -z "${file_name}" ]] ; then
            string_helper "Enter File Name :" name_length_check_validity "Enter a valid file name !!" file_name          
        fi
        if [[ -f "${file_name}" ]] ; then
            echo -e "\n>>> [!] Ooops there is file with same name !!\n"
            echo -e "\n>>> [*] Please Choose another name.\n"
            file_name=""
            continue            
        fi
        touch "$file_name" # -> creates the file
        case "$file_name" in 
            *.py)
                python_file_create "$file_name"
                break ;;
            *.c)
                c_file_create "$file_name"
                break ;;
            *.cpp)
                cpp_file_create "$file_name"
                break ;;
            *.sh | *)
                bash_file_create "$file_name"
                break ;;
        esac         
    done
    return 0
}

# >>> running the script
file_name_check "$1"







