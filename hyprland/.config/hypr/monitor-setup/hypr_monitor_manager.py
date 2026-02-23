#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import subprocess
import time

# -------------------------------------------
#   Configuración Global
# -------------------------------------------
WALLPAPER_CMD = ['swww', 'img', '/home/enigma/Documentos/WallPapers/wall_gemini.png', '--transition-type', 'simple']

# -------------------------------------------
#   Nueva Función de Notificación
# -------------------------------------------
def notify(message, title="Display Manager", urgency="normal"):
    """
    Envía una notificación al sistema usando notify-send.
    urgency: 'low', 'normal', 'critical'
    """
    try:
        # -u: urgencia, -t: tiempo en ms (3000ms = 3s)
        subprocess.run(['notify-send', '-u', urgency, '-t', '3000', title, message])
    except FileNotFoundError:
        # Si no tiene notify-send, hacemos fallback a print para no romper el script
        print(f"[{title}] {message}")

# -------------------------------------------
#   Helpers (Rofi & Hyprland)
# -------------------------------------------

def run_cmd(cmd_list):
    try:
        result = subprocess.run(cmd_list, capture_output=True, text=True)
        return result.stdout.strip()
    except Exception as e:
        notify(f"Error ejecutando comando: {e}", urgency="critical")
        return ""

def rofi_menu(options: list, prompt: str, lines=None, custom_input=False):
    cmd = ['rofi', '-dmenu', '-p', prompt, '-i']
    if lines:
        cmd.extend(['-l', str(lines)])
    
    input_str = '\n'.join([str(x) for x in options])
    
    try:
        result = subprocess.run(cmd, input=input_str, capture_output=True, text=True)
    except FileNotFoundError:
        notify("Rofi no está instalado", urgency="critical")
        return None
    
    selection = result.stdout.strip()
    if result.returncode != 0:
        return None
    
    if selection in options or custom_input:
        return selection
    return None

def get_monitors_data():
    try:
        output = run_cmd(['hyprctl', 'monitors', 'all', '-j'])
        data = json.loads(output)
        
        monitors_dict = {}
        for m in data:
            name = m['name']
            monitors_dict[name] = {
                'id': m['id'],
                'current_res': f"{m['width']}x{m['height']}@{m['refreshRate']:.2f}Hz",
                'current_pos': f"{m['x']}x{m['y']}",
                'current_scale': m['scale'],
                'transform': m['transform'],
                'available_modes': m['availableModes'],
                'description': f"{m['make']} {m['model']}",
                'width': m['width'],
                'height': m['height']
            }
        return monitors_dict
    except Exception as e:
        notify(f"Error leyendo monitores: {e}", urgency="critical")
        return {}

def apply_config(config_dict):
    """
    Aplica la configuración y notifica al usuario.
    """
    cmds = []
    changes_summary = []

    for mon, cfg in config_dict.items():
        if not cfg['enabled']:
            cmds.append(f"hyprctl keyword monitor '{mon}, disable'")
            changes_summary.append(f"{mon}: OFF")
            continue
            
        res = cfg['res'].replace("Hz", "")
        base_cmd = f"hyprctl keyword monitor '{mon}, {res}, {cfg['pos']}, {cfg['scale']}'"
        
        if cfg.get('transform') is not None and cfg.get('transform') != 0:
            base_cmd = f"{base_cmd}, transform, {cfg['transform']}"
            
        cmds.append(base_cmd)
        changes_summary.append(f"{mon}: {res}")

    # Ejecutar comandos
    for cmd in cmds:
        subprocess.run(cmd, shell=True)
    
    # Notificación final (En lugar de print por cada comando)
    notify(f"Configuración aplicada:\n" + "\n".join(changes_summary), urgency="normal")
    
    # Restaurar wallpaper
    time.sleep(0.5)
    try:
        subprocess.run(WALLPAPER_CMD, check=False)
    except Exception:
        pass

# -------------------------------------------
#   Lógica Avanzada de Posicionamiento
# -------------------------------------------

