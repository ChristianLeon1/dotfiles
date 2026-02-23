#!/bin/bash

# Función para obtener temperatura y uso de una tarjeta específica
get_gpu_data() {
    CARD_ID=$1
    
    # Verificamos si la tarjeta existe
    if [ -d "/sys/class/drm/$CARD_ID" ]; then
        
        # 1. USO (%)
        if [ -r "/sys/class/drm/$CARD_ID/device/gpu_busy_percent" ]; then
            usage=$(cat /sys/class/drm/$CARD_ID/device/gpu_busy_percent)
        else
            usage="0"
        fi

        # 2. TEMPERATURA
        temp_path=$(find /sys/class/drm/$CARD_ID/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1)
        
        if [ -f "$temp_path" ]; then
            temp_raw=$(cat "$temp_path")
            temp=$((temp_raw / 1000))
        else
            temp="--"
        fi
        
        echo "$temp \t$usage %"

    else
        echo "N/A"
    fi
}

# --- CONFIGURACIÓN ---
# Normalmente card0 es la integrada y card1 la dedicada.
# Si ves que los valores están al revés en tu barra, invierte estas variables.
CARD_INT="card2"
CARD_DED="card1"

# Obtenemos los datos
DATA_INT=$(get_gpu_data $CARD_INT)
DATA_DED=$(get_gpu_data $CARD_DED)

# Imprimimos el formato final
# Ejemplo: "INT 40°C 5%  |  RX 0°C 0%"
echo "  $DATA_INT \t 󰢮   $DATA_DED"
