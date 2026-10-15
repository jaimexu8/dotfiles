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
config.window_background_opacity = 0.88

if is_mac then
  -- macOS native frosted-glass blur
  config.macos_window_background_blur = 50
elseif is_windows then
  -- Windows 11 Mica / Acrylic backdrop support
  config.win32_system_backdrop = "Acrylic" -- Options: "Mica", "Acrylic", "Tabbed"
end

-- Subtle dimming and desaturation for inactive panes (focus enhancement)
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.6,
}

-- Theme-matched colors for splits and tab bar
config.colors = {
  split = "#393552", -- Muted border matching Rosé Pine Moon
  tab_bar = {
    background = "rgba(0, 0, 0, 0)", -- Transparent tab bar background
    new_tab = {
      bg_color = "rgba(0, 0, 0, 0)",
      fg_color = "#6e6a86",
    },
    new_tab_hover = {
      bg_color = "#2a273f",
      fg_color = "#e0def4",
    },
  },
}

-- Padding around terminal content (breathing room)
config.window_padding = {
  left = 16,
  right = 16,
  top = 12,
  bottom = 10,
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

config.line_height = 1.15

--------------------------------------------------------------------------------
-- 4. TAB BAR CONFIGURATION & AESTHETICS
--------------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 36
config.tab_bar_at_bottom = false

-- Helper: Map process name to a clean Nerd Font icon
local function get_process_icon(process_name)
  local name = (process_name or ""):lower():gsub("%.exe$", "")
  if name:find("nvim") or name:find("vim") then
    return ""
  elseif name:find("zsh") or name:find("bash") or name:find("fish") or name:find("sh") then
    return ""
  elseif name:find("git") then
    return ""
  elseif name:find("python") or name:find("py") then
    return ""
  elseif name:find("node") or name:find("npm") or name:find("pnpm") or name:find("yarn") then
    return ""
  elseif name:find("cargo") or name:find("rust") then
    return ""
  elseif name:find("pwsh") or name:find("powershell") then
    return "󰨊"
  elseif name:find("cmd") then
    return ""
  elseif name:find("docker") then
    return "󰡨"
  else
    return ""
  end
end

-- Helper: Safely retrieve current working directory basename
local function get_cwd_basename(pane)
  local success, cwd_uri = pcall(function() return pane.current_working_path end)
  if success and cwd_uri then
    local path = tostring(cwd_uri.file_path or cwd_uri)
    local home = os.getenv("HOME") or ""
    if home ~= "" and path:sub(1, #home) == home then
      path = "~" .. path:sub(#home + 1)
    end
    local basename = path:match("([^/\\]+)[/\\]*$") or path
    return basename
  end
  return ""
end

-- Format tab title as modern floating pill
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title

  -- Extract clean process name & icon
  local raw_process = pane.foreground_process_name or ""
  local clean_name = raw_process:gsub("(.*[/\\])(.*)", "%2"):gsub("%.exe$", "")
  local icon = get_process_icon(clean_name ~= "" and clean_name or title)

  if clean_name ~= "" then
    title = clean_name
  end

  local index = tab.tab_index + 1

  -- Active tab: vibrant pill with rounded caps ( ... )
  if tab.is_active then
    return {
      { Background = { Color = "rgba(0, 0, 0, 0)" } },
      { Foreground = { Color = "#ea9a97" } },
      { Text = " " },
      { Background = { Color = "#ea9a97" } },
      { Foreground = { Color = "#232136" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = icon .. " " .. index .. ": " .. title },
      { Background = { Color = "rgba(0, 0, 0, 0)" } },
      { Foreground = { Color = "#ea9a97" } },
      { Text = " " },
    }
  else
    -- Inactive tab: subtle dark pill
    local bg = hover and "#393552" or "#2a273f"
    local fg = hover and "#e0def4" or "#908caa"
    return {
      { Background = { Color = "rgba(0, 0, 0, 0)" } },
      { Foreground = { Color = bg } },
      { Text = " " },
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = icon .. " " .. index .. ": " .. title },
      { Background = { Color = "rgba(0, 0, 0, 0)" } },
      { Foreground = { Color = bg } },
      { Text = " " },
    }
  end
end)

-- Status bar formatting with rounded pills for Leader, CWD, OS, and Clock
wezterm.on("update-status", function(window, pane)
  local stat = {}

  -- 1. Leader Pill (Pops up in vibrant Rose when active)
  if window:leader_is_active() then
    table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
    table.insert(stat, { Foreground = { Color = "#eb6f92" } })
    table.insert(stat, { Text = "" })
    table.insert(stat, { Background = { Color = "#eb6f92" } })
    table.insert(stat, { Foreground = { Color = "#232136" } })
    table.insert(stat, { Attribute = { Intensity = "Bold" } })
    table.insert(stat, { Text = "󰌌 LEADER" })
    table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
    table.insert(stat, { Foreground = { Color = "#eb6f92" } })
    table.insert(stat, { Text = "  " })
  end

  -- 2. Current Working Directory Pill
  local cwd = get_cwd_basename(pane)
  if cwd ~= "" then
    table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
    table.insert(stat, { Foreground = { Color = "#2a273f" } })
    table.insert(stat, { Text = "" })
    table.insert(stat, { Background = { Color = "#2a273f" } })
    table.insert(stat, { Foreground = { Color = "#9ccfd8" } })
    table.insert(stat, { Text = " " .. cwd })
    table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
    table.insert(stat, { Foreground = { Color = "#2a273f" } })
    table.insert(stat, { Text = " " })
  end

  -- 3. OS Pill
  local os_badge = " Linux"
  if is_windows then
    os_badge = " Windows"
  elseif is_wsl then
    os_badge = "󰌽 WSL"
  elseif is_mac then
    os_badge = " macOS"
  end

  table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
  table.insert(stat, { Foreground = { Color = "#393552" } })
  table.insert(stat, { Text = "" })
  table.insert(stat, { Background = { Color = "#393552" } })
  table.insert(stat, { Foreground = { Color = "#c4a7e7" } })
  table.insert(stat, { Text = os_badge })
  table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
  table.insert(stat, { Foreground = { Color = "#393552" } })
  table.insert(stat, { Text = " " })

  -- 4. Clock Pill
  local time = wezterm.strftime(" %H:%M")
  table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
  table.insert(stat, { Foreground = { Color = "#2a273f" } })
  table.insert(stat, { Text = "" })
  table.insert(stat, { Background = { Color = "#2a273f" } })
  table.insert(stat, { Foreground = { Color = "#e0def4" } })
  table.insert(stat, { Text = time })
  table.insert(stat, { Background = { Color = "rgba(0, 0, 0, 0)" } })
  table.insert(stat, { Foreground = { Color = "#2a273f" } })
  table.insert(stat, { Text = " " })

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
-- 6. GENERAL SETTINGS, CURSOR & ANIMATION
--------------------------------------------------------------------------------
-- Prefer hardware-accelerated WebGpu; auto-falls back to OpenGL / Software
config.front_end = "WebGpu"

-- High refresh rate smooth rendering
config.animation_fps = 60

config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.check_for_updates = false

-- Smooth cursor styling
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = "EaseInOut"
config.cursor_blink_ease_out = "EaseInOut"

--------------------------------------------------------------------------------
-- 7. KEYBINDINGS
--------------------------------------------------------------------------------
-- Multiplexer Leader Key: CTRL+A (1 second timeout)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Modifier key aliases for cross-platform harmony
-- On macOS: CMD is standard for window/tab operations
-- On Linux / Windows: CTRL+SHIFT or ALT is standard
local mod = is_mac and "CMD" or "CTRL|SHIFT"

--------------------------------------------------------------------------------
-- Interactive Hotkeys Cheatsheet Popup (InputSelector)
--------------------------------------------------------------------------------
local cheatsheet_action = act.InputSelector({
  title = "󰌌  Keybindings Cheatsheet (Type to search, Enter to execute, Esc to exit)",
  choices = {
    { label = "─── PANES (Leader: Ctrl+A) ──────────────────────────────────" },
    { id = "split_h", label = "Leader + | (or \\)   Split pane horizontally (left / right)" },
    { id = "split_v", label = "Leader + -          Split pane vertically (top / bottom)" },
    { id = "nav_pane", label = "Leader + h/j/k/l    Navigate panes (Vim keys / Arrows)" },
    { id = "resize", label = "Leader + H/J/K/L    Resize active pane (by 5 cells)" },
    { id = "zoom", label = "Leader + z          Toggle pane zoom (fullscreen pane)" },
    { id = "close_pane", label = "Leader + x          Close active pane" },
    { label = "─── TABS ──────────────────────────────────────────────────" },
    { id = "new_tab", label = "Ctrl+Shift+T / Cmd+T / Leader+c   New tab" },
    { id = "close_tab", label = "Ctrl+Shift+W / Cmd+W             Close tab" },
    { id = "next_tab", label = "Leader + n                       Next tab" },
    { id = "prev_tab", label = "Leader + p                       Previous tab" },
    { id = "tab_num", label = "Alt+1..9 / Cmd+1..9               Switch to tab 1-9" },
    { label = "─── CLIPBOARD & SCROLLBACK ────────────────────────────────" },
    { id = "copy", label = "Ctrl+Shift+C / Cmd+C          Copy to clipboard" },
    { id = "paste", label = "Ctrl+Shift+V / Cmd+V          Paste from clipboard" },
    { id = "copy_mode", label = "Leader + [                   Enter Vim copy mode (scrollback)" },
    { id = "search", label = "Leader + /                   Search scrollback buffer" },
    { label = "─── LAUNCHER & UTILITIES ─────────────────────────────────" },
    { id = "cheatsheet", label = "Leader + ? / F1             Open this Hotkeys Cheatsheet" },
    { id = "launcher", label = "Leader + Space               Launcher menu (Switch shells/WSL)" },
    { id = "palette", label = "Ctrl+Shift+P / Cmd+P          Command Palette" },
    { id = "fullscreen", label = "Alt + Enter                  Toggle Fullscreen" },
    { id = "font_inc", label = "Ctrl/Cmd + Plus              Increase font size" },
    { id = "font_dec", label = "Ctrl/Cmd + Minus             Decrease font size" },
    { id = "font_reset", label = "Ctrl/Cmd + 0                 Reset font size" },
  },
  action = wezterm.action_callback(function(window, pane, id, label)
    if not id then return end
    if id == "split_h" then
      window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
    elseif id == "split_v" then
      window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
    elseif id == "zoom" then
      window:perform_action(act.TogglePaneZoomState, pane)
    elseif id == "close_pane" then
      window:perform_action(act.CloseCurrentPane({ confirm = true }), pane)
    elseif id == "new_tab" then
      window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
    elseif id == "close_tab" then
      window:perform_action(act.CloseCurrentTab({ confirm = false }), pane)
    elseif id == "next_tab" then
      window:perform_action(act.ActivateTabRelative(1), pane)
    elseif id == "prev_tab" then
      window:perform_action(act.ActivateTabRelative(-1), pane)
    elseif id == "copy_mode" then
      window:perform_action(act.ActivateCopyMode, pane)
    elseif id == "search" then
      window:perform_action(act.Search("CurrentSelectionOrEmptyString"), pane)
    elseif id == "launcher" then
      window:perform_action(act.ShowLauncher, pane)
    elseif id == "palette" then
      window:perform_action(act.ActivateCommandPalette, pane)
    elseif id == "fullscreen" then
      window:perform_action(act.ToggleFullScreen, pane)
    end
  end),
})

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
  -- Launcher, Command Palette, Cheatsheet & Windows
  ------------------------------------------------------------------------------
  -- Hotkeys Cheatsheet Popup (Interactive fuzzy search modal)
  { key = "?", mods = "LEADER|SHIFT", action = cheatsheet_action },
  { key = "/", mods = "LEADER|SHIFT", action = cheatsheet_action },
  { key = "F1", mods = "NONE", action = cheatsheet_action },
  { key = "?", mods = mod, action = cheatsheet_action },

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
