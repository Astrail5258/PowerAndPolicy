local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local DestinyLib = {}

-- Define some preset color themes
local Themes = {
    Light = {
        WindowBackground = Color3.fromRGB(255, 255, 255),
        ButtonBackground = Color3.fromRGB(240, 240, 240),
        ButtonTextColor = Color3.fromRGB(0, 0, 0),
        TitleBackground = Color3.fromRGB(200, 200, 200),
        TitleTextColor = Color3.fromRGB(0, 0, 0)
    },
    Dark = {
        WindowBackground = Color3.fromRGB(40, 40, 40),
        ButtonBackground = Color3.fromRGB(60, 60, 60),
        ButtonTextColor = Color3.fromRGB(255, 255, 255),
        TitleBackground = Color3.fromRGB(30, 30, 30),
        TitleTextColor = Color3.fromRGB(255, 255, 255)
    },
    Blue = {
        WindowBackground = Color3.fromRGB(0, 0, 255),
        ButtonBackground = Color3.fromRGB(0, 0, 200),
        ButtonTextColor = Color3.fromRGB(255, 255, 255),
        TitleBackground = Color3.fromRGB(0, 0, 180),
        TitleTextColor = Color3.fromRGB(255, 255, 255)
    }
}

local function createDraggableElement(element)
    local dragging, dragInput, dragStart, startPos

    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = element.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    element.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function applyTheme(window, theme)
    local themeColors = Themes[theme]
    if not themeColors then return end

    window.BackgroundColor3 = themeColors.WindowBackground

    local titleBar = window:FindFirstChild("TitleBar")
    if titleBar then
        titleBar.BackgroundColor3 = themeColors.TitleBackground
        titleBar.TextColor3 = themeColors.TitleTextColor
    end

    for _, child in pairs(window:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child.BackgroundColor3 = themeColors.ButtonBackground
            child.TextColor3 = themeColors.ButtonTextColor
        end
    end
end

function DestinyLib:CreateWindow(title, initialTheme)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local window = Instance.new("Frame")
    window.Name = title
    window.Size = UDim2.new(0, 400, 0, 300)
    window.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BorderSizePixel = 0
    window.Parent = ScreenGui

    local titleBar = Instance.new("TextLabel")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Text = title
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.TextSize = 20
    titleBar.TextAlign = Enum.TextXAlignment.Center
    titleBar.Parent = window

    applyTheme(window, initialTheme)
    createDraggableElement(window)

    return window
end

function DestinyLib:AddToggleButton(window, text, defaultState, callback)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 30)
    toggleButton.Position = UDim2.new(0, 10, 0, 40)
    toggleButton.Text = text
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 18
    toggleButton.Parent = window

    local state = defaultState
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.Text = state and text or text .. " (Off)"
        callback(state)
    end)
end

function DestinyLib:AddSlider(window, text, minValue, maxValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 300, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 80)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderFrame.Parent = window

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 0, 1, 0)
    slider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    slider.Text = ""
    slider.Parent = sliderFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 1, 5)
    sliderLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderLabel.Text = text .. ": " .. defaultValue
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = 16
    sliderLabel.Parent = sliderFrame

    local function updateSlider(input)
        local sizeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        slider.Size = UDim2.new(sizeX, 0, 1, 0)
        local value = math.floor(minValue + (sizeX * (maxValue - minValue)))
        sliderLabel.Text = text .. ": " .. value
        callback(value)
    end

    slider.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
end

function DestinyLib:AddThemeSelector(window, callback)
    local themeDropdown = Instance.new("TextButton")
    themeDropdown.Size = UDim2.new(0, 100, 0, 30)
    themeDropdown.Position = UDim2.new(0, 10, 0, 120)
    themeDropdown.Text = "Choose Theme"
    themeDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    themeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeDropdown.TextSize = 18
    themeDropdown.Parent = window

    local themeList = {"Light", "Dark", "Blue"}
    local currentThemeIndex = 1

    themeDropdown.MouseButton1Click:Connect(function()
        currentThemeIndex = (currentThemeIndex % #themeList) + 1
        local selectedTheme = themeList[currentThemeIndex]
        applyTheme(window, selectedTheme)
        themeDropdown.Text = "Theme: " .. selectedTheme
        callback(selectedTheme)
    end)
end

-- Create the main UI
local ui = DestinyLib:CreateWindow("Destiny GUI", "Dark")

-- Add a Toggle button to show/hide the UI
DestinyLib:AddToggleButton(ui, "Show/Hide UI", true, function(state)
    ui.Visible = state
end)

-- Add a simple slider to adjust some value
DestinyLib:AddSlider(ui, "Adjust Speed", 0, 100, 50, function(value)
    print("Speed set to: ", value)
end)

-- Add a theme selector
DestinyLib:AddThemeSelector(ui, function(selectedTheme)
    print("Selected theme: ", selectedTheme)
end)

return DestinyLib
