#!/bin/bash

printf "%-8s %-6s %-10s %-25s %-15s\n" "TYPE" "ID" "STATUS" "NAME" "IP ADDRESS"
echo "-------------------------------------------------------------------------"

# 1. Gather VMs (QEMU): qm list format is ID | NAME | STATUS
qm list | awk 'NR>1 {print "VM|" $1 "|" $3 "|" $2}' > /tmp/pve_resources.tmp

# 2. Gather Containers (LXC): pct list format is ID | STATUS | NAME
pct list | awk 'NR>1 {print "LXC|" $1 "|" $2 "|" $3}' >> /tmp/pve_resources.tmp

# Process all resources
cat /tmp/pve_resources.tmp | while IFS="|" read -r type vmid status name; do

    if [ "$status" = "running" ]; then
        display_status="Started"

        if [ "$type" = "VM" ]; then
            # Query QEMU Guest Agent for VMs
            ip=$(timeout 2 pvesh get /nodes/localhost/qemu/$vmid/agent/network-get-interfaces --output-format json 2>/dev/null \
                | jq -r '(.result // .)[]? | .["ip-addresses"][]? | select(.["ip-address-type"]=="ipv4") | .["ip-address"]' \
                | grep -v "127.0.0.1" \
                | head -n 1)

            if [ -z "$ip" ]; then
                ip="No Agent/IP"
            fi

        elif [ "$type" = "LXC" ]; then
            # Query LXC networking directly via pct exec
            ip=$(timeout 2 pct exec "$vmid" -- ip -4 addr show 2>/dev/null \
                | awk '/inet / {print $2}' \
                | cut -d/ -f1 \
                | grep -v "127.0.0.1" \
                | head -n 1)

            if [ -z "$ip" ]; then
                ip="No IP Found"
            fi
        fi

    else
        display_status="off"
        ip="N/A"
    fi

    printf "%-8s %-6s %-10s %-25s %-15s\n" "$type" "$vmid" "$display_status" "$name" "$ip"

done

# Clean up
rm -f /tmp/pve_resources.tmp