---@diagnostic disable: unused-local
local wezterm = require("wezterm")
local os = require("os")
local is_mac = wezterm.target_triple:find("darwin")
local is_windows = wezterm.target_triple:find("windows")
local is_linux = wezterm.target_triple:find("linux")

local default_prog = { os.getenv("SHELL") }
-- use WSL in Windows
if is_windows then
	default_prog = {
		"wsl.exe",
		--[[ "--distribution", "Ubuntu-20.04", ]]
		"--exec",
		"/bin/zsh",
		"-l",
	}
end

return {
	default_prog = default_prog,
	--  ╭──────────────────────────────────────────────────────────╮
	--  │                        Appearance                        │
	--  ╰──────────────────────────────────────────────────────────╯
	color_scheme = "Batman",
	font = wezterm.font_with_fallback({
		"Iosevka Term",
		"Migmix 1M",
	}),
	use_fancy_tab_bar = false,
	--  ╭──────────────────────────────────────────────────────────╮
	--  │                          Keymap                          │
	--  ╰──────────────────────────────────────────────────────────╯
	-- timeout_milliseconds defaults to 1000 and can be omitted
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "\\",
			mods = "LEADER",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
		{
			key = "a",
			mods = "LEADER|CTRL",
			action = wezterm.action.SendString("\x01"),
		},
	},
}
