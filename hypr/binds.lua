---------------------
---- Variables needed for the keybinds below ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "~/.config/rofi/launcher.sh"
local browser = "helium-browser"
local logoutmenu = "~/.config/rofi/powermenu.sh"
local msgs = "vesktop"

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",

		follow_mouse = 1,

		force_no_accel = true,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local Alt = "ALT" -- sets the "Alt" key as the secondary modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(
	mainMod .. " + Delete",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- keybinds for applications --

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(Alt .. " + R", hl.dsp.exec_cmd("pkill waybar; waybar &"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(Alt .. " + L", hl.dsp.exec_cmd(logoutmenu))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(msgs))
hl.bind(Alt .. " + S", hl.dsp.exec_cmd("hyprshot -m window ~/Pictures/screenshot/"))
-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
