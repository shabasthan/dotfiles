#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, Gdk
import subprocess

# --- FINE-TUNE POSITIONING HERE ---
TOP_MARGIN = 5    # Height of your Waybar (in pixels)
RIGHT_MARGIN = 44 # Distance from right edge to align under network icon
# ----------------------------------

class WifiDropdown(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.has_entered = False

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)

        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, TOP_MARGIN)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, RIGHT_MARGIN)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)

        self.connect("enter-notify-event", self.on_mouse_enter)
        self.connect("leave-notify-event", self.on_mouse_leave)
        self.connect("focus-out-event", lambda w, e: Gtk.main_quit())

        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            window {
                opacity: 0.8;
                background-color: #1e1e2e;
                border: 1px solid #b4befe;
                border-radius: 0px;
                padding: 6px;
            }
            button {
                background: transparent;
                color: #cdd6f4;
                border: none;
                border-radius: 0px;
                padding: 8px 12px;
                font-family: "JetBrainsMono Nerd Font";
                font-size: 13px;
            }
            button:hover {
                background-color: #45475a;
                color: #b4befe;
            }
            button.active-wifi {
                color: #a6e3a1;
                font-weight: bold;
            }
            button.disconnect-btn {
                color: #f38ba8;
                padding: 8px 10px;
            }
            button.disconnect-btn:hover {
                background-color: #f38ba8;
                color: #1e1e2e;
            }
            entry {
                background-color: #313244;
                color: #cdd6f4;
                border: 1px solid #b4befe;
                border-radius: 0px;
                padding: 6px;
            }
        """)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        self.add(box)

        toggle_btn = Gtk.Button(label="󰤨  Toggle Wi-Fi")
        if toggle_btn.get_child():
            toggle_btn.get_child().set_xalign(0.0)
        toggle_btn.connect("clicked", self.toggle_wifi)
        box.pack_start(toggle_btn, False, False, 0)

        active_ssid, ssids = self.get_wifi_list()
        for ssid in ssids:
            is_active = (ssid == active_ssid)
            
            if is_active:
                row_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
                
                btn = Gtk.Button(label=f"󰤨  {ssid}  󰄬")
                btn.get_style_context().add_class("active-wifi")
                if btn.get_child():
                    btn.get_child().set_xalign(0.0)
                btn.connect("clicked", self.connect_wifi, ssid)
                row_box.pack_start(btn, True, True, 0)

                disc_btn = Gtk.Button(label="󰅖")
                disc_btn.get_style_context().add_class("disconnect-btn")
                disc_btn.set_tooltip_text("Disconnect")
                disc_btn.connect("clicked", self.disconnect_wifi, ssid)
                row_box.pack_start(disc_btn, False, False, 0)

                box.pack_start(row_box, False, False, 0)
            else:
                btn = Gtk.Button(label=f"󰤨  {ssid}")
                if btn.get_child():
                    btn.get_child().set_xalign(0.0)
                btn.connect("clicked", self.connect_wifi, ssid)
                box.pack_start(btn, False, False, 0)

        self.show_all()

    def on_mouse_enter(self, widget, event):
        self.has_entered = True

    def on_mouse_leave(self, widget, event):
        if self.has_entered:
            alloc = self.get_allocation()
            if event.x < 0 or event.y < 0 or event.x >= alloc.width or event.y >= alloc.height:
                Gtk.main_quit()

    def send_notification(self, title, message):
        try:
            subprocess.run(["notify-send", title, message])
        except Exception:
            pass

    def toggle_wifi(self, btn):
        subprocess.run(["nmcli", "radio", "wifi", "toggle"])
        Gtk.main_quit()

    def disconnect_wifi(self, btn, ssid):
        res = subprocess.run(["nmcli", "connection", "down", "id", ssid], capture_output=True, text=True)
        if res.returncode != 0:
            subprocess.run(["nmcli", "device", "disconnect", "wlan0"], capture_output=True, text=True)
        self.send_notification("Wi-Fi Disconnected", f"Disconnected from {ssid}")
        Gtk.main_quit()

    def connect_wifi(self, btn, ssid):
        res = subprocess.run(["nmcli", "device", "wifi", "connect", ssid], capture_output=True, text=True)
        if res.returncode == 0:
            self.send_notification("Wi-Fi Connected", f"Successfully connected to {ssid}")
            Gtk.main_quit()
        else:
            self.prompt_password(ssid)

    def prompt_password(self, ssid):
        dialog = Gtk.Dialog(
            title=f"Connect to {ssid}",
            transient_for=self,
            flags=0,
            buttons=(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK)
        )
        dialog.set_default_size(300, 110)
        dialog.set_position(Gtk.WindowPosition.CENTER)
        dialog.set_resizable(False)

        area = dialog.get_content_area()
        area.set_spacing(8)
        area.set_border_width(12)

        label = Gtk.Label(label=f"Enter Password for {ssid}:")
        label.set_xalign(0.0)
        area.add(label)

        entry = Gtk.Entry()
        entry.set_visibility(False)
        entry.set_activates_default(True)
        area.add(entry)

        ok_btn = dialog.get_widget_for_response(Gtk.ResponseType.OK)
        if ok_btn:
            ok_btn.set_can_default(True)
            ok_btn.grab_default()

        dialog.show_all()
        entry.grab_focus()  # Shifts keyboard focus straight into password entry field

        response = dialog.run()

        if response == Gtk.ResponseType.OK:
            pwd = entry.get_text()
            dialog.destroy()
            res = subprocess.run(["nmcli", "device", "wifi", "connect", ssid, "password", pwd], capture_output=True, text=True)
            if res.returncode == 0:
                self.send_notification("Wi-Fi Connected", f"Successfully connected to {ssid}")
            else:
                self.send_notification("Wi-Fi Connection Failed", f"Could not connect to {ssid}. Incorrect password?")
            Gtk.main_quit()
        else:
            dialog.destroy()

    def get_wifi_list(self):
        active_ssid = ""
        ssids = []
        try:
            res = subprocess.check_output(["nmcli", "-t", "-f", "ACTIVE,SSID", "device", "wifi", "list"]).decode("utf-8")
            lines = [line.strip() for line in res.split("\n") if line.strip()]
            seen = set()
            for line in lines:
                parts = line.split(":", 1)
                if len(parts) == 2:
                    active, ssid = parts[0], parts[1].strip()
                    if ssid and ssid != "--":
                        if active == "yes":
                            active_ssid = ssid
                        if ssid not in seen:
                            seen.add(ssid)
                            ssids.append(ssid)
        except Exception:
            pass
        return active_ssid, ssids[:8]

if __name__ == "__main__":
    win = WifiDropdown()
    Gtk.main()
