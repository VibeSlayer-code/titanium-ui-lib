local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Themes = {
    Dark = {
        Primary = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(25, 25, 35),
        Tertiary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(138, 43, 226),
        AccentHover = Color3.fromRGB(158, 63, 246),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(46, 213, 115),
        Warning = Color3.fromRGB(255, 159, 67),
        Error = Color3.fromRGB(255, 71, 87),
        Border = Color3.fromRGB(60, 60, 80)
    },
    Light = {
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(240, 240, 245),
        Accent = Color3.fromRGB(138, 43, 226),
        AccentHover = Color3.fromRGB(158, 63, 246),
        Text = Color3.fromRGB(20, 20, 30),
        TextDark = Color3.fromRGB(100, 100, 120),
        Success = Color3.fromRGB(46, 213, 115),
        Warning = Color3.fromRGB(255, 159, 67),
        Error = Color3.fromRGB(255, 71, 87),
        Border = Color3.fromRGB(220, 220, 230)
    },
    Midnight = {
        Primary = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(18, 18, 25),
        Tertiary = Color3.fromRGB(28, 28, 38),
        Accent = Color3.fromRGB(88, 166, 255),
        AccentHover = Color3.fromRGB(108, 186, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 170, 190),
        Success = Color3.fromRGB(46, 213, 115),
        Warning = Color3.fromRGB(255, 159, 67),
        Error = Color3.fromRGB(255, 71, 87),
        Border = Color3.fromRGB(50, 50, 70)
    },
    Ocean = {
        Primary = Color3.fromRGB(12, 20, 31),
        Secondary = Color3.fromRGB(20, 32, 48),
        Tertiary = Color3.fromRGB(31, 47, 67),
        Accent = Color3.fromRGB(0, 184, 217),
        AccentHover = Color3.fromRGB(20, 204, 237),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(170, 190, 210),
        Success = Color3.fromRGB(46, 213, 115),
        Warning = Color3.fromRGB(255, 159, 67),
        Error = Color3.fromRGB(255, 71, 87),
        Border = Color3.fromRGB(45, 60, 85)
    }
}

local CurrentTheme = Themes.Dark

local function Tween(object, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Tween(frame, {
                Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Linear)
        end
    end)
end

local function CreateRipple(button)
    button.ClipsDescendants = true
    
    button.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Parent = button
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        
        Tween(ripple, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }, 0.6, Enum.EasingStyle.Exponential)
        
        task.delay(0.6, function()
            ripple:Destroy()
        end)
    end)
end

local function CreateGlow(object, color, intensity)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/Glow.png"
    glow.ImageColor3 = color
    glow.ImageTransparency = 1 - (intensity or 0.3)
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 256, 256)
    glow.Size = UDim2.new(1, 60, 1, 60)
    glow.Position = UDim2.new(0, -30, 0, -30)
    glow.Parent = object
    return glow
end

local function CreateNotification(title, description, duration, notifType)
    local NotificationContainer = LocalPlayer.PlayerGui:FindFirstChild("UltraLibNotifications")
    
    if not NotificationContainer then
        NotificationContainer = Instance.new("ScreenGui")
        NotificationContainer.Name = "UltraLibNotifications"
        NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotificationContainer.Parent = LocalPlayer.PlayerGui
        
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.BackgroundTransparency = 1
        Container.Position = UDim2.new(1, -20, 1, -20)
        Container.Size = UDim2.new(0, 320, 1, 0)
        Container.AnchorPoint = Vector2.new(1, 1)
        Container.Parent = NotificationContainer
        
        local Layout = Instance.new("UIListLayout")
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 12)
        Layout.Parent = Container
    end
    
    local Container = NotificationContainer.Container
    
    local Notification = Instance.new("Frame")
    Notification.BackgroundColor3 = CurrentTheme.Secondary
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.ClipsDescendants = true
    Notification.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CurrentTheme.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Notification
    
    local Accent = Instance.new("Frame")
    Accent.BackgroundColor3 = notifType == "error" and CurrentTheme.Error or 
                              notifType == "warning" and CurrentTheme.Warning or 
                              notifType == "success" and CurrentTheme.Success or 
                              CurrentTheme.Accent
    Accent.BorderSizePixel = 0
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.Parent = Notification
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = Accent
    
    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 16, 0, 12)
    Content.Size = UDim2.new(1, -32, 1, -24)
    Content.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = CurrentTheme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, -30, 0, 20)
    Title.Parent = Content
    
    local Description = Instance.new("TextLabel")
    Description.BackgroundTransparency = 1
    Description.Font = Enum.Font.Gotham
    Description.Text = description
    Description.TextColor3 = CurrentTheme.TextDark
    Description.TextSize = 12
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.Position = UDim2.new(0, 0, 0, 24)
    Description.Size = UDim2.new(1, -30, 1, -28)
    Description.Parent = Content
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = CurrentTheme.TextDark
    CloseButton.TextSize = 20
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.Position = UDim2.new(1, 0, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Parent = Content
    
    local textBounds = Description.TextBounds.Y
    local notifHeight = math.max(70, textBounds + 50)
    
    Tween(Notification, {Size = UDim2.new(1, 0, 0, notifHeight)}, 0.35, Enum.EasingStyle.Back)
    
    local function Close()
        Tween(Notification, {
            Size = UDim2.new(1, 0, 0, 0)
        }, 0.25, Enum.EasingStyle.Quart).Completed:Connect(function()
            Notification:Destroy()
        end)
    end
    
    CloseButton.MouseButton1Click:Connect(Close)
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = CurrentTheme.Text}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = CurrentTheme.TextDark}, 0.2)
    end)
    
    task.delay(duration or 5, Close)
