export LANG=C

# Obtenemos info
INFO=$(acpi -b)
# Extraemos solo la hora (ej: 02:30)
TIME=$(echo "$INFO" | grep -o "[0-9][0-9]:[0-9][0-9]")

if [[ "$INFO" == *"Discharging"* || "$INFO" == *"Charging"* ]]; then
    # Si está descargando, mostrar solo el tiempo o "..." si calculando
    if [ -n "$TIME" ]; then
        echo "$TIME"
    fi
else
    # Si está al 100% o conectada sin cargar
    echo "Full" 
fi
