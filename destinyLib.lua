-- Create the main GUI library
local Library = {}
Library.__index = Library

local currentTheme = {
    Background = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(255, 255, 255)
}

-- Helper function to round corners
local function roundify(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

-- Create a new tab
function Library:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Content = Instance.new("Frame")
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Parent = script.Parent -- Parent to the GUI screen (you can customize this)

    local tabTitle = Instance.new("TextLabel")
    tabTitle.Text = name
    tabTitle.TextColor3 = currentTheme.Text
    tabTitle.Font = Enum.Font.Gotham
    tabTitle.TextSize = 20
    tabTitle.Size = UDim2.new(1, 0, 0, 40)
    tabTitle.TextAlignment = Enum.TextXAlignment.Center
    tabTitle.BackgroundTransparency = 1
    tabTitle.Parent = tab.Content

    tabAPI = {}
    setmetatable(tabAPI, Library)
    return tabAPI
end

-- Add slider to tab
function Library:AddSlider(labelText, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = tabContent

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = currentTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 10)
    sliderBack.Position = UDim2.new(0, 0, 0, 20)
    sliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = frame
    roundify(sliderBack, 5)

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, (default - min) / (max - min), 0, 10)
    slider.BackgroundColor3 = currentTheme.Accent
    slider.BorderSizePixel = 0
    slider.Parent = sliderBack
    roundify(slider, 5)

    local dragger = Instance.new("Frame")
    dragger.Size = UDim2.new(0, 16, 0, 16)
    dragger.Position = UDim2.new(0, (default - min) / (max - min) * sliderBack.Size.X.Offset - 8, 0, 0)
    dragger.BackgroundColor3 = currentTheme.Accent
    dragger.BorderSizePixel = 0
    dragger.Parent = sliderBack
    roundify(dragger, 8)

    dragger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function updateSlider()
                local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
                local newValue = math.clamp((mousePos - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
                slider.Size = UDim2.new(newValue, 0, 1, 0)
                dragger.Position = UDim2.new(newValue, -8, 0, 0)
                if callback then callback(min + newValue * (max - min)) end
            end
            game:GetService("UserInputService").InputChanged:Connect(updateSlider)
        end
    end)
end

-- Add toggle to tab
function Library:AddToggle(labelText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tabContent

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.TextColor3 = currentTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local toggleBack = Instance.new("Frame")
    toggleBack.Size = UDim2.new(0, 40, 0, 20)
    toggleBack.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBack.BackgroundColor3 = currentTheme.Accent:lerp(Color3.new(0, 0, 0), 0.4)
    toggleBack.BorderSizePixel = 0
    toggleBack.Parent = frame
    roundify(toggleBack, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = currentTheme.Accent
    knob.BorderSizePixel = 0
    knob.Parent = toggleBack
    roundify(knob, 8)

    local isOn = default
    if callback then callback(isOn) end

    local function toggle()
        isOn = not isOn
        game.TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = isOn and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
        }):Play()
        if callback then callback(isOn) end
    end

    toggleBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
end

-- Add color picker to tab
function Library:AddColorPicker(labelText, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = tabContent

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = currentTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 30)
    preview.Position = UDim2.new(0, 0, 0, 25)
    preview.BackgroundColor3 = defaultColor
    preview.BorderSizePixel = 0
    preview.Parent = frame
    roundify(preview, 6)

    local palette = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0),
    }

    for i, color in ipairs(palette) do
        local swatch = Instance.new("TextButton")
        swatch.Size = UDim2.new(0, 20, 0, 20)
        swatch.Position = UDim2.new(0, 35 + (i - 1) * 25, 0, 30)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        swatch.Parent = frame
        roundify(swatch, 5)

        swatch.MouseButton1Click:Connect(function()
            preview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
    end
end

-- Add dropdown to tab
function Library:AddDropdown(labelText, options, defaultIndex, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = tabContent

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = currentTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 25)
    button.Position = UDim2.new(0, 0, 0, 25)
    button.Text = options[defaultIndex] or options[1]
    button.TextColor3 = currentTheme.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BackgroundColor3 = currentTheme.Background:lerp(Color3.new(0.2,0.2,0.2), 0.2)
    button.BorderSizePixel = 0
    button.Parent = frame
    roundify(button, 6)

    local list = Instance.new("Frame")
    list.Visible = false
    list.Size = UDim2.new(1, 0, 0, #options * 25)
    list.Position = UDim2.new(0, 0, 0, 50)
    list.BackgroundColor3 = currentTheme.Background:lerp(Color3.new(0.1,0.1,0.1), 0.3)
    list.BorderSizePixel = 0
    list.Parent = frame
    roundify(list, 6)

    for i, option in ipairs(options) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 25)
        opt.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
        opt.Text = option
        opt.BackgroundTransparency = 1
        opt.TextColor3 = currentTheme.Text
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 14
    
