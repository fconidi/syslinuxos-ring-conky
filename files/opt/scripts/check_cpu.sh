#!/bin/bash

# Detect CPU thread count
cpu=$(grep -c processor /proc/cpuinfo)

# Detect active network interface: prefer default-route iface, else first non-loopback UP
iface=$(ip route show default 2>/dev/null | awk '/^default/ {print $5; exit}')
if [ -z "$iface" ]; then
    iface=$(ip -o link show up 2>/dev/null | awk -F': ' '$2 != "lo" {print $2; exit}')
fi

if [ -f /opt/Sys-ring-conky/settings.lua ]; then
    sed -i "s/cpu_cores = [0-9]\+/cpu_cores = $cpu/" /opt/Sys-ring-conky/settings.lua
    if [ -n "$iface" ]; then
        sed -i "s/net_interface = \"[^\"]*\"/net_interface = \"$iface\"/" /opt/Sys-ring-conky/settings.lua
    fi
    echo "Ring conky settings updated: cpu_cores=$cpu, net_interface=${iface:-unchanged}."
else
    echo "Error: settings file not found at /opt/Sys-ring-conky/settings.lua."
fi
