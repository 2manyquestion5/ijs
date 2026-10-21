#!/usr/bin/env bash

# Waybar battery aggregator
#
# PURPOSE: Combines available battery information for the bar’s custom battery widget.
# ROLE: Called by the Waybar JSONC configuration.
# CUSTOMIZATION: Verify battery naming and sysfs fields on a different machine.

base=/sys/class/power_supply

total_now=0
total_full=0

for bat in BAT0 BAT1; do
    if [ -f "$base/$bat/energy_now" ]; then
        now=$(cat "$base/$bat/energy_now")
        full=$(cat "$base/$bat/energy_full")
    else
        now=$(cat "$base/$bat/charge_now")
        full=$(cat "$base/$bat/charge_full")
    fi

    total_now=$((total_now + now))
    total_full=$((total_full + full))
done

percent=$((100 * total_now / total_full))

echo "$percent%"
