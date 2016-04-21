#!/bin/bash

# kptr_restrict / prevents reading kern symbols / cat /proc/kallsyms
# dmesg_restrict / prevents dmesg
# smep  / cat /proc/cpuinfo
# smap  / 
# kaslr /  
# physmap executable / check architecture. 32-bit kernels have non-executable physmaps. 
# NULL memory mapping  / sysctl -a | grep mmap_min_addr

printf "Kerncheck v 1.0 by rh0gue\n\n"

if [[ $(cat /proc/sys/kernel/kptr_restrict) -eq 0 ]]; then 
        echo -n -e "\033[31m[+] kallsyms enabled\033[m\n"
        prepare_kernel_cred=$(cat /proc/kallsyms | awk '/ prepare_kernel_cred/ {print $1}') 
        commit_cred=$(cat /proc/kallsyms | awk '/ commit_creds/ {print $1}') 
        echo -n -e "\033[33m    prepare_kernel_cred resolved at 0x"$prepare_kernel_cred"\033[m\n"
        echo -n -e "\033[33m    commit_creds resolved at 0x"$commit_cred"\033[m\n"
else 
        echo -n -e "\033[32m[+] kallsyms disabled\033[m\n"
fi
 
if [[ $(cat /proc/sys/kernel/dmesg_restrict) -eq 0 ]]; then 
        echo -n -e "\033[31m[+] dmesg enabled\033[m\n" 
else 
        echo -n -e "\033[32m[+] dmesg disabled\033[m\n"
fi

if [[ $(cat /proc/cpuinfo | grep smep)  ]]; then 
        echo -n -e "\033[32m[+] SMEP enabled\033[m\n" 
else 
        echo -n -e "\033[31m[+] SMEP disabled\033[m\n"
fi

if [[ $(cat /proc/cpuinfo | grep smap)  ]]; then 
        echo -n -e "\033[32m[+] SMAP enabled\033[m\n" 
else 
        echo -n -e "\033[31m[+] SMAP disabled\033[m\n" 
fi

if [[ $(sysctl -a 2> /dev/null| awk '/mmap_min_addr/ {print $3}') -ne 0 ]]; then 
        echo -n -e "\033[32m[+] NULL memory mapping protection enabled\033[m\n" 
else 
        echo -n -e "\033[31m[+] NULL memory mapping protection disabled\033[m\n" 
fi
