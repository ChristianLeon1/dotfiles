#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# AÑO: 2026 CREADOR: Ramírez León Christian Yael

import sys

import dbus


def truncate(text, max_len=35):
    """Corta el texto si es muy largo para que no rompa la barra"""
    if len(text) > max_len:
        return text[:max_len] + "..."
    return text


try:
    session_bus = dbus.SessionBus()
    spotify_bus = session_bus.get_object(
        "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2"
    )

    spotify_properties = dbus.Interface(spotify_bus, "org.freedesktop.DBus.Properties")

    # Obtener metadatos y estado
    metadata = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "Metadata")
    status = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus")

    # Extraer Artista y Canción
    # xesam:artist es una lista, tomamos el primero
    artist = metadata.get("xesam:artist", ["Desconocido"])[0]
    title = metadata.get("xesam:title", "Desconocido")

    # Formato de salida
    if status == "Playing":
        output = f"{artist} - {title}"
    elif status == "Paused":
        output = f"(Pausa) {artist} - {title}"
    else:
        output = ""

    # Imprimir resultado truncado
    print(truncate(output))

except Exception:
    # Si Spotify está cerrado o hay error de DBus
    print("Offline")
