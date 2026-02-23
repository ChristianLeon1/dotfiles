#!/bin/bash

# Forzar idioma inglés para que el grep funcione siempre
export LANG=C

# 1. Revisar si está encendido
# Busca "Powered: yes" en la configuración
POWER=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$POWER" ]; then
    echo "off"
    exit 0
fi

# 2. Revisar si hay algo conectado
# Busca "Connected: yes" en la info del dispositivo actual
if bluetoothctl info | grep -q "Connected: yes"; then
    echo "connected"
else
    echo "on"
fi
