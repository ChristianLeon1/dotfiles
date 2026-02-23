#!/bin/bash

# Variables para controlar que no te spamee la notificación
NOTIFIED_20=false
NOTIFIED_10=false

sleep 5  

while true; do
    BAT_PATH=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)

    if [ -z "$BAT_PATH" ]; then
        sleep 60
        continue
    fi

    CAPACITY=$(cat "$BAT_PATH/capacity")
    STATUS=$(cat "$BAT_PATH/status")

    if [ "$STATUS" = "Charging" ]; then
        NOTIFIED_20=false
        NOTIFIED_10=false
    else
        if [ "$CAPACITY" -le 20 ] && [ "$CAPACITY" -gt 10 ]; then
            if [ "$NOTIFIED_20" = "false" ]; then
                notify-send -u critical "🔋 Batería Baja" "Nivel al $CAPACITY%. Ve buscando el cargador."
                NOTIFIED_20=true
                sleep 1
            fi
        fi

        if [ "$CAPACITY" -le 10 ]; then
            if [ "$NOTIFIED_10" = "false" ]; then
                notify-send -u critical "⚡ BATERÍA CRÍTICA" "Iniciando el modo de ahorro de energía. Nivel al $CAPACITY%." 
                hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1"
                killall mpvpaper
                swww img "$WALL_STATIC" --transition-type simple
            
                hyprctl keyword decoration:shadow:enabled 0
                hyprctl keyword animations:enabled 0
            
                powerprofilesctl set power-saver

                NOTIFIED_10=true
            fi
        fi
    fi

    sleep 60
done

