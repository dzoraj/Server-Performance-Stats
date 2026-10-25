





#!/bin/bash

while true; do
    # 1Total CPU usage
    cpu_usage=$(top -b -n 1 | grep "%Cpu(s)" | awk '{print 100 - $8}')
    # echo -ne "Total cpu usage is: ${cpu_usage}%\r"
    echo -ne "\033[KTotal cpu usage is: ${cpu_usage}% \n"
    # 2Total memory usage (Free vs Used including percentage) 
    total_mem_usage=$(top -b -n 1 | grep "MiB Mem" | awk '{print ($8/$4) * 100}')
    total_mem_free=$(top -b -n 1 | grep "MiB Mem" | awk '{print ($6/$4) * 100}')
    echo -ne "\033[KTotal memory usage is: ${total_mem_usage}%\n"
    echo -ne "\033[KTotal free memory is: ${total_mem_free}%\n"    


    # 3Total disk usage (Free vs Used including percentage) 
    total_disk_usage=$(df -h / | grep "/dev/" | awk '{print $5}') #practically incorrect since a server in most cases has multiple disks
    total_disk_GB=$(df -h /| grep "/dev/" | awk '{print $2}')
    available_disk_GB=$(df -h /| grep "/dev/" | awk '{print $4}')
    echo -ne "\033[KTotal disk usage is: ${total_disk_usage}\n"
    echo -ne "\033[KTotal disk size is: ${total_disk_GB}\n"
    echo -ne "\033[KAvailable disk size is: ${available_disk_GB}\n"

    # 4Top 5 processes by CPU usage
    top_five_cpu_usage=$(ps aux --sort=-%cpu | head -6 | awk '{print $1 "\t" $2"\t" $3 "\t" $11}')
    echo -ne "\033[K${top_five_cpu_usage}\n"

    # 5Top 5 processes by memory usage
    top_five_mem_usage=$(ps aux --sort=-%mem | head -6 | awk '{print $1 "\t" $2"\t" $4 "\t" $11}')
    echo -ne "\033[K${top_five_mem_usage}\n"


    echo -e "\033[18A\r\c"
    sleep 2
done
