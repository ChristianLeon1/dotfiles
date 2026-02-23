#!/bin/bash

echo "["
first=true

# Iterar sobre todas las tarjetas gráficas detectadas por el sistema
for card in /sys/class/drm/card[0-9]*; do
    # Verificar si es una carpeta válida
    [ -e "$card/device" ] || continue

    # Obtener el Vendor ID (0x1002 es AMD)
    vendor=$(cat "$card/device/vendor" 2>/dev/null)
    
    # Si es AMD (0x1002), procedemos
    if [[ "$vendor" == "0x1002" ]]; then
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        # 1. Obtener Nombre (A veces es un código, intentamos limpiarlo)
        # Usamos 'uevent' para sacar el nombre del driver o subsistema si product_name falla
        if [ -f "$card/device/product_name" ]; then
            name=$(cat "$card/device/product_name" | sed 's/AMD Radeon //g' | sed 's/ Graphics//g')
        else
            name="AMD GPU"
        fi

        # 2. Uso (%) - El driver amdgpu expone 'gpu_busy_percent'
        usage=0
        if [ -f "$card/device/gpu_busy_percent" ]; then
            usage=$(cat "$card/device/gpu_busy_percent")
        fi

        # 3. Memoria VRAM (Vienen en bytes, convertimos a MB)
        mem_used=0
        mem_total=0
        if [ -f "$card/device/mem_info_vram_used" ]; then
            used_bytes=$(cat "$card/device/mem_info_vram_used")
            mem_used=$((used_bytes / 1024 / 1024))
        fi
        if [ -f "$card/device/mem_info_vram_total" ]; then
            total_bytes=$(cat "$card/device/mem_info_vram_total")
            mem_total=$((total_bytes / 1024 / 1024))
        fi

        # 4. Temperatura (Busca dentro de la carpeta hwmon asociada)
        # Nota: Divide por 1000 porque viene en miligrados
        temp=0
        hwmon=$(find "$card/device/hwmon" -name "temp1_input" -print -quit 2>/dev/null)
        if [ -n "$hwmon" ]; then
            raw_temp=$(cat "$hwmon")
            temp=$((raw_temp / 1000))
        fi

        # Imprimir JSON para Eww
        printf '{"name": "%s", "usage": %d, "temp": %d, "mem_used": %d, "mem_total": %d}' \
            "$name" "$usage" "$temp" "$mem_used" "$mem_total"
    fi
done

echo "]"
