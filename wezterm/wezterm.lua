local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

--------------------------------------------------------------------------------
-- 1. PLATFORM DETECTION
--------------------------------------------------------------------------------
-- Windows: "x86_64-pc-windows-msvc" or "aarch64-pc-windows-msvc"
-- macOS:   "x86_64-apple-darwin"   or "aarch64-apple-darwin"
-- Linux:   "x86_64-unknown-linux-gnu", etc.
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_mac = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- Check if running directly inside WSL (e.g., via WSLg / X11 on Linux)
local is_wsl = is_linux and (function()
  local f = io.open("/proc/version", "r")
  if f then
    local content = f:read("*all"):lower()
    f:close()
    return content:find("microsoft") ~= nil or content:find("wsl") ~= nil
  end
  return false
end)()

--------------------------------------------------------------------------------
-- 2. COLOR SCHEME & AESTHETICS
--------------------------------------------------------------------------------
config.color_scheme = "rose-pine-moon"

-- Background opacity and platform-specific blur
config.window_background_opacity = 0.85

if is_mac then
  -- macOS native frosted-glass blur
  config.macos_window_background_blur = 50
elseif is_windows then
  -- Windows 11 Mica / Acrylic backdrop support
  config.win32_system_backdrop = "Acrylic" -- Options: "Mica", "Acrylic", "Tabbed"
end

-- Padding around terminal content
config.window_padding = {
  left = 12,
  right = 12,
  top = 10,
  bottom = 8,
}

-- Window decorations:
-- - macOS: Integrated buttons puts native traffic lights cleanly inside the tab bar
-- - Windows: Integrated buttons embeds minimize/maximize/close into the tab bar
-- - Linux: Borderless with resize handles (clean for GNOME, KDE, and Tiling WMs like Hyprland/i3)
if is_mac or is_windows then
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
  config.window_decorations = "RESIZE"
end

--------------------------------------------------------------------------------
-- 3. TYPOGRAPHY & FONTS
--------------------------------------------------------------------------------
-- Primary font with fallback stack
config.font = wezterm.font_with_fallback({
  { family = "Hack Nerd Font", weight = "Regular" },
  { family = "JetBrainsMono Nerd Font", weight = "Regular" },
  { family = "FiraCode Nerd Font", weight = "Regular" },
  { family = "Cascadia Code", weight = "Regular" },
  { family = "Symbols Nerd Font Mono" },
  "Apple Color Emoji",
  "Segoe UI Emoji",
  "Noto Color Emoji",
})

-- Retina displays on macOS typically require slightly larger font sizes
if is_mac then
  config.font_size = 15.0
else
  config.font_size = 12.5
end

config.line_height = 1.1

--------------------------------------------------------------------------------
-- 4. TAB BAR CONFIGURATION
--------------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.tab_bar_at_bottom = false

-- Format tab title cleanly
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title

  -- Extract clean process / directory name
  local process_name = pane.foreground_process_name or ""
  if process_name ~= "" then
    -- Strip directory path and file extension (e.g. C:\...\pwsh.exe -> pwsh)
    local clean_name = process_name:gsub("(.*[/\\])(.*)", "%2"):gsub("%.exe$", "")
    if clean_name ~= "" then
      title = clean_name
    end
  end

  local index = tab.tab_index + 1
  local prefix = " " .. index .. ": "
  local suffix = " "
  if tab.is_active then
    prefix = "  " .. index .. ": "
  end

  return {
    { Text = prefix .. title .. suffix },
  }
end)

-- Status bar formatting with OS icon and Leader key indicator
wezterm.on("update-status", function(window, pane)
  local stat = {}

  -- Leader key indicator
  if window:leader_is_active() then
    table.insert(stat, { Background = { Color = "#eb6f92" } })
    table.insert(stat, { Foreground = { Color = "#232136" } })
    table.insert(stat, { Attribute = { Intensity = "Bold" } })
    table.insert(stat, { Text = "  LEADER  " })
  end

  -- OS Badge
  local os_badge = " Linux"
  if is_windows then
    os_badge = " Windows"
  elseif is_wsl then
    os_badge = "󰌽 WSL"
  elseif is_mac then
    os_badge = " macOS"
  end

  table.insert(stat, { Background = { Color = "#2a283e" } })
  table.insert(stat, { Foreground = { Color = "#9ccfd8" } })
  table.insert(stat, { Text = " " .. os_badge .. " " })

  -- Current time
  local time = wezterm.strftime(" %H:%M ")
  table.insert(stat, { Background = { Color = "#393552" } })
  table.insert(stat, { Foreground = { Color = "#e0def4" } })
  table.insert(stat, { Text = time })

  window:set_right_status(wezterm.format(stat))
end)

