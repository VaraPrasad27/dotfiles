-- Inside ~/.config/hypr/hyprland.lua
local status, err = pcall(function()
    require("modules/appearance")
    require("modules/autostarts")
    require("modules/binds")
    require("modules/env")
    require("modules/inputs")
    require("modules/monitors")
    require("modules/rules_permissions")
end)

if not status then
    -- Built-in safe fallbacks or error reporting
    print("Error loading config module: " .. tostring(err))
end
