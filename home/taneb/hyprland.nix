# taneb's Hyprland config (compositor + minimal terminal/launcher/bar stack).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kitty
    fuzzel
    waybar
    grim # screenshots
    slurp # interactive region selection
    wl-clipboard # wl-copy / wl-paste
  ];

  # Hyprland 0.55+ config is Lua, not hyprlang.
  xdg.configFile."hypr/hyprland.lua".text = ''
    hl.config({
        input = {
            kb_layout = "au",
        },
        general = {
            gaps_in = 4,
            gaps_out = 8,
            border_size = 2,
            col.active_border = "rgba(33ccffee)",
            col.inactive_border = "rgba(595959aa)",
        },
        decoration = {
            rounding = 8,
        },
    })

    -- Start the bar once Hyprland is up.
    hl.on("hyprland.start", function()
        hl.exec_cmd("waybar")
    end)

    local mod = "SUPER"
    local terminal = "kitty"
    local launcher = "fuzzel"

    -- Apps & basics
    hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
    hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))
    hl.bind(mod .. " + Q", hl.dsp.window.close())
    hl.bind(mod .. " + M", hl.dsp.exit())
    hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
    hl.bind(mod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
    hl.bind(mod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

    -- Focus (vim-style: H left, J down, K up, L right)
    hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
    hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
    hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
    hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))

    -- Move focused window
    hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
    hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
    hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
    hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

    -- Resize focused window
    hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
    hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
    hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
    hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))

    -- Workspaces: SUPER+1-0 to switch, SUPER+SHIFT+1-0 to move the window there
    hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = 1 }))
    hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = 2 }))
    hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = 3 }))
    hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = 4 }))
    hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = 5 }))
    hl.bind(mod .. " + 6", hl.dsp.focus({ workspace = 6 }))
    hl.bind(mod .. " + 7", hl.dsp.focus({ workspace = 7 }))
    hl.bind(mod .. " + 8", hl.dsp.focus({ workspace = 8 }))
    hl.bind(mod .. " + 9", hl.dsp.focus({ workspace = 9 }))
    hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
    hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
    hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
    hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
    hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
    hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
    hl.bind(mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
    hl.bind(mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
    hl.bind(mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
    hl.bind(mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
    hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

    -- 3-finger swipe to switch workspaces
    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
  '';

  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top",
        "position": "top",
        "modules-left": ["hyprland/workspaces"],
        "modules-center": ["clock"],
        "hyprland/workspaces": {
            "format": "{name}"
        },
        "clock": {
            "format": "{:%H:%M}"
        }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
        font-family: monospace;
        font-size: 13px;
        border: none;
        min-height: 0;
    }

    #waybar {
        background: rgba(20, 20, 20, 0.85);
        color: #ffffff;
    }

    #workspaces button {
        padding: 0 6px;
        color: #aaaaaa;
    }

    #workspaces button.active {
        color: #ffffff;
    }

    #clock {
        padding: 0 10px;
    }
  '';
}
