-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
   hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
     hl.exec_cmd("sudo /usr/local/bin/set-gpu-pstate.sh")
     hl.exec_cmd('awww-daemon & sleep 0.5 && [ -f ~/.config/current_wallpaper ] && awww img "$(cat ~/.config/current_wallpaper)"')
     hl.exec_cmd("waybar & swaync")
   end)
