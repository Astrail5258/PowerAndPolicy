local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Astrail5258/PowerAndPolicy/refs/heads/main/kavoUI.lua"))()
local colors = {
    SchemeColor = Color3.fromRGB(30, 30, 30),
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}
local Window = Library.CreateLib("Power&Policy | by Astrail", colors)
local Waypoints = Window:NewTab("Waypoints")
local Kingdoms = Waypoints:NewSection("Kingdoms")
Kingdoms:NewButton("Rathport", "Teleport to Rathport", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(407, 30, 1650)
end)

Kingdoms:NewButton("Dundalk", "Teleport to Dundalk", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(270, 31, -673)
end)

local Settings = Window:NewTab("Settings")
local Customization = Settings:NewSection("UI Customization")

local themes = {
    SchemeColor = colors.SchemeColor,
    Background = colors.Background,
    Header = colors.Header,
    TextColor = colors.TextColor,
    ElementColor = colors.ElementColor
}

for theme, color in pairs(themes) do
    Customization:NewColorPicker(theme, "Change your " .. theme, color, function(color3)
        Library:ChangeColor(theme, color3)
    end)
end
