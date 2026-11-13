#!/usr/bin/env python3
# Small libadwaita window for the waybar WireGuard module (wg-quick@$IFACE, root via polkit)
import subprocess
import sys
import time
from pathlib import Path

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, Gio, GLib, Gtk  # noqa: E402

IFACE = "wg0"
LABEL = "Home"
UNIT = f"wg-quick@{IFACE}"
ICONS = Path.home() / ".config/waybar/icons"
SYSFS = Path("/sys/class/net") / IFACE


def is_up():
    return SYSFS.is_dir()


def read_stat(name):
    try:
        return int((SYSFS / "statistics" / name).read_text())
    except OSError:
        return 0


def human_bytes(n):
    for unit in ("B", "KiB", "MiB", "GiB"):
        if n < 1024 or unit == "GiB":
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024


def human_duration(seconds):
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    return f"{h}h {m:02d}m" if h else f"{m}m {s:02d}s"


def address():
    out = subprocess.run(["ip", "-4", "-br", "addr", "show", IFACE], capture_output=True, text=True).stdout.split()
    return out[2] if len(out) > 2 else "—"


def ensure_polkit_agent():
    """systemctl needs a running agent to show the password prompt."""
    if subprocess.run(["systemctl", "--user", "is-active", "--quiet", "hyprpolkitagent"]).returncode:
        subprocess.run(["systemctl", "--user", "start", "hyprpolkitagent"])


def active_since():
    """CLOCK_MONOTONIC seconds when the unit became active, or None."""
    out = subprocess.run(
        ["systemctl", "show", UNIT, "-p", "ActiveEnterTimestampMonotonic", "--value"],
        capture_output=True, text=True,
    ).stdout.strip()
    return int(out) / 1e6 if out.isdigit() and int(out) else None


class Window(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="WireGuard", default_width=380, resizable=False)
        self.busy = False
        self.syncing = False
        self.since = None

        esc = Gtk.ShortcutController()
        esc.add_shortcut(Gtk.Shortcut(
            trigger=Gtk.ShortcutTrigger.parse_string("Escape"),
            action=Gtk.CallbackAction.new(lambda *_: self.close() or True),
        ))
        self.add_controller(esc)

        self.logo = Gtk.Image(pixel_size=64, margin_top=6, margin_bottom=6)

        self.switch = Adw.SwitchRow(title=f"{LABEL} ({IFACE})")
        self.switch.connect("notify::active", self.on_switch)
        main = Adw.PreferencesGroup()
        main.add(self.switch)

        details = Adw.PreferencesGroup(title="Details")
        self.rows = {}
        for key in ("Address", "Connected for", "Received", "Sent"):
            row = Adw.ActionRow(title=key)
            value = Gtk.Label(css_classes=["dim-label", "numeric"])
            row.add_suffix(value)
            details.add(row)
            self.rows[key] = value
        self.details = details

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18,
                      margin_top=6, margin_bottom=18, margin_start=18, margin_end=18)
        for w in (self.logo, main, details):
            box.append(w)

        self.toasts = Adw.ToastOverlay(child=box)
        view = Adw.ToolbarView(content=self.toasts)
        view.add_top_bar(Adw.HeaderBar())
        self.set_content(view)

        self.refresh(state_changed=True)
        GLib.timeout_add_seconds(1, self.refresh)

    def refresh(self, state_changed=False):
        up = is_up()
        if up != self.switch.get_active() or state_changed:
            self.since = active_since() if up else None
        if not self.busy:
            self.syncing = True
            self.switch.set_active(up)
            self.syncing = False
            self.switch.set_subtitle("Connected" if up else "Disconnected")

        icon = ICONS / ("wireguard.png" if up else "wireguard-off.png")
        if icon.exists():
            self.logo.set_from_file(str(icon))
        else:
            self.logo.set_from_icon_name("network-vpn-symbolic")

        self.details.set_visible(up)
        if up:
            self.rows["Address"].set_label(address())
            self.rows["Connected for"].set_label(human_duration(time.monotonic() - self.since) if self.since else "—")
            self.rows["Received"].set_label(human_bytes(read_stat("rx_bytes")))
            self.rows["Sent"].set_label(human_bytes(read_stat("tx_bytes")))
        return GLib.SOURCE_CONTINUE

    def on_switch(self, row, _pspec):
        if self.syncing or self.busy:
            return
        want_up = row.get_active()
        self.busy = True
        self.want_up = want_up
        self.started_at = int(time.time())
        row.set_sensitive(False)
        row.set_subtitle("Connecting…" if want_up else "Disconnecting…")
        ensure_polkit_agent()
        proc = Gio.Subprocess.new(
            ["systemctl", "start" if want_up else "stop", UNIT],
            Gio.SubprocessFlags.STDERR_PIPE,
        )
        proc.communicate_utf8_async(None, None, self.on_done)

    def on_done(self, proc, result):
        _, _, err = proc.communicate_utf8_finish(result)
        if not proc.get_successful():
            self.show_error((err or "").strip())
        self.busy = False
        self.switch.set_sensitive(True)
        self.refresh(state_changed=True)
        subprocess.run(["pkill", "-RTMIN+8", "waybar"])

    def show_error(self, err):
        if "Interactive authentication required" in err:
            self.toasts.add_toast(Adw.Toast(title="No password prompt (polkit agent not running)", timeout=5))
            return
        if "Access denied" in err or "cancel" in err.lower():
            self.toasts.add_toast(Adw.Toast(title="Authentication cancelled", timeout=3))
            return
        # wg-quick itself failed: its real reason is in the unit's journal
        log = subprocess.run(
            ["journalctl", "-u", UNIT, "-o", "cat", "--no-pager", "-n", "5", f"--since=@{self.started_at}"],
            capture_output=True, text=True,
        ).stdout.strip()
        first = err.splitlines()[0] if err else "WireGuard command failed"
        body = "\n\n".join(filter(None, [first, log, f"Check /etc/wireguard/{IFACE}.conf"]))
        dialog = Adw.AlertDialog(
            heading=f"Couldn't {'connect to' if self.want_up else 'disconnect from'} {LABEL}",
            body=body,
        )
        dialog.add_response("ok", "OK")
        dialog.present(self)


class App(Adw.Application):
    def __init__(self):
        super().__init__(application_id="local.dotfiles.WireGuard")
        Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.FORCE_DARK)

    def do_activate(self):
        (self.props.active_window or Window(self)).present()


if __name__ == "__main__":
    sys.exit(App().run(sys.argv))
