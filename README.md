# syslinuxos-ring-conky

Ring-style Conky theme for [SysLinuxOS](https://syslinuxos.com) with **automatic resolution scaling**.

Displays CPU, RAM, disks, network, clock and battery as animated rings drawn via Cairo.

## Credits / License

Fork of **Auzia Conky** by **Zineddine SAIBI** (GPL-3.0,
<https://github.com/SZinedine/auzia-conky>), itself based on the
**Namoudaj Conky** template by the same author.
The drawing code (`abstract.lua`, `colors.lua`, `rc/gauge.lua`, `start.lua`)
remains the work of Zineddine SAIBI.

Fork, auto-scaling and Debian packaging for SysLinuxOS by:

- **Franco Conidi** (aka *edmond*) — <fconidi@gmail.com>
- <https://syslinuxos.com> — <https://francoconidi.it>

Distributed under **GPL-3.0**, same as upstream. See `files/opt/Sys-ring-conky/LICENSE`.

## Features added over upstream

- **Auto-scaling** — `rc/scale.lua` detects the primary display resolution via
  `xrandr` (fallback: `xdpyinfo`) and computes:

  ```
  scale = min(width/1920, height/1080)   # clamped 0.5 .. 3.0
  ```

  `cairo_scale(cr, scale, scale)` is applied once in `start.lua`; every ring,
  stroke width, text position and font size scales uniformly.
  At 1920×1080 `scale = 1.0` — identical to the original layout.
  Override at any time with `CONKY_RING_SCALE=<n>`.

- **Accurate CPU temperature** — `cpu_temperature()` in `abstract.lua` reads
  `coretemp` (Intel `Package id 0`) or `k10temp` (AMD `Tctl`/`Tdie`) via
  `sensors`, falling back to `acpitemp` when `lm-sensors` is not available.

- **Auto-detected CPU core/thread count** — `check_cpu.service` runs
  `check_cpu.sh` at boot (and on install) to write the correct `cpu_cores`
  and active `net_interface` into `settings.lua`.

- **No-battery safeguard** — on desktops/VMs without a battery the battery
  ring is suppressed (no misleading "100%" from an AC adapter).

- **Desktop menu integration** — `System > Monitor > Conky-ring-start / Conky-ring-stop`.

## Installation

### Via SysLinuxOS APT repository (recommended)

```bash
curl -fsSL https://fconidi.github.io/SysLinuxOS-Tools/client/install-repo.sh | sudo bash
sudo apt install syslinuxos-ring-conky
```

### Direct .deb download

Download the latest `.deb` from [Releases](../../releases/latest) and install:

```bash
sudo apt install ./syslinuxos-ring-conky_<version>_all.deb
```

### Build from source

```bash
sudo apt install fakeroot dpkg-dev
git clone https://github.com/fconidi/syslinuxos-ring-conky.git
cd syslinuxos-ring-conky
bash build-deb.sh
sudo apt install ./syslinuxos-ring-conky_*.deb
```

## Dependencies

- `conky-all`
- `x11-xserver-utils` (xrandr)
- `x11-utils` (xdpyinfo — optional fallback)
- `lm-sensors` (optional, for accurate CPU temperature)

## Files installed

| Path | Description |
|------|-------------|
| `/opt/Sys-ring-conky/` | Theme files (conkyrc, \*.lua, rc/) |
| `/opt/scripts/conky-ring-start.sh` | Start script |
| `/opt/scripts/conky-ring-stop.sh` | Stop script |
| `/opt/scripts/check_cpu.sh` | CPU/net detection script |
| `/lib/systemd/system/check_cpu.service` | Boot-time detection unit |

## Usage

```
Menu → System → Monitor → Conky-ring-start   # start
Menu → System → Monitor → Conky-ring-stop    # stop
```

Force a specific scale factor without changing resolution:

```bash
CONKY_RING_SCALE=1.5 /opt/scripts/conky-ring-start.sh
```