def calculate_relative_pos(target_pos_str, target_res_str, relation):
    try:
        t_x, t_y = map(int, target_pos_str.split('x'))
        res_part = target_res_str.split('@')[0]
        t_w, t_h = map(int, res_part.split('x'))
        
        if relation == 'same-as': return f"{t_x}x{t_y}"
        elif relation == 'right-of': return f"{t_x + t_w}x{t_y}"
        elif relation == 'left-of': return f"{t_x - t_w}x{t_y}"
        elif relation == 'below': return f"{t_x}x{t_y + t_h}"
        elif relation == 'above': return f"{t_x}x{t_y - t_h}"
        return "0x0"
    except:
        return "0x0"

# -------------------------------------------
#   Menú de Configuración Avanzada
# -------------------------------------------

def advanced_config_menu(connected_monitors):
    config_buffer = {}
    mon_data = get_monitors_data()
    
    for m in connected_monitors:
        curr = mon_data.get(m, {})
        config_buffer[m] = {
            'enabled': True,
            'res': curr.get('current_res', 'preferred'),
            'pos': curr.get('current_pos', '0x0'),
            'scale': str(curr.get('current_scale', '1')),
            'transform': curr.get('transform', 0)
        }

    while True:
        options = ["== SAVE & APPLY ==", "== EXIT =="] + [f"Edit: {m}" for m in connected_monitors]
        sel = rofi_menu(options, "Advanced Config > Select Monitor:")
        
        if not sel: break
        if sel == "== EXIT ==": return None
        if sel == "== SAVE & APPLY ==": 
            save_option = rofi_menu(['Yes', 'No'], "Save to file?")
            if save_option == 'Yes':
                save_config_to_json(config_buffer)
            return config_buffer

        target_mon = sel.replace("Edit: ", "")
        
        while True:
            c = config_buffer[target_mon]
            status_str = "ON" if c['enabled'] else "OFF"
            
            menu_opts = [
                f"Status: [{status_str}]",
                f"Resolution: [{c['res']}]",
                f"Position: [{c['pos']}]",
                f"Scale: [{c['scale']}]",
                f"Transform: [{c['transform']}]",
                "Back"
            ]
            
            attr_sel = rofi_menu(menu_opts, f"Configuring {target_mon}:")
            if not attr_sel or attr_sel == "Back": break
            
            if "Status:" in attr_sel:
                s = rofi_menu(['ON', 'OFF'], "Set Status:")
                if s: config_buffer[target_mon]['enabled'] = (s == 'ON')
            elif "Resolution:" in attr_sel:
                modes = mon_data.get(target_mon, {}).get('available_modes', [])
                clean_modes = [x.split()[0] for x in modes]
                if not clean_modes: clean_modes = ["preferred", "1920x1080@60", "1600x900@60"]
                r = rofi_menu(clean_modes, "Select Resolution:")
                if r: config_buffer[target_mon]['res'] = r
            elif "Position:" in attr_sel:
                pos_opts = ["0x0 (Origin)", "Manual Input"]
                others = [x for x in connected_monitors if x != target_mon]
                for o in others:
                    pos_opts.extend([f"Right of {o}", f"Left of {o}", f"Same as {o}"])
                
                p = rofi_menu(pos_opts, "Select Position:")
                if p:
                    if "Origin" in p: config_buffer[target_mon]['pos'] = "0x0"
                    elif "Manual" in p:
                        man = rofi_menu([], "Type XxY:", custom_input=True)
                        if man: config_buffer[target_mon]['pos'] = man
                    elif "Right of" in p:
                        ref_mon = p.replace("Right of ", "")
                        config_buffer[target_mon]['pos'] = calculate_relative_pos(config_buffer[ref_mon]['pos'], config_buffer[ref_mon]['res'], 'right-of')
                    elif "Left of" in p:
                        notify("Nota: Para 'Left-of' asegúrate de no solapar coordenadas negativas.", urgency="low")
                        ref_mon = p.replace("Left of ", "")
                        config_buffer[target_mon]['pos'] = calculate_relative_pos(config_buffer[ref_mon]['pos'], config_buffer[target_mon]['res'], 'left-of')
                    elif "Same as" in p:
                        ref_mon = p.replace("Same as ", "")
                        config_buffer[target_mon]['pos'] = config_buffer[ref_mon]['pos']

            elif "Scale:" in attr_sel:
                sc = rofi_menu(['1', '1.25', '1.5', '0.8'], "Select Scale:", custom_input=True)
                if sc: config_buffer[target_mon]['scale'] = sc
            elif "Transform:" in attr_sel:
                tr_map = {'Normal': 0, '90 deg': 1, '180 deg': 2, '270 deg': 3, 'Flipped': 4}
                t = rofi_menu(list(tr_map.keys()), "Orientation:")
                if t: config_buffer[target_mon]['transform'] = tr_map[t]

