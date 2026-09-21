#!/bin/sh
current_hostname=$(hostname)
current_user=$(whoami)
current_date_time=$(date +"%F %T")
device_operating_system=$(uname -s)
device_kernel_version=$(uname -r)
device_uptime=$(uptime | awk -F'up' '{print $2}' | cut -d',' -f1)
device_cpu_information=$(nproc)
device_memory_information=$(free -h)
current_working_directory=$(pwd)

system_information(){
    echo "Hostname: $current_hostname"
    echo "User: $current_user"
    echo "Date and Time: $current_date_time"
    echo "Operating System: $device_operating_system"
    echo "Kernel Version: $device_kernel_version"
    echo "Uptime: $device_uptime"
    echo "Memory Information: $device_memory_information"
    echo "Working Directory: $current_working_directory"
    echo "CPU Count: $device_cpu_information"
}

network_information(){
    HOST_NAME=$2

    if [ -z "$HOST_NAME" ]; then
        echo "Error: host cannot be empty." >&2
        exit 2
    fi

    if ! command -v getent >/dev/null 2>&1; then
        echo "Error: getent is required to resolve hosts." >&2
        exit 1
    fi

    resolved_addresses=$(getent ahosts "$HOST_NAME" 2>/dev/null)
    if [ -z "$resolved_addresses" ]; then
        echo "Failed to resolve host: $HOST_NAME" >&2
        exit 1
    fi

    ip_address=$(printf '%s\n' "$resolved_addresses" | awk 'NR == 1 { print $1 }')
    echo "Resolved address for $HOST_NAME: $ip_address"

    if ! command -v ping >/dev/null 2>&1; then
        echo "Error: ping is unavailable." >&2
        exit 1
    fi

    if ping -c 1 -W 2 "$HOST_NAME" >/dev/null 2>&1; then
        echo "Connectivity check: reachable"
    else
        echo "Connectivity check: unreachable"
        exit 1
    fi

    exit 0
}

network_information_port(){
    

    HOST_NAME=$2
    PORT=$3

    if [ -z "$HOST_NAME" ]; then
        echo "Error: host cannot be empty." >&2
        exit 2
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Error: port must be a number from 1 to 65535." >&2
        exit 2
    fi


    if ! command -v getent >/dev/null 2>&1; then
        echo "Error: getent is required to resolve hosts." >&2
        exit 1
    fi

    resolved_addresses=$(getent ahosts "$HOST_NAME" 2>/dev/null)
    if [ -z "$resolved_addresses" ]; then
        echo "Failed to resolve host: $HOST_NAME" >&2
        exit 1
    fi

    ip_address=$(printf '%s\n' "$resolved_addresses" | awk 'NR == 1 { print $1 }')
    echo "Resolved address for $HOST_NAME: $ip_address"

    if ! command -v ping >/dev/null 2>&1; then
        echo "Error: ping is unavailable." >&2
        exit 1
    fi

    if ping -c 1 -W 2 "$HOST_NAME" >/dev/null 2>&1; then
        echo "Connectivity check: reachable"
    else
        echo "Connectivity check: unreachable"
        exit 1
    fi

    if ! command -v ip >/dev/null 2>&1; then
        echo "Error: ip is unavailable." >&2
        exit 1
    fi

    echo "Network interfaces:"
    ip -brief address

    if [ "$#" -ge 3 ]; then
        if ! command -v nc >/dev/null 2>&1; then
            echo "Error: nc is required for TCP port checks." >&2
            exit 1
        fi

        if nc -z -w 3 "$HOST_NAME" "$PORT" >/dev/null 2>&1; then
            echo "TCP connectivity to port $PORT: open"
        else
            echo "TCP connectivity to port $PORT: unavailable"
            exit 1
        fi
    fi
}

help(){
    echo "Usage: $0 {system|network|disk|help}"
    echo "system: Display system information"
    echo "network <host>: Check network connectivity to a host"
    echo "disk: Display disk usage information"
}

case "$1" in
    "system-info")
        system_information
        ;;
    "check-host")
        network_information "$@"
        ;;
    "check-port")
        network_information_port "$@" 
        ;;
    "help")
        help
        ;;
    *)
        echo "Invalid option. Please use proper arguments. Use the help argument to properly check"
        exit 2
        ;;
esac