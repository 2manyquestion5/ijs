#!/usr/bin/env bash

# Waybar network traffic
#
# PURPOSE: Detects the current default interface and formats network counters.
# ROLE: Used by the custom network module in Waybar.
# CUSTOMIZATION: Interface selection may differ on hosts with multiple active routes.

iface=$(ip route | awk '/default/ {print $5; exit}')

[ -z "$iface" ] && {
    echo "↑ 0  ↓ 0"
    exit
}

rx_file="/sys/class/net/$iface/statistics/rx_bytes"
tx_file="/sys/class/net/$iface/statistics/tx_bytes"

state="/tmp/waybar-network-$iface"

rx=$(cat "$rx_file")
tx=$(cat "$tx_file")
now=$(date +%s)

if [ -f "$state" ]; then
    read old_rx old_tx old_time < "$state"

    elapsed=$((now - old_time))
    [ "$elapsed" -lt 1 ] && elapsed=1

    down=$(( (rx - old_rx) / elapsed ))
    up=$(( (tx - old_tx) / elapsed ))
else
    down=0
    up=0
fi

echo "$rx $tx $now" > "$state"

human() {
    value=$1

    if [ "$value" -ge 1048576 ]; then
        awk "BEGIN {printf \"%.1fM\", $value / 1048576}"
    elif [ "$value" -ge 1024 ]; then
        awk "BEGIN {printf \"%.0fK\", $value / 1024}"
    else
        printf "%dB" "$value"
    fi
}

printf "↑ %s  ↓ %s\n" "$(human "$up")" "$(human "$down")"
