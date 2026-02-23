#!/bin/bash

WORK_TIME=1500      # 25 minutos
BREAK_TIME=300      # 5 minutos (Descanso corto)
LONG_BREAK_TIME=900 # 15 minutos (Descanso largo)
SESSIONS_TARGET=3   # Cantidad de sesiones antes del descanso largo

# --- ARCHIVOS DE ESTADO ---
STATUS_FILE="/tmp/pomodoro_status"
TIMER_FILE="/tmp/pomodoro_timer"
PID_FILE="/tmp/pomodoro_pid"
MODE_FILE="/tmp/pomodoro_mode"       # work, break, long_break
SESSION_FILE="/tmp/pomodoro_sessions" # Guarda el número de sesión actual (0, 1, 2...)

# --- COMANDOS ---
SOUND_CMD="paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
# Ajusta ruta si es necesario
EWW_CMD="eww"

# --- FUNCIONES ---

update_display() {
    local T=$1
    local M=$((T / 60))
    local S=$((T % 60))
    printf -v PRETTY_TIME "%02d:%02d" $M $S
    
    local MODE=$(cat "$MODE_FILE" 2>/dev/null)
    [ -z "$MODE" ] && MODE="work"
    
    local SESSIONS=$(cat "$SESSION_FILE" 2>/dev/null)
    [ -z "$SESSIONS" ] && SESSIONS=0
    
    # Enviamos tiempo, modo y número de sesiones a Eww
    $EWW_CMD update pomodoro_display="$PRETTY_TIME"
    $EWW_CMD update pomodoro_mode="$MODE"
    $EWW_CMD update pomodoro_session="$SESSIONS"
}

timer_loop() {
    while true; do
        STATUS=$(cat "$STATUS_FILE" 2>/dev/null)
        TIME=$(cat "$TIMER_FILE" 2>/dev/null)
        MODE=$(cat "$MODE_FILE" 2>/dev/null)
        SESSIONS=$(cat "$SESSION_FILE" 2>/dev/null)

        # Valores por defecto iniciales
        [ -z "$TIME" ] && TIME=$WORK_TIME
        [ -z "$STATUS" ] && STATUS="stopped"
        [ -z "$MODE" ] && MODE="work"
        [ -z "$SESSIONS" ] && SESSIONS=0

        if [ "$STATUS" == "stopped" ]; then
            rm -f "$PID_FILE"
            exit 0
        elif [ "$STATUS" == "paused" ]; then
            sleep 1
            continue
        fi

        if [ "$TIME" -gt 0 ]; then
            TIME=$((TIME - 1))
            echo "$TIME" > "$TIMER_FILE"
            update_display "$TIME"
            sleep 1
        else
            # --- EL TIEMPO SE ACABÓ ---
            $SOUND_CMD &
            
            if [ "$MODE" == "work" ]; then
                # Terminó sesión de trabajo, incrementamos contador
                SESSIONS=$((SESSIONS + 1))
                echo "$SESSIONS" > "$SESSION_FILE"
                
                if [ "$SESSIONS" -ge "$SESSIONS_TARGET" ]; then
                    # TOCA DESCANSO LARGO
                    notify-send -u critical "Pomodoro" "¡Felicidades! $SESSIONS sesiones completadas. Descanso largo de 15 min."
                    echo "long_break" > "$MODE_FILE"
                    echo "$LONG_BREAK_TIME" > "$TIMER_FILE"
                    # Reiniciamos contador de sesiones después del ciclo largo
                    echo "0" > "$SESSION_FILE" 
                else
                    # TOCA DESCANSO CORTO
                    notify-send -u normal "Pomodoro" "Sesión $SESSIONS terminada. Descanso corto de 5 min."
                    echo "break" > "$MODE_FILE"
                    echo "$BREAK_TIME" > "$TIMER_FILE"
                fi
            else
                # Terminó cualquier descanso (corto o largo), vuelve al trabajo
                notify-send -u critical "Pomodoro" "Descanso terminado. ¡A trabajar!"
                echo "work" > "$MODE_FILE"
                echo "$WORK_TIME" > "$TIMER_FILE"
            fi
            
            sleep 1
        fi
    done
}

start_timer() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        return
    fi
    timer_loop &
    echo $! > "$PID_FILE"
}

toggle() {
    current=$(cat "$STATUS_FILE" 2>/dev/null)
    if [ "$current" == "running" ]; then
        echo "paused" > "$STATUS_FILE"
        $EWW_CMD update pomodoro_state="paused"
    else
        echo "running" > "$STATUS_FILE"
        $EWW_CMD update pomodoro_state="running"
        start_timer
    fi
}

reset() {
    echo "stopped" > "$STATUS_FILE"
    echo "work" > "$MODE_FILE"
    echo "0" > "$SESSION_FILE" # Resetear sesiones también
    echo "$WORK_TIME" > "$TIMER_FILE"
    
    update_display "$WORK_TIME"
    $EWW_CMD update pomodoro_state="stopped"
    
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
}

case "$1" in
    toggle) toggle ;;
    reset) reset ;;
esac