--------------------------------------------------------------------------------
-- 5. PLATFORM-SPECIFIC SHELLS & LAUNCH MENU
--------------------------------------------------------------------------------
if is_windows then
  -- Discover all WSL distributions installed on Windows
  config.wsl_domains = wezterm.default_wsl_domains()

  -- Set WSL as the default startup domain (e.g. "WSL:Ubuntu")
  for _, domain in ipairs(config.wsl_domains) do
    if domain.is_default then
      config.default_domain = domain.name
      break
    end
  end
  if not config.default_domain and #config.wsl_domains > 0 then
    config.default_domain = config.wsl_domains[1].name
  end

  -- Windows Launch Menu with quick access to common shells
  config.launch_menu = {
    {
      label = "PowerShell Core (pwsh)",
      args = { "pwsh.exe", "-NoLogo" },
    },
    {
      label = "Windows PowerShell",
      args = { "powershell.exe", "-NoLogo" },
    },
    {
      label = "Command Prompt",
      args = { "cmd.exe" },
    },
    {
      label = "Git Bash",
      args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" },
    },
  }

  -- Automatically populate launch menu with WSL distros
  for _, domain in ipairs(config.wsl_domains) do
    table.insert(config.launch_menu, {
      label = domain.name,
      domain = { DomainName = domain.name },
    })
  end
elseif is_mac then
  -- macOS Left Option key as standard Alt/Meta for terminal readline / Neovim
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true

  config.launch_menu = {
    { label = "Default Shell", args = { os.getenv("SHELL") or "/bin/zsh", "-l" } },
    { label = "Bash", args = { "/bin/bash", "-l" } },
    { label = "Zsh", args = { "/bin/zsh", "-l" } },
  }
elseif is_linux then
  -- Wayland support on Arch Linux and modern Wayland compositors (Hyprland, Sway, GNOME)
  if os.getenv("WAYLAND_DISPLAY") ~= nil then
    config.enable_wayland = true
  end

  config.launch_menu = {
    { label = "Default Shell", args = { os.getenv("SHELL") or "/bin/bash", "-l" } },
    { label = "Bash", args = { "/bin/bash", "-l" } },
    { label = "Zsh", args = { "/usr/bin/zsh", "-l" } },
  }
end

--------------------------------------------------------------------------------
-- 6. GENERAL SETTINGS & PERFORMANCE
--------------------------------------------------------------------------------
-- Prefer hardware-accelerated WebGpu; auto-falls back to OpenGL / Software
config.front_end = "WebGpu"

config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.check_for_updates = false

-- Cursor styling
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 650

--------------------------------------------------------------------------------
-- 7. KEYBINDINGS
--------------------------------------------------------------------------------
-- Multiplexer Leader Key: CTRL+A (1 second timeout)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Modifier key aliases for cross-platform harmony
-- On macOS: CMD is standard for window/tab operations
-- On Linux / Windows: CTRL+SHIFT or ALT is standard
local mod = is_mac and "CMD" or "CTRL|SHIFT"

config.keys = {
  -- Leader passthrough (press Ctrl+A twice to send Ctrl+A to the shell/editor)
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },

  ------------------------------------------------------------------------------
  -- Panes (Tmux-style via Leader)
  ------------------------------------------------------------------------------
  -- Split horizontal (left / right)
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Split vertical (top / bottom)
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate panes (Vim keys & arrows)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Resize panes (Leader + Shift + H/J/K/L)
  { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Zoom / Toggle fullscreen pane
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Close pane (prompt confirmation)
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  ------------------------------------------------------------------------------
  -- Tabs
  ------------------------------------------------------------------------------
  { key = "t", mods = mod, action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = mod, action = act.CloseCurrentTab({ confirm = false }) },
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- Tab Navigation 1-9 (works across Mac CMD+1..9 and Windows/Linux ALT+1..9)
  { key = "1", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(4) },
  { key = "6", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(5) },
  { key = "7", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(6) },
  { key = "8", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(7) },
  { key = "9", mods = is_mac and "CMD" or "ALT", action = act.ActivateTab(8) },

  ------------------------------------------------------------------------------
  -- Clipboard & Selection
  ------------------------------------------------------------------------------
  { key = "c", mods = mod, action = act.CopyTo("Clipboard") },
  { key = "v", mods = mod, action = act.PasteFrom("Clipboard") },

  -- Copy mode (Vim-style scrollback selection)
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  -- Quick search in scrollback
  { key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },

  ------------------------------------------------------------------------------
  -- Launcher, Command Palette & Windows
  ------------------------------------------------------------------------------
  -- Launch menu (select shell, WSL distro, etc.)
  { key = "Space", mods = "LEADER", action = act.ShowLauncher },
  { key = "p", mods = mod, action = act.ActivateCommandPalette },

  -- Fullscreen toggle
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

  -- Font Size Adjustments
  { key = "=", mods = mod, action = act.IncreaseFontSize },
  { key = "+", mods = mod, action = act.IncreaseFontSize },
  { key = "-", mods = mod, action = act.DecreaseFontSize },
  { key = "0", mods = mod, action = act.ResetFontSize },
}

-- macOS-specific Cmd bracket tab navigation (standard Mac terminal behavior)
if is_mac then
  table.insert(config.keys, { key = "{", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) })
  table.insert(config.keys, { key = "}", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) })
  table.insert(config.keys, { key = "n", mods = "CMD", action = act.SpawnWindow })
end

--------------------------------------------------------------------------------
-- 8. MOUSE BINDINGS
--------------------------------------------------------------------------------
config.mouse_bindings = {
  -- Right-click pastes from clipboard
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
  -- Ctrl/Cmd-Click opens hyperlinks
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = is_mac and "CMD" or "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
}

return config
