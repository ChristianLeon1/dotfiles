#!/usr/bin/env bash

uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi"

# Options
shutdown="󰐥  Shutdown"
reboot="  Restart"
lock="  Lock"
suspend="󰒲  Sleep"
logout="󰍃  Logout"

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# echo "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0
chosen="$(echo "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"

case $chosen in
    $shutdown)
      eval "systemctl poweroff"
      ;;
    $reboot)
      eval "systemctl reboot"
      ;;
    $lock)
      pidof hyprlock || hyprlock
      ;;
    $suspend)
      eval 'sleep 1 && systemctl suspend'
      ;;
    $logout)
      eval "hyprctl dispatch exit"
      ;;
esac
