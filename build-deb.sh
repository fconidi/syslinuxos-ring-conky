#!/bin/bash
# Build syslinuxos-ring-conky.
#
# Output: syslinuxos-ring-conky_<VERSION>_all.deb in this directory.
# No sudo needed: fakeroot handles root ownership for packaging.

set -euo pipefail

PKG_VERSION="0.1.4"
PKG_NAME="syslinuxos-ring-conky"
ARCH="all"

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
FILES_DIR="${WORKDIR}/files"
STAGING="${WORKDIR}/staging"
OUTPUT_DEB="${WORKDIR}/${PKG_NAME}_${PKG_VERSION}_${ARCH}.deb"

echo "==> Workspace: $WORKDIR"
echo "==> Target: $OUTPUT_DEB"

# --- 1. Clean staging and copy files/ ---
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -a "$FILES_DIR"/* "$STAGING/"

# --- 1b. Permissions ---
chmod 755 "$STAGING/opt/scripts/conky-ring-start.sh" \
          "$STAGING/opt/scripts/conky-ring-stop.sh" \
          "$STAGING/opt/scripts/check_cpu.sh"
chmod 644 "$STAGING/lib/systemd/system/check_cpu.service"
find "$STAGING/opt/Sys-ring-conky" -type f -exec chmod 644 {} +
chmod 644 "$STAGING/usr/share/applications/"*.desktop
chmod 644 "$STAGING/usr/share/doc/$PKG_NAME/"*

# --- 2. DEBIAN/control ---
mkdir -p "$STAGING/DEBIAN"
INSTALLED_SIZE=$(du -sk "$STAGING" --exclude=DEBIAN | cut -f1)

cat > "$STAGING/DEBIAN/control" <<EOF
Package: $PKG_NAME
Version: $PKG_VERSION
Section: x11
Priority: optional
Architecture: $ARCH
Depends: conky-all, x11-xserver-utils
Recommends: x11-utils
Maintainer: Franco Conidi (edmond) <fconidi@gmail.com>
Homepage: https://syslinuxos.com
Installed-Size: $INSTALLED_SIZE
Description: Ring-style Conky theme for SysLinuxOS with auto-scaling
 Ring-style Conky theme (CPU, RAM, disks, network, clock, battery)
 integrated into the System > Monitor menu of SysLinuxOS.
 .
 Fork of Auzia Conky by Zineddine SAIBI (GPL-3.0,
 https://github.com/SZinedine/auzia-conky), itself based on the
 Namoudaj Conky template by the same author. Forked and packaged for
 SysLinuxOS by Franco Conidi (edmond) <fconidi@gmail.com>.
 .
 Added features: automatic screen resolution detection (xrandr, fallback
 xdpyinfo) and proportional scaling of the window and drawing relative to
 the 1920x1080 reference layout, via cairo_scale. Override: CONKY_RING_SCALE.
 CPU temperature fixed to use coretemp (Intel Package id 0) or k10temp
 (AMD Tctl/Tdie) instead of the inaccurate acpitemp sensor.
 .
 Includes check_cpu.service which auto-detects CPU core/thread count at boot.
EOF

# --- 3. postinst ---
cat > "$STAGING/DEBIAN/postinst" <<'POSTINST'
#!/bin/bash
set -e

case "$1" in
    configure)
        # Remove legacy unit installed manually from ISO in /etc (plain file,
        # not a symlink): it took precedence over ours in /lib and was a
        # duplicate. Removing it makes our /lib unit authoritative.
        if [ -f /etc/systemd/system/check_cpu.service ]; then
            rm -f /etc/systemd/system/check_cpu.service \
                  /etc/systemd/system/multi-user.target.wants/check_cpu.service
        fi
        # Detect CPU count immediately (updates settings.lua).
        if [ -x /opt/scripts/check_cpu.sh ]; then
            /opt/scripts/check_cpu.sh || true
        fi
        # Enable and start the CPU detection service.
        if [ -d /run/systemd/system ]; then
            systemctl daemon-reload >/dev/null 2>&1 || true
            if command -v deb-systemd-helper >/dev/null 2>&1; then
                deb-systemd-helper enable check_cpu.service >/dev/null 2>&1 || true
            else
                systemctl enable check_cpu.service >/dev/null 2>&1 || true
            fi
            systemctl daemon-reload >/dev/null 2>&1 || true
            systemctl start check_cpu.service >/dev/null 2>&1 || true
        fi
        # Refresh the desktop menu database.
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
        fi
        echo
        echo "syslinuxos-ring-conky: installation complete."
        echo "  - Start: Menu > System > Monitor > Conky-ring-start"
        echo "  - Stop:  Menu > System > Monitor > Conky-ring-stop"
        echo "  - Auto-scaling active based on resolution (override: CONKY_RING_SCALE=<n>)"
        ;;
    abort-upgrade|abort-remove|abort-deconfigure)
        ;;
    *)
        echo "postinst called with unknown argument \`$1'" >&2
        exit 1
        ;;
esac

exit 0
POSTINST

# --- 4. prerm ---
cat > "$STAGING/DEBIAN/prerm" <<'PRERM'
#!/bin/sh
set -e

case "$1" in
    remove|deconfigure)
        if [ -d /run/systemd/system ]; then
            systemctl disable --now check_cpu.service >/dev/null 2>&1 || true
        fi
        ;;
    upgrade|failed-upgrade)
        ;;
    *)
        echo "prerm called with unknown argument \`$1'" >&2
        exit 1
        ;;
esac

exit 0
PRERM

# --- 5. postrm ---
cat > "$STAGING/DEBIAN/postrm" <<'POSTRM'
#!/bin/sh
set -e

case "$1" in
    remove|purge)
        if [ -d /run/systemd/system ]; then
            systemctl daemon-reload >/dev/null 2>&1 || true
        fi
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
        fi
        ;;
    upgrade|failed-upgrade|abort-install|abort-upgrade|disappear)
        ;;
    *)
        echo "postrm called with unknown argument \`$1'" >&2
        exit 1
        ;;
    esac

exit 0
POSTRM

chmod 755 "$STAGING/DEBIAN/postinst" "$STAGING/DEBIAN/prerm" "$STAGING/DEBIAN/postrm"

# --- 6. md5sums ---
echo "==> Generating md5sums"
(cd "$STAGING" && find . -type f -not -path './DEBIAN/*' -printf '%P\n' | sort | xargs -d '\n' md5sum > DEBIAN/md5sums)

# --- 7. Build .deb ---
echo "==> Building .deb (fakeroot)"
rm -f "$OUTPUT_DEB"
fakeroot dpkg-deb --build "$STAGING" "$OUTPUT_DEB"

# --- 8. Verify ---
echo
echo "==> .deb produced:"
ls -la "$OUTPUT_DEB"
echo
echo "==> Metadata:"
dpkg-deb -I "$OUTPUT_DEB" | grep -E "^ (Package|Version|Architecture|Depends|Maintainer)"
echo
echo "==> Contents:"
dpkg-deb -c "$OUTPUT_DEB" | awk '{print $1, $6}'

echo
echo "Build OK: $OUTPUT_DEB"
echo
echo "To install/test:"
echo "  sudo apt install $OUTPUT_DEB"