end

function Library:Create(config)
    local WindowConfig = config or {}
    WindowConfig.Title = WindowConfig.Title or "Ultra Library"
    WindowConfig.Theme = WindowConfig.Theme or "Dark"
    WindowConfig.Size = WindowConfig.Size or {600, 450}
    WindowConfig.Keybind = WindowConfig.Keybind or Enum.KeyCode.RightShift
    
    CurrentTheme = Themes[WindowConfig.Theme] or Themes.Dark
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltraLib_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = CurrentTheme.Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -WindowConfig.Size[1]/2, 0.5, -WindowConfig.Size[2]/2)
    MainFrame.Size = UDim2.new(0, WindowConfig.Size[1], 0, WindowConfig.Size[2])
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = CurrentTheme.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = MainFrame
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Size = UDim2.new(1, 80, 1, 80)
    Shadow.Position = UDim2.new(0, -40, 0, -40)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = CurrentTheme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.BackgroundColor3 = CurrentTheme.Secondary
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Position = UDim2.new(0, 0, 1, -12)
    TopBarFix.Size = UDim2.new(1, 0, 0, 12)
    TopBarFix.Parent = TopBar
    
    local TopBarStroke = Instance.new("UIStroke")
    TopBarStroke.Color = CurrentTheme.Border
    TopBarStroke.Thickness = 1
    TopBarStroke.Transparency = 0.5
    TopBarStroke.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = WindowConfig.Title
    TitleLabel.TextColor3 = CurrentTheme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Size = UDim2.new(0.5, -20, 1, 0)
    TitleLabel.Parent = TopBar
    
    local TitleGlow = CreateGlow(TitleLabel, CurrentTheme.Accent, 0.15)
    
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.AnchorPoint = Vector2.new(1, 0)
    ControlsFrame.Position = UDim2.new(1, -10, 0, 0)
    ControlsFrame.Size = UDim2.new(0, 100, 1, 0)
    ControlsFrame.Parent = TopBar
    
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 8)
    ControlsLayout.Parent = ControlsFrame
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.BackgroundColor3 = CurrentTheme.Tertiary
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = CurrentTheme.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Parent = ControlsFrame
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeButton
    
    CreateRipple(MinimizeButton)
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.BackgroundColor3 = CurrentTheme.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Parent = ControlsFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CreateRipple(CloseButton)
    
    local isMinimized = false
    local originalSize = MainFrame.Size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(MainFrame, {Size = UDim2.new(0, WindowConfig.Size[1], 0, 45)}, 0.3, Enum.EasingStyle.Back)
            MinimizeButton.Text = "+"
        else
            Tween(MainFrame, {Size = originalSize}, 0.3, Enum.EasingStyle.Back)
            MinimizeButton.Text = "−"
        end
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = CurrentTheme.Error}, 0.2)
    end)
    
    MakeDraggable(MainFrame, TopBar)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.BackgroundColor3 = CurrentTheme.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.Size = UDim2.new(0, 160, 1, -45)
    TabContainer.Parent = MainFrame
    
    local TabContainerStroke = Instance.new("UIStroke")
    TabContainerStroke.Color = CurrentTheme.Border
    TabContainerStroke.Thickness = 1
    TabContainerStroke.Transparency = 0.5
    TabContainerStroke.Parent = TabContainer
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0, 10, 0, 15)
    TabList.Size = UDim2.new(1, -20, 1, -25)
    TabList.ScrollBarThickness = 4
    TabList.ScrollBarImageColor3 = CurrentTheme.Accent
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 160, 0, 45)
    ContentContainer.Size = UDim2.new(1, -160, 1, -45)
    ContentContainer.Parent = MainFrame
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Flags = {}
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == WindowConfig.Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    function Window:AddTab(tabName, icon)
        local Tab = {}
        Tab.Name = tabName
        Tab.Elements = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.BackgroundColor3 = CurrentTheme.Tertiary
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = CurrentTheme.TextDark
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.Parent = TabList
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = icon or "rbxassetid://7733717447"
        TabIcon.ImageColor3 = CurrentTheme.TextDark
        TabIcon.Position = UDim2.new(1, -30, 0.5, -10)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Parent = TabButton
        
        CreateRipple(TabButton)
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 15, 0, 15)
        TabContent.Size = UDim2.new(1, -30, 1, -30)
        TabContent.ScrollBarThickness = 5
        TabContent.ScrollBarImageColor3 = CurrentTheme.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Padding = UDim.new(0, 12)
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Parent = TabContent
        
        TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                Tween(tab.Button, {
                    BackgroundTransparency = 1,
                    TextColor3 = CurrentTheme.TextDark
                }, 0.2)
                Tween(tab.Icon, {ImageColor3 = CurrentTheme.TextDark}, 0.2)
            end
            
            TabContent.Visible = true
            Window.CurrentTab = Tab
            Tween(TabButton, {
                BackgroundTransparency = 0,
                BackgroundColor3 = CurrentTheme.Accent,
                TextColor3 = CurrentTheme.Text
            }, 0.2)
            Tween(TabIcon, {ImageColor3 = CurrentTheme.Text}, 0.2)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.9}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Icon = TabIcon
        
        if not Window.CurrentTab then
            TabButton.MouseButton1Click:Fire()
        end
        
        table.insert(Window.Tabs, Tab)
        
        function Tab:AddSection(sectionName)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.BackgroundColor3 = CurrentTheme.Secondary
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 10)
            SectionCorner.Parent = SectionFrame
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = CurrentTheme.Border
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.7
            SectionStroke.Parent = SectionFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = CurrentTheme.Text
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Position = UDim2.new(0, 15, 0, 12)
            SectionTitle.Size = UDim2.new(1, -30, 0, 20)
            SectionTitle.Parent = SectionFrame
            
            local SectionDivider = Instance.new("Frame")
            SectionDivider.BackgroundColor3 = CurrentTheme.Border
            SectionDivider.BorderSizePixel = 0
            SectionDivider.Position = UDim2.new(0, 15, 0, 40)
            SectionDivider.Size = UDim2.new(1, -30, 0, 1)
            SectionDivider.Parent = SectionFrame
            
            local SectionContent = Instance.new("Frame")
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 15, 0, 50)
            SectionContent.Size = UDim2.new(1, -30, 1, -60)
            SectionContent.Parent = SectionFrame
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Padding = UDim.new(0, 10)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Parent = SectionContent
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 70)
            end)
            
            function Section:AddButton(config)
                config = config or {}
                config.Text = config.Text or "Button"
                config.Callback = config.Callback or function() end
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
                ButtonFrame.Parent = SectionContent
                
                local Button = Instance.new("TextButton")
                Button.BackgroundColor3 = CurrentTheme.Tertiary
                Button.BorderSizePixel = 0
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = config.Text
                Button.TextColor3 = CurrentTheme.Text
                Button.TextSize = 13
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Parent = ButtonFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 8)
                ButtonCorner.Parent = Button
                
                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Color = CurrentTheme.Border
                ButtonStroke.Thickness = 1
                ButtonStroke.Transparency = 0.7
                ButtonStroke.Parent = Button
                
                CreateRipple(Button)
                
                Button.MouseButton1Click:Connect(function()
                    pcall(config.Callback)
                    Tween(Button, {BackgroundColor3 = CurrentTheme.Accent}, 0.1).Completed:Connect(function()
                        Tween(Button, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    end)
                end)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {
                        BackgroundColor3 = CurrentTheme.Accent
                    }, 0.2)
                    Tween(ButtonStroke, {Transparency = 0.3}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {
                        BackgroundColor3 = CurrentTheme.Tertiary
                    }, 0.2)
                    Tween(ButtonStroke, {Transparency = 0.7}, 0.2)
                end)
            end
            
            function Section:AddToggle(config)
                config = config or {}
                config.Text = config.Text or "Toggle"
                config.Default = config.Default or false
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local toggled = config.Default
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.BackgroundColor3 = CurrentTheme.Tertiary
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
                ToggleFrame.Parent = SectionContent
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = CurrentTheme.Border
                ToggleStroke.Thickness = 1
                ToggleStroke.Transparency = 0.7
                ToggleStroke.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Font = Enum.Font.GothamSemibold
                ToggleButton.Text = config.Text
                ToggleButton.TextColor3 = CurrentTheme.Text
                ToggleButton.TextSize = 13
                ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
                ToggleButton.Position = UDim2.new(0, 15, 0, 0)
                ToggleButton.Size = UDim2.new(1, -60, 1, 0)
                ToggleButton.Parent = ToggleFrame
                
                local ToggleOuter = Instance.new("Frame")
                ToggleOuter.BackgroundColor3 = CurrentTheme.Primary
                ToggleOuter.BorderSizePixel = 0
                ToggleOuter.AnchorPoint = Vector2.new(1, 0.5)
                ToggleOuter.Position = UDim2.new(1, -12, 0.5, 0)
                ToggleOuter.Size = UDim2.new(0, 42, 0, 22)
                ToggleOuter.Parent = ToggleFrame
                
                local ToggleOuterCorner = Instance.new("UICorner")
                ToggleOuterCorner.CornerRadius = UDim.new(1, 0)
                ToggleOuterCorner.Parent = ToggleOuter
                
                local ToggleOuterStroke = Instance.new("UIStroke")
                ToggleOuterStroke.Color = CurrentTheme.Border
                ToggleOuterStroke.Thickness = 1.5
                ToggleOuterStroke.Transparency = 0.5
                ToggleOuterStroke.Parent = ToggleOuter
                
                local ToggleInner = Instance.new("Frame")
                ToggleInner.BackgroundColor3 = CurrentTheme.TextDark
                ToggleInner.BorderSizePixel = 0
                ToggleInner.Position = UDim2.new(0, 3, 0.5, -8)
                ToggleInner.Size = UDim2.new(0, 16, 0, 16)
                ToggleInner.Parent = ToggleOuter
                
                local ToggleInnerCorner = Instance.new("UICorner")
                ToggleInnerCorner.CornerRadius = UDim.new(1, 0)
                ToggleInnerCorner.Parent = ToggleInner
                
                CreateRipple(ToggleButton)
                
                local function UpdateToggle()
                    if toggled then
                        Tween(ToggleOuter, {BackgroundColor3 = CurrentTheme.Accent}, 0.25)
                        Tween(ToggleInner, {
                            Position = UDim2.new(1, -19, 0.5, -8),
                            BackgroundColor3 = CurrentTheme.Text
                        }, 0.25, Enum.EasingStyle.Back)
                        Tween(ToggleOuterStroke, {Transparency = 0.2}, 0.25)
                    else
                        Tween(ToggleOuter, {BackgroundColor3 = CurrentTheme.Primary}, 0.25)
                        Tween(ToggleInner, {
                            Position = UDim2.new(0, 3, 0.5, -8),
                            BackgroundColor3 = CurrentTheme.TextDark
                        }, 0.25, Enum.EasingStyle.Back)
                        Tween(ToggleOuterStroke, {Transparency = 0.5}, 0.25)
                    end
                    
                    if config.Flag then
                        Window.Flags[config.Flag] = toggled
                    end
                    
                    pcall(config.Callback, toggled)
                end
                
                UpdateToggle()
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateToggle()
                end)
                
                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(ToggleStroke, {Transparency = 0.3}, 0.2)
                end)
                
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    Tween(ToggleStroke, {Transparency = 0.7}, 0.2)
                end)
                
                return {
                    Set = function(self, value)
                        toggled = value
                        UpdateToggle()
                    end
                }
            end
            
            function Section:AddSlider(config)
                config = config or {}
                config.Text = config.Text or "Slider"
                config.Min = config.Min or 0
                config.Max = config.Max or 100
                config.Default = config.Default or 50
                config.Increment = config.Increment or 1
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local value = config.Default
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.BackgroundColor3 = CurrentTheme.Tertiary
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Size = UDim2.new(1, 0, 0, 65)
                SliderFrame.Parent = SectionContent
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 8)
                SliderCorner.Parent = SliderFrame
                
                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = CurrentTheme.Border
                SliderStroke.Thickness = 1
                SliderStroke.Transparency = 0.7
                SliderStroke.Parent = SliderFrame
                
                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Font = Enum.Font.GothamSemibold
                SliderTitle.Text = config.Text
                SliderTitle.TextColor3 = CurrentTheme.Text
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Position = UDim2.new(0, 15, 0, 10)
                SliderTitle.Size = UDim2.new(0.6, -15, 0, 20)
                SliderTitle.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.BackgroundTransparency = 1
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(value)
                SliderValue.TextColor3 = CurrentTheme.Accent
                SliderValue.TextSize = 13
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Position = UDim2.new(0.6, 0, 0, 10)
                SliderValue.Size = UDim2.new(0.4, -15, 0, 20)
                SliderValue.Parent = SliderFrame
                
                local SliderBar = Instance.new("Frame")
                SliderBar.BackgroundColor3 = CurrentTheme.Primary
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0, 15, 0, 38)
                SliderBar.Size = UDim2.new(1, -30, 0, 8)
                SliderBar.Parent = SliderFrame
                
                local SliderBarCorner = Instance.new("UICorner")
                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Parent = SliderBar
                
                local SliderFill = Instance.new("Frame")
                SliderFill.BackgroundColor3 = CurrentTheme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
                SliderFill.Parent = SliderBar
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderDot = Instance.new("Frame")
                SliderDot.BackgroundColor3 = CurrentTheme.Text
                SliderDot.BorderSizePixel = 0
                SliderDot.AnchorPoint = Vector2.new(1, 0.5)
                SliderDot.Position = UDim2.new(1, 0, 0.5, 0)
                SliderDot.Size = UDim2.new(0, 16, 0, 16)
                SliderDot.Parent = SliderFill
                
                local SliderDotCorner = Instance.new("UICorner")
                SliderDotCorner.CornerRadius = UDim.new(1, 0)
                SliderDotCorner.Parent = SliderDot
                
                local SliderDotStroke = Instance.new("UIStroke")
                SliderDotStroke.Color = CurrentTheme.Accent
                SliderDotStroke.Thickness = 2
                SliderDotStroke.Parent = SliderDot
                
                local dragging = false
                
                local function UpdateSlider(input)
                    local posX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    value = math.floor((config.Min + (config.Max - config.Min) * posX) / config.Increment + 0.5) * config.Increment
                    value = math.clamp(value, config.Min, config.Max)
                    
                    SliderValue.Text = tostring(value)
                    Tween(SliderFill, {Size = UDim2.new(posX, 0, 1, 0)}, 0.1)
                    
                    if config.Flag then
                        Window.Flags[config.Flag] = value
                    end
                    
                    pcall(config.Callback, value)
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                        Tween(SliderDot, {Size = UDim2.new(0, 20, 0, 20)}, 0.15, Enum.EasingStyle.Back)
                    end
                end)
                
                SliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        Tween(SliderDot, {Size = UDim2.new(0, 16, 0, 16)}, 0.15, Enum.EasingStyle.Back)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(SliderStroke, {Transparency = 0.3}, 0.2)
                end)
                
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    Tween(SliderStroke, {Transparency = 0.7}, 0.2)
                end)
                
                return {
                    Set = function(self, val)
                        value = math.clamp(val, config.Min, config.Max)
                        SliderValue.Text = tostring(value)
                        Tween(SliderFill, {
                            Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
                        }, 0.2)
                        if config.Flag then
                            Window.Flags[config.Flag] = value
                        end
                        pcall(config.Callback, value)
                    end
                }
            end
            
            function Section:AddDropdown(config)
                config = config or {}
                config.Text = config.Text or "Dropdown"
                config.Options = config.Options or {"Option 1", "Option 2", "Option 3"}
                config.Default = config.Default or config.Options[1]
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local selected = config.Default
                local isOpen = false
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.BackgroundColor3 = CurrentTheme.Tertiary
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = SectionContent
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 8)
                DropdownCorner.Parent = DropdownFrame
                
                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = CurrentTheme.Border
                DropdownStroke.Thickness = 1
                DropdownStroke.Transparency = 0.7
                DropdownStroke.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Font = Enum.Font.GothamSemibold
                DropdownButton.Text = config.Text .. ": " .. selected
                DropdownButton.TextColor3 = CurrentTheme.Text
                DropdownButton.TextSize = 13
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.Position = UDim2.new(0, 15, 0, 0)
                DropdownButton.Size = UDim2.new(1, -40, 0, 38)
                DropdownButton.Parent = DropdownFrame
                
                local DropdownIcon = Instance.new("TextLabel")
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Font = Enum.Font.GothamBold
                DropdownIcon.Text = "▼"
                DropdownIcon.TextColor3 = CurrentTheme.TextDark
                DropdownIcon.TextSize = 10
                DropdownIcon.AnchorPoint = Vector2.new(1, 0.5)
                DropdownIcon.Position = UDim2.new(1, -15, 0, 19)
                DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
                DropdownIcon.Parent = DropdownFrame
                
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.BackgroundTransparency = 1
                OptionsContainer.Position = UDim2.new(0, 8, 0, 45)
                OptionsContainer.Size = UDim2.new(1, -16, 0, 0)
                OptionsContainer.Parent = DropdownFrame
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Padding = UDim.new(0, 4)
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsContainer
                
                for _, option in ipairs(config.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.BackgroundColor3 = CurrentTheme.Primary
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = "  " .. option
                    OptionButton.TextColor3 = CurrentTheme.Text
                    OptionButton.TextSize = 12
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.Size = UDim2.new(1, 0, 0, 32)
                    OptionButton.Parent = OptionsContainer
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 6)
                    OptionCorner.Parent = OptionButton
                    
                    CreateRipple(OptionButton)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = config.Text .. ": " .. selected
                        
                        isOpen = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 38)}, 0.25, Enum.EasingStyle.Quart)
                        Tween(DropdownIcon, {Rotation = 0}, 0.25)
                        
                        if config.Flag then
                            Window.Flags[config.Flag] = selected
                        end
                        
                        pcall(config.Callback, selected)
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.15)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = CurrentTheme.Primary}, 0.15)
                    end)
                end
                
                OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionsContainer.Size = UDim2.new(1, -16, 0, OptionsLayout.AbsoluteContentSize.Y)
                end)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        Tween(DropdownFrame, {
                            Size = UDim2.new(1, 0, 0, 53 + OptionsLayout.AbsoluteContentSize.Y)
                        }, 0.25, Enum.EasingStyle.Quart)
                        Tween(DropdownIcon, {Rotation = 180}, 0.25)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 38)}, 0.25, Enum.EasingStyle.Quart)
                        Tween(DropdownIcon, {Rotation = 0}, 0.25)
                    end
                end)
                
                DropdownFrame.MouseEnter:Connect(function()
                    Tween(DropdownFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(DropdownStroke, {Transparency = 0.3}, 0.2)
                end)
                
                DropdownFrame.MouseLeave:Connect(function()
                    Tween(DropdownFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    Tween(DropdownStroke, {Transparency = 0.7}, 0.2)
                end)
                
                return {
                    Set = function(self, option)
                        if table.find(config.Options, option) then
                            selected = option
                            DropdownButton.Text = config.Text .. ": " .. selected
                            if config.Flag then
                                Window.Flags[config.Flag] = selected
                            end
                            pcall(config.Callback, selected)
                        end
                    end
                }
            end
            
            function Section:AddTextbox(config)
                config = config or {}
                config.Text = config.Text or "Textbox"
                config.Placeholder = config.Placeholder or "Enter text..."
                config.Default = config.Default or ""
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.BackgroundColor3 = CurrentTheme.Tertiary
                TextboxFrame.BorderSizePixel = 0
                TextboxFrame.Size = UDim2.new(1, 0, 0, 65)
                TextboxFrame.Parent = SectionContent
                
                local TextboxCorner = Instance.new("UICorner")
                TextboxCorner.CornerRadius = UDim.new(0, 8)
                TextboxCorner.Parent = TextboxFrame
                
                local TextboxStroke = Instance.new("UIStroke")
                TextboxStroke.Color = CurrentTheme.Border
                TextboxStroke.Thickness = 1
                TextboxStroke.Transparency = 0.7
                TextboxStroke.Parent = TextboxFrame
                
                local TextboxTitle = Instance.new("TextLabel")
                TextboxTitle.BackgroundTransparency = 1
                TextboxTitle.Font = Enum.Font.GothamSemibold
                TextboxTitle.Text = config.Text
                TextboxTitle.TextColor3 = CurrentTheme.Text
                TextboxTitle.TextSize = 13
                TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left
                TextboxTitle.Position = UDim2.new(0, 15, 0, 10)
                TextboxTitle.Size = UDim2.new(1, -30, 0, 20)
                TextboxTitle.Parent = TextboxFrame
                
                local TextboxInput = Instance.new("TextBox")
                TextboxInput.BackgroundColor3 = CurrentTheme.Primary
                TextboxInput.BorderSizePixel = 0
                TextboxInput.Font = Enum.Font.Gotham
                TextboxInput.PlaceholderText = config.Placeholder
                TextboxInput.PlaceholderColor3 = CurrentTheme.TextDark
                TextboxInput.Text = config.Default
                TextboxInput.TextColor3 = CurrentTheme.Text
                TextboxInput.TextSize = 12
                TextboxInput.TextXAlignment = Enum.TextXAlignment.Left
                TextboxInput.Position = UDim2.new(0, 15, 0, 35)
                TextboxInput.Size = UDim2.new(1, -30, 0, 22)
                TextboxInput.ClearTextOnFocus = false
                TextboxInput.Parent = TextboxFrame
                
                local TextboxInputCorner = Instance.new("UICorner")
                TextboxInputCorner.CornerRadius = UDim.new(0, 6)
                TextboxInputCorner.Parent = TextboxInput
                
                local TextboxInputPadding = Instance.new("UIPadding")
                TextboxInputPadding.PaddingLeft = UDim.new(0, 10)
                TextboxInputPadding.PaddingRight = UDim.new(0, 10)
                TextboxInputPadding.Parent = TextboxInput
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        if config.Flag then
                            Window.Flags[config.Flag] = TextboxInput.Text
                        end
                        pcall(config.Callback, TextboxInput.Text)
                    end
                end)
                
                TextboxInput.Focused:Connect(function()
                    Tween(TextboxStroke, {Color = CurrentTheme.Accent, Transparency = 0.3}, 0.2)
                end)
                
                TextboxInput.FocusLost:Connect(function()
                    Tween(TextboxStroke, {Color = CurrentTheme.Border, Transparency = 0.7}, 0.2)
                end)
                
                TextboxFrame.MouseEnter:Connect(function()
                    Tween(TextboxFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                end)
                
                TextboxFrame.MouseLeave:Connect(function()
                    Tween(TextboxFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                end)
                
                return {
                    Set = function(self, text)
                        TextboxInput.Text = text
                        if config.Flag then
                            Window.Flags[config.Flag] = text
                        end
                        pcall(config.Callback, text)
                    end
                }
            end
            
            function Section:AddKeybind(config)
                config = config or {}
                config.Text = config.Text or "Keybind"
                config.Default = config.Default or Enum.KeyCode.None
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local currentKey = config.Default
                local binding = false
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.BackgroundColor3 = CurrentTheme.Tertiary
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
                KeybindFrame.Parent = SectionContent
                
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 8)
                KeybindCorner.Parent = KeybindFrame
                
                local KeybindStroke = Instance.new("UIStroke")
                KeybindStroke.Color = CurrentTheme.Border
                KeybindStroke.Thickness = 1
                KeybindStroke.Transparency = 0.7
                KeybindStroke.Parent = KeybindFrame
                
                local KeybindTitle = Instance.new("TextLabel")
                KeybindTitle.BackgroundTransparency = 1
                KeybindTitle.Font = Enum.Font.GothamSemibold
                KeybindTitle.Text = config.Text
                KeybindTitle.TextColor3 = CurrentTheme.Text
                KeybindTitle.TextSize = 13
                KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
                KeybindTitle.Position = UDim2.new(0, 15, 0, 0)
                KeybindTitle.Size = UDim2.new(0.6, -15, 1, 0)
                KeybindTitle.Parent = KeybindFrame
                
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.BackgroundColor3 = CurrentTheme.Primary
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Font = Enum.Font.GothamBold
                KeybindButton.Text = currentKey.Name
                KeybindButton.TextColor3 = CurrentTheme.Accent
                KeybindButton.TextSize = 11
                KeybindButton.AnchorPoint = Vector2.new(1, 0.5)
                KeybindButton.Position = UDim2.new(1, -12, 0.5, 0)
                KeybindButton.Size = UDim2.new(0, 85, 0, 26)
                KeybindButton.Parent = KeybindFrame
                
                local KeybindButtonCorner = Instance.new("UICorner")
                KeybindButtonCorner.CornerRadius = UDim.new(0, 6)
                KeybindButtonCorner.Parent = KeybindButton
                
                CreateRipple(KeybindButton)
                
                KeybindButton.MouseButton1Click:Connect(function()
                    binding = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeybindButton.Text = currentKey.Name
                            binding = false
                            Tween(KeybindButton, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                            
                            if config.Flag then
                                Window.Flags[config.Flag] = currentKey
                            end
                        end
                    elseif not gameProcessed and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.None then
                        pcall(config.Callback)
                    end
                end)
                
                KeybindFrame.MouseEnter:Connect(function()
                    Tween(KeybindFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(KeybindStroke, {Transparency = 0.3}, 0.2)
                end)
                
                KeybindFrame.MouseLeave:Connect(function()
                    Tween(KeybindFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    Tween(KeybindStroke, {Transparency = 0.7}, 0.2)
                end)
                
                return {
                    Set = function(self, key)
                        currentKey = key
                        KeybindButton.Text = currentKey.Name
                        if config.Flag then
                            Window.Flags[config.Flag] = currentKey
                        end
                    end
                }
            end
            
            function Section:AddLabel(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, 25)
                LabelFrame.Parent = SectionContent
                
                local Label = Instance.new("TextLabel")
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.Text = text
                Label.TextColor3 = CurrentTheme.TextDark
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.Parent = LabelFrame
                
                return {
                    Set = function(self, newText)
                        Label.Text = newText
                    end
                }
            end
            
            function Section:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.BackgroundColor3 = CurrentTheme.Border
                Divider.BorderSizePixel = 0
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.Parent = SectionContent
            end
            
            function Section:AddColorPicker(config)
                config = config or {}
                config.Text = config.Text or "Color Picker"
                config.Default = config.Default or Color3.fromRGB(255, 255, 255)
                config.Flag = config.Flag or nil
                config.Callback = config.Callback or function() end
                
                local currentColor = config.Default
                
                local ColorPickerFrame = Instance.new("Frame")
                ColorPickerFrame.BackgroundColor3 = CurrentTheme.Tertiary
                ColorPickerFrame.BorderSizePixel = 0
                ColorPickerFrame.Size = UDim2.new(1, 0, 0, 38)
                ColorPickerFrame.Parent = SectionContent
                
                local ColorPickerCorner = Instance.new("UICorner")
                ColorPickerCorner.CornerRadius = UDim.new(0, 8)
                ColorPickerCorner.Parent = ColorPickerFrame
                
                local ColorPickerStroke = Instance.new("UIStroke")
                ColorPickerStroke.Color = CurrentTheme.Border
                ColorPickerStroke.Thickness = 1
                ColorPickerStroke.Transparency = 0.7
                ColorPickerStroke.Parent = ColorPickerFrame
                
                local ColorPickerTitle = Instance.new("TextLabel")
                ColorPickerTitle.BackgroundTransparency = 1
                ColorPickerTitle.Font = Enum.Font.GothamSemibold
                ColorPickerTitle.Text = config.Text
                ColorPickerTitle.TextColor3 = CurrentTheme.Text
                ColorPickerTitle.TextSize = 13
                ColorPickerTitle.TextXAlignment = Enum.TextXAlignment.Left
                ColorPickerTitle.Position = UDim2.new(0, 15, 0, 0)
                ColorPickerTitle.Size = UDim2.new(0.7, -15, 1, 0)
                ColorPickerTitle.Parent = ColorPickerFrame
                
                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.BackgroundColor3 = currentColor
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.AnchorPoint = Vector2.new(1, 0.5)
                ColorDisplay.Position = UDim2.new(1, -12, 0.5, 0)
                ColorDisplay.Size = UDim2.new(0, 60, 0, 26)
                ColorDisplay.Parent = ColorPickerFrame
                
                local ColorDisplayCorner = Instance.new("UICorner")
                ColorDisplayCorner.CornerRadius = UDim.new(0, 6)
                ColorDisplayCorner.Parent = ColorDisplay
                
                local ColorDisplayStroke = Instance.new("UIStroke")
                ColorDisplayStroke.Color = CurrentTheme.Border
                ColorDisplayStroke.Thickness = 1.5
                ColorDisplayStroke.Parent = ColorDisplay
                
                local ColorButton = Instance.new("TextButton")
                ColorButton.BackgroundTransparency = 1
                ColorButton.Text = ""
                ColorButton.Size = UDim2.new(1, 0, 1, 0)
                ColorButton.Parent = ColorDisplay
                
                CreateRipple(ColorButton)
                
                ColorButton.MouseButton1Click:Connect(function()
                    CreateNotification(
                        "Color Picker",
                        "Advanced color picker coming soon! Using default color.",
                        3,
                        "warning"
                    )
                end)
                
                ColorPickerFrame.MouseEnter:Connect(function()
                    Tween(ColorPickerFrame, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(ColorPickerStroke, {Transparency = 0.3}, 0.2)
                end)
                
                ColorPickerFrame.MouseLeave:Connect(function()
                    Tween(ColorPickerFrame, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                    Tween(ColorPickerStroke, {Transparency = 0.7}, 0.2)
                end)
                
                return {
                    Set = function(self, color)
                        currentColor = color
                        ColorDisplay.BackgroundColor3 = color
                        if config.Flag then
                            Window.Flags[config.Flag] = color
                        end
                        pcall(config.Callback, color)
                    end
                }
            end
            
            return Section
        end
        
        return Tab
    end
    
    function Window:Notify(config)
        config = config or {}
        CreateNotification(
            config.Title or "Notification",
            config.Description or "This is a notification",
            config.Duration or 5,
            config.Type or "info"
        )
    end
    
    function Window:AddWatermark(text)
        local Watermark = Instance.new("Frame")
        Watermark.Name = "Watermark"
        Watermark.BackgroundColor3 = CurrentTheme.Secondary
        Watermark.BorderSizePixel = 0
        Watermark.Position = UDim2.new(0, 10, 0, 10)
        Watermark.Size = UDim2.new(0, 0, 0, 30)
        Watermark.Parent = ScreenGui
        
        local WatermarkCorner = Instance.new("UICorner")
        WatermarkCorner.CornerRadius = UDim.new(0, 8)
        WatermarkCorner.Parent = Watermark
        
        local WatermarkStroke = Instance.new("UIStroke")
        WatermarkStroke.Color = CurrentTheme.Border
        WatermarkStroke.Thickness = 1
        WatermarkStroke.Transparency = 0.5
        WatermarkStroke.Parent = Watermark
        
        local WatermarkText = Instance.new("TextLabel")
        WatermarkText.BackgroundTransparency = 1
        WatermarkText.Font = Enum.Font.GothamBold
        WatermarkText.Text = text or "Ultra Library"
        WatermarkText.TextColor3 = CurrentTheme.Text
        WatermarkText.TextSize = 12
        WatermarkText.Position = UDim2.new(0, 12, 0, 0)
        WatermarkText.Size = UDim2.new(1, -24, 1, 0)
        WatermarkText.Parent = Watermark
        
        local textSize = game:GetService("TextService"):GetTextSize(
            WatermarkText.Text,
            WatermarkText.TextSize,
            WatermarkText.Font,
            Vector2.new(math.huge, math.huge)
        )
        
        Tween(Watermark, {Size = UDim2.new(0, textSize.X + 24, 0, 30)}, 0.3, Enum.EasingStyle.Back)
        
        return {
            Set = function(self, newText)
                WatermarkText.Text = newText
                local newSize = game:GetService("TextService"):GetTextSize(
                    newText,
                    WatermarkText.TextSize,
                    WatermarkText.Font,
                    Vector2.new(math.huge, math.huge)
                )
                Tween(Watermark, {Size = UDim2.new(0, newSize.X + 24, 0, 30)}, 0.2)
            end,
            Remove = function(self)
                Watermark:Destroy()
            end
        }
    end
    
    CreateNotification("Welcome!", WindowConfig.Title .. " has been loaded successfully!", 4, "success")
    
    return Window
end

return Library