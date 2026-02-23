#!/bin/bash

WALL_STATIC="$HOME/Documentos/WallPapers/fondo.png"
WALL_VIDEO="$HOME/Documentos/WallPapers/fondo.mp4"

# --- OPCIONES DEL MENÚ (Iconos + Texto) ---
OP_NORMAL="Modo Normal"
OP_JUEGO="Modo Juego"
OP_AHORRO="Ahorro de Energía"

# --- LANZAR ROFI ---
# Muestra el menú y guarda la elección en la variable CHOICE
CHOICE=$(echo -e "$OP_NORMAL\n$OP_JUEGO\n$OP_AHORRO" | rofi -dmenu -i -p "Modo de Sistema:")

# --- LÓGICA DE SELECCIÓN ---
case "$CHOICE" in
    "$OP_AHORRO")
        notify-send -u low "Modo Ahorro de Energía" 
        
        hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1"
        killall mpvpaper
        swww img "$WALL_STATIC" --transition-type simple
        
        hyprctl keyword decoration:shadow:enabled 0
        hyprctl keyword animations:enabled 0
        
        powerprofilesctl set power-saver
        ;;
        
    "$OP_NORMAL")
        notify-send -u normal "Modo Normal" 
        
        hyprctl keyword monitor "eDP-1, 1920x1080@144, 0x0, 1"
        hyprctl keyword decoration:shadow:enabled 1
        hyprctl keyword animations:enabled 1
        sleep 0.5
        swww img "$WALL_STATIC" --transition-type simple
        powerprofilesctl set balanced
        ;;
        
    "$OP_JUEGO")
        notify-send -u critical "Modo Juego"
        
        hyprctl keyword monitor "eDP-1, 1920x1080@144, 0x0, 1"
        
        killall mpvpaper
        swww img "$WALL_STATIC" --transition-type simple
        
        hyprctl keyword decoration:shadow:enabled 0
        hyprctl keyword animations:enabled 1
        powerprofilestl set performance
        ;;
esac
