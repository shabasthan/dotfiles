#!/usr/bin/env bash

# Calculate CPU usage as an integer
usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%d", 100 - $8}')

# Fetch load average
load=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)

# Fetch CPU frequency
freq=$(lscpu 2>/dev/null | grep "CPU MHz" | head -n1 | awk '{printf "%.1f", $3/1000}')

if [ -n "$freq" ]; then
    tooltip="CPU Usage: ${usage}%\nAvg Frequency: ${freq}GHz\nLoad Average: ${load}"
else
    tooltip="CPU Usage: ${usage}%\nLoad Average: ${load}"
fi

# Output JSON for Waybar
printf '{"text": "%d%% 󰍛", "tooltip": "%s"}\n' "$usage" "$tooltip"
