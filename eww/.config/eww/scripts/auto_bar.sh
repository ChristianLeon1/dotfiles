#!/bin/bash

launch_eww() {
    pkill eww
    
    sleep 0.3
    
    eww-wayland daemon
    eww-wayland open topbar

    MONITOR_COUNT=$(hyprctl monitors -j | jq length)

    if [ "$MONITOR_COUNT" -ge 2 ]; then
      sed -i '/:monitor 0/c\:monitor 1' ~/.config/eww/eww_sidebar.yuck 
        # Si hay 2 o más, abrimos la barra secundaria
        echo "Múltiples monitores detectados ($MONITOR_COUNT). Abriendo barra secundaria..."
        eww-wayland open topbar_sec
      else 
        echo "Solo un monitor detectado. Cerrando barra secundaria si está abierta..."
        sed -i '/:monitor 1/c\:monitor 0' ~/.config/eww/eww_sidebar.yuck  
        sleep 0.2
    fi

    eww-wayland open sidebar 
}

launch_eww

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    
    if [[ ${line:0:12} == "monitoradded" ]] || [[ ${line:0:14} == "monitorremoved" ]]; then
        echo "Cambio de monitor detectado ($line). Recargando barras..."
        launch_eww
    fi

done
