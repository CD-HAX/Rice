local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local Alt = "ALT" -- sets the "Alt" key as the secondary modifier

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. "+ SHIFT + J", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+ SHIFT + I", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+ SHIFT + K", hl.dsp.focus({ direction = "down" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + I", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + K", hl.dsp.window.move({ direction = "down" }))

-- Resizing windows using vim binds with alt as the modifier
hl.bind(Alt .. " + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }, { repeating = true }))
hl.bind(Alt .. " + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }, { repeating = true }))
hl.bind(Alt .. " + up", hl.dsp.window.resize({ x = 0, y = 10, relative = true }, { repeating = true }))
hl.bind(Alt .. " + down", hl.dsp.window.resize({ x = 0, y = -10, relative = true }, { repeating = true }))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