# -------------------------------------------
#   Cargar / Guardar
# -------------------------------------------

CONFIG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'hypr_mon_config.json')

def save_config_to_json(config_buffer):
    name = rofi_menu([], "Name configuration:", custom_input=True)
    if not name: return
    
    saved_data = {}
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            try: saved_data = json.load(f)
            except: pass
            
    saved_data[name] = config_buffer
    with open(CONFIG_FILE, 'w') as f:
        json.dump(saved_data, f, indent=4)
    
    notify(f"Configuración '{name}' guardada.", urgency="low")

def load_config_menu():
    if not os.path.exists(CONFIG_FILE):
        notify("No hay configuraciones guardadas.", urgency="low")
        return None
        
    with open(CONFIG_FILE, 'r') as f:
        data = json.load(f)
        
    sel = rofi_menu(list(data.keys()), "Load Configuration:")
    return data[sel] if sel else None

# --------------------------------------------------------
#   MAIN
# --------------------------------------------------------

def main():
    monitors_info = get_monitors_data()
    connected = list(monitors_info.keys())
    
    if not connected:
        notify("No se detectaron monitores activos.", urgency="critical")
        return

    options = ["Auto (Reset)", "Advanced Config", "Load Saved Config"]
    if len(connected) == 2:
        options[1:1] = ["Quick Dual: Right", "Quick Dual: Left", "Quick Mirror"]

    sel = rofi_menu(options, f"Displays ({len(connected)})")
    final_config = None

    if sel == "Auto (Reset)":
        final_config = {}
        x_off = 0
        for m in connected:
            w = monitors_info[m]['width']
            final_config[m] = {'enabled': True, 'res': 'preferred', 'pos': f"{x_off}x0", 'scale': 1, 'transform': 0}
            x_off += w

    elif sel == "Quick Dual: Right":
        m1, m2 = connected[0], connected[1]
        w1 = monitors_info[m1]['width']
        final_config = {
            m1: {'enabled': True, 'res': 'preferred', 'pos': '0x0', 'scale': 1, 'transform': 0},
            m2: {'enabled': True, 'res': 'preferred', 'pos': f'{w1}x0', 'scale': 1, 'transform': 0}
        }
    
    elif sel == "Quick Dual: Left":
        m1, m2 = connected[0], connected[1]
        w2 = monitors_info[m2]['width']
        final_config = {
            m2: {'enabled': True, 'res': 'preferred', 'pos': '0x0', 'scale': 1, 'transform': 0},
            m1: {'enabled': True, 'res': 'preferred', 'pos': f'{w2}x0', 'scale': 1, 'transform': 0}
        }
        
    elif sel == "Quick Mirror":
        final_config = {}
        for m in connected:
            final_config[m] = {'enabled': True, 'res': 'preferred', 'pos': '0x0', 'scale': 1, 'transform': 0}
            
    elif sel == "Advanced Config":
        final_config = advanced_config_menu(connected)
        
    elif sel == "Load Saved Config":
        final_config = load_config_menu()

    if final_config:
        apply_config(final_config)

if __name__ == "__main__":
    main()
