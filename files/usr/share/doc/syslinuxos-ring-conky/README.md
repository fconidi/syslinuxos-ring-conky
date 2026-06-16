# syslinuxos-ring-conky

Tema Conky "ad anelli" di SysLinuxOS con **auto-scaling in base alla
risoluzione dello schermo**.

## Crediti / licenza

Fork di **Auzia Conky** di **Zineddine SAIBI** (GPL-3.0,
<https://github.com/SZinedine/auzia-conky>), a sua volta basato sul template
**Namoudaj Conky** dello stesso autore. Il codice di disegno (`abstract.lua`,
`colors.lua`, `rc/gauge.lua`, `start.lua`) resta opera di Zineddine SAIBI.

Fork, auto-scaling e packaging per SysLinuxOS a cura di:

- **Franco Conidi** (aka *edmond*) — <fconidi@gmail.com>
- <https://syslinuxos.com>
- <https://francoconidi.it>

Distribuito sotto **GPL-3.0**, come l'upstream. Vedi `LICENSE`.

## Cosa fa

Il tema e' autorato per una finestra di 1240x720 su schermo 1920x1080, con
coordinate/raggi/font assoluti. Per supportare risoluzioni diverse senza
ridisegnare tutto, `rc/scale.lua` rileva la risoluzione (xrandr, fallback
xdpyinfo) e calcola:

    scale = min(larghezza/1920, altezza/1080)   # clamp 0.5 .. 3.0

- `conkyrc` dimensiona la finestra (`minimum_width/height`, `gap_y`) con `scale`.
- `start.lua` applica `cairo_scale(cr, scale, scale)`: anelli, spessori,
  posizioni del testo e font scalano in modo uniforme.

A 1920x1080 `scale = 1.0`, quindi il layout e' identico all'originale.

## File

- `/opt/Sys-ring-conky/`        tema (conkyrc, *.lua, rc/scale.lua, rc/gauge.lua)
- `/opt/scripts/conky-ring-start.sh` / `conky-ring-stop.sh`  avvio/arresto
- `/opt/scripts/check_cpu.sh`   imposta `cpu_cores` in settings.lua
- `/lib/systemd/system/check_cpu.service`  esegue check_cpu.sh al boot
- voci di menu: System > Monitor (Conky-ring-start / Conky-ring-stop)

## Uso

    Menu  ->  Conky-ring-start        # avvia
    Menu  ->  Conky-ring-stop         # arresta

## Test su risoluzioni diverse

In VirtualBox cambia la risoluzione dello schermo dell'ospite e riavvia il
conky (stop + start). In alternativa, forza un fattore senza cambiare
risoluzione:

    CONKY_RING_SCALE=1.5 /opt/scripts/conky-ring-start.sh

## Dipendenze

conky-all, x11-xserver-utils (xrandr). x11-utils (xdpyinfo) come fallback.
