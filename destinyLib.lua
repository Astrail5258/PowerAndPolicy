-- Create basic UI elements and interaction helpers

local function createDraggableElement(element)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
            input.Consumed = true
        end
    end)

    element.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    element.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

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

-- Function to apply a color theme to the window and buttons
local function applyTheme(window, theme)
    local themeColors = Themes[theme]

    window.BackgroundColor3 = themeColors.WindowBackground

    -- Apply to title
    window:FindFirstChild("TitleBar").BackgroundColor3 = themeColors.TitleBackground
    window:FindFirstChild("TitleBar").TextColor3 = themeColors.TitleTextColor

    -- Apply to buttons
    for _, button in pairs(window:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = themeColors.ButtonBackground
            button.TextColor3 = themeColors.ButtonTextColor
        end
    end
end

-- Function to create a window
function DestinyLib:CreateWindow(title, initialTheme)
    local window = Instance.new("Frame")
    window.Name = title
    window.Size = UDim2.new(0, 400, 0, 300)
    window.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BorderSizePixel = 0
    window.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    -- Title bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Text = title
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.TextSize = 20
    titleBar.TextAlign = Enum.TextAnchor.MiddleCenter
    titleBar.Parent = window

    -- Apply initial theme
    applyTheme(window, initialTheme)

    -- Make the window draggable
    createDraggableElement(window)

    return window
end

-- Function to add a toggle button to the window
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

-- Function to create a simple slider
function DestinyLib:AddSlider(window, text, minValue, maxValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 300, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 120)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderFrame.Parent = window

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 0, 1, 0)
    slider.Position = UDim2.new(0, 0, 0, 0)
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
    sliderLabel.Parent = window

    -- Create a draggable slider
    slider.MouseButton1Down:Connect(function()
        local dragging = true
        local startPos = slider.Position.X.Offset

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging then
                local delta = input.Position.X - startPos
                local clampedValue = math.clamp(delta, 0, sliderFrame.Size.X.Offset)
                slider.Size = UDim2.new(0, clampedValue, 1, 0)

                local value = minValue + (clampedValue / sliderFrame.Size.X.Offset) * (maxValue - minValue)
                sliderLabel.Text = text .. ": " .. math.round(value)
                callback(value)
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function()
            dragging = false
        end)
    end)
end

-- Function to change theme via dropdown
function DestinyLib:AddThemeSelector(window, callback)
    local themeDropdown = Instance.new("TextButton")
    themeDropdown.Size = UDim2.new(0, 100, 0, 30)
    themeDropdown.Position = UDim2.new(0, 10, 0, 160)
    themeDropdown.Text = "Choose Theme"
    themeDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    themeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeDropdown.TextSize = 18
    themeDropdown.Parent = window

    themeDropdown.MouseButton1Click:Connect(function()
        local theme = Enum.KeyCode[math.random(1, #Themes)] -- Random theme for demo
        applyTheme(window, theme)
        callback(theme)
    end)
end

-- Toggle GUI Visibility
local function toggleGUIVisibility(window)
    local isVisible = window.Visible
    window.Visible = not isVisible
end

-- Create the main UI
local ui = DestinyLib:CreateWindow("Destiny GUI", "Dark")

-- Add a Toggle button to show/hide the UI
DestinyLib:AddToggleButton(ui, "Show/Hide UI", true, function(state)
    toggleGUIVisibility(ui)
end)

-- Add a simple slider to adjust some value
DestinyLib:AddSlider(ui, "Adjust Speed", 0, 100, 50, function(value)
    print("Speed set to:", value)
end)

-- Add a theme selector
DestinyLib:AddThemeSelector(ui, function(selectedTheme)
    print("Selected theme:", selectedTheme)
end)

-- Enable draggable UI for the whole window
createDraggableElement(ui)

ui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

--
