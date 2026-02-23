#!/bin/bash

# Busca si hay algo conectado
if bluetoothctl info | grep -q "Connected: yes"; then
    # Si sí, extrae el "Alias" (nombre amigable)
    bluetoothctl info | grep "Alias" | cut -d ' ' -f 2-
else
    # Si no, no imprime nada (vacío)
    echo ""
fi
