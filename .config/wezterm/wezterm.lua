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
	color_scheme = "Batman",
	font = wezterm.font_with_fallback({
		"Iosevka Term",
		"Migmix 1M",
	}),
}
