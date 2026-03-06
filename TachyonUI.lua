--[[
    TachyonUI - Advanced Modern Roblox UI Library
    Version: 1.0.0
    Developer: Antigravity (Google DeepMind)
    
    Features:
    - Glassmorphism & Modern Aesthetics
    - Responsive Scaling & Smooth Animations
    - Theme Support (Dark/Light/Custom)
    - Clean, Chainable API
    - Performance Optimized
]]

local TachyonUI = {}
TachyonUI.__index = TachyonUI

--[ Services ]--
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--[ Variables ]--
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Parent = (gethui and gethui()) or (CoreGui:FindFirstChild("RobloxGui") or CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

--[ Utility Functions ]--
local Utils = {}

function Utils:Tween(instance, duration, properties, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(instance, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    return tween
end

function Utils:MakeDraggable(gui, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--[ Theme System ]--
TachyonUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Sidebar = Color3.fromRGB(25, 25, 25),
        Section = Color3.fromRGB(30, 30, 30),
        Element = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(50, 50, 50),
        Hover = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(0, 120, 200)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Sidebar = Color3.fromRGB(230, 230, 230),
        Section = Color3.fromRGB(220, 220, 220),
        Element = Color3.fromRGB(210, 210, 210),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(40, 40, 40),
        TextMuted = Color3.fromRGB(100, 100, 100),
        Stroke = Color3.fromRGB(180, 180, 180),
        Hover = Color3.fromRGB(190, 190, 190),
        Secondary = Color3.fromRGB(0, 100, 220)
    }
}

TachyonUI.SelectedTheme = TachyonUI.Themes.Dark

function TachyonUI:SetTheme(themeNameOrTable)
    if type(themeNameOrTable) == "string" and TachyonUI.Themes[themeNameOrTable] then
        TachyonUI.SelectedTheme = TachyonUI.Themes[themeNameOrTable]
    elseif type(themeNameOrTable) == "table" then
        for k, v in pairs(themeNameOrTable) do
            TachyonUI.SelectedTheme[k] = v
        end
    end
    -- TODO: Update existing elements if any
end

--[ Core Library Methods ]--
function TachyonUI:Notify(options)
    options = options or {}
    local Title = options.Title or "Notification"
    local Content = options.Content or "Hello World"
    local Duration = options.Duration or 5
    
    local NotificationGui = Parent:FindFirstChild("TachyonNotifications")
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "TachyonNotifications"
        NotificationGui.Parent = Parent
        
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 10)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.HorizontalAlignment = Enum.HorizontalAlignment.Right
        List.Parent = NotificationGui
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 20)
        Padding.PaddingRight = UDim.new(0, 20)
        Padding.Parent = NotificationGui
    end
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 250, 0, 0)
    NotifyFrame.BackgroundColor3 = self.SelectedTheme.Background
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.ClipsDescendants = true
    NotifyFrame.Parent = NotificationGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = NotifyFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.SelectedTheme.Accent
    Stroke.Thickness = 1
    Stroke.Parent = NotifyFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = self.SelectedTheme.Accent
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifyFrame
    
    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -20, 0, 35)
    ContentLabel.Position = UDim2.new(0, 10, 0, 30)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = Content
    ContentLabel.TextColor3 = self.SelectedTheme.Text
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextSize = 12
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextWrapped = true
    ContentLabel.Parent = NotifyFrame
    
    Utils:Tween(NotifyFrame, 0.3, {Size = UDim2.new(0, 250, 0, 70)})
    
    task.delay(Duration, function()
        Utils:Tween(NotifyFrame, 0.3, {Size = UDim2.new(0, 250, 0, 0)})
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

function TachyonUI:SetWatermark(text)
    if self.Watermark then self.Watermark:Destroy() end
    
    local WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name = "TachyonWatermark"
    WatermarkGui.Parent = Parent
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 30)
    Frame.Position = UDim2.new(0, 20, 0, 20)
    Frame.BackgroundColor3 = self.SelectedTheme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = WatermarkGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.SelectedTheme.Accent
    Stroke.Thickness = 1
    Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = self.SelectedTheme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.Parent = Frame
    
    Utils:MakeDraggable(Frame, Frame)
    self.Watermark = WatermarkGui
end

function TachyonUI:ToggleUI()
    self.Visible = not self.Visible
    -- This will be linked to the specific Window's Main frame later
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == TachyonUI.ToggleKey then
        TachyonUI:ToggleUI()
    end
end)
function TachyonUI:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Tachyon UI"
    local Size = options.Size or UDim2.new(0, 600, 0, 450)
    local Theme = options.Theme or "Dark"
    
    self:SetTheme(Theme)
    
    local Main = {}
    Main.Tabs = {}
    Main.CurrentTab = nil
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Parent
    
    Main.ScreenGui = ScreenGui
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Main"
    Container.Size = Size
    Container.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    Container.BackgroundColor3 = self.SelectedTheme.Background
    Container.BorderSizePixel = 0
    Container.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.SelectedTheme.Stroke
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Container
    
    Utils:MakeDraggable(Container, Container)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = self.SelectedTheme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Container
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = self.SelectedTheme.Accent
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = Sidebar
    
    -- Search bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "Search"
    SearchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    SearchFrame.Position = UDim2.new(0.05, 0, 0, 45)
    SearchFrame.BackgroundColor3 = self.SelectedTheme.Element
    SearchFrame.Parent = Sidebar
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchFrame
    
    local SearchInput = Instance.new("TextBox")
    SearchInput.Size = UDim2.new(1, -10, 1, 0)
    SearchInput.Position = UDim2.new(0, 5, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = self.SelectedTheme.Text
    SearchInput.PlaceholderColor3 = self.SelectedTheme.TextMuted
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 12
    SearchInput.Parent = SearchFrame
    
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, tab in pairs(Main.Tabs) do
            local foundInTab = false
            for _, element in pairs(tab.Elements) do
                if element.Instance.Name:lower():find(query) then
                    element.Instance.Visible = true
                    foundInTab = true
                else
                    element.Instance.Visible = false
                end
            end
            tab.Button.Visible = (tab.Button.Name:lower():find(query) ~= nil) or foundInTab
        end
    end)
    
    -- Tab Scrolling Frame
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, -85)
    TabList.Position = UDim2.new(0, 0, 0, 85)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList

    Main.Container = Container
    table.insert(TachyonUI.Windows, Main)
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -170, 1, -20)
    Content.Position = UDim2.new(0, 165, 0, 10)
    Content.BackgroundTransparency = 1
    Content.Parent = Container
    
    Main.Content = Content
    
    function Main:CreateTab(name, icon)
        local Tab = {}
        Tab.Elements = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(0.9, 0, 0, 35)
        TabButton.BackgroundColor3 = TachyonUI.SelectedTheme.Element
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = TachyonUI.SelectedTheme.TextMuted
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabList
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = TachyonUI.SelectedTheme.Accent
        TabPage.Parent = Content
        
        local TabPageLayout = Instance.new("UIListLayout")
        TabPageLayout.Padding = UDim.new(0, 8)
        TabPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabPageLayout.Parent = TabPage
        
        local TabPagePadding = Instance.new("UIPadding")
        TabPagePadding.PaddingTop = UDim.new(0, 5)
        TabPagePadding.Parent = TabPage
        
        function Tab:Select()
            if Main.CurrentTab then
                Main.CurrentTab.Button.TextColor3 = TachyonUI.SelectedTheme.TextMuted
                Main.CurrentTab.Page.Visible = false
                Utils:Tween(Main.CurrentTab.Button, 0.3, {BackgroundColor3 = TachyonUI.SelectedTheme.Element})
            end
            
            Main.CurrentTab = Tab
            TabButton.TextColor3 = TachyonUI.SelectedTheme.Text
            TabPage.Visible = true
            Utils:Tween(TabButton, 0.3, {BackgroundColor3 = TachyonUI.SelectedTheme.Accent})
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)
        
        Tab.Button = TabButton
        Tab.Page = TabPage
        
        if not Main.CurrentTab then
            Tab:Select()
        end
        
        function Tab:CreateSection(title)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = title .. "Section"
            SectionFrame.Size = UDim2.new(0.95, 0, 0, 35)
            SectionFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Section
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabPage
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -20, 1, 0)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = title:upper()
            SectionTitle.TextColor3 = TachyonUI.SelectedTheme.Accent
            SectionTitle.TextSize = 12
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            -- Re-calculate container size based on elements
            local function UpdateSize()
                local contentSize = TabPageLayout.AbsoluteContentSize
                TabPage.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
            end
            
            TabPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
            
            return Section
        end
        
        function Tab:CreateButton(options)
            options = options or {}
            local Text = options.Text or "Button"
            local Callback = options.Callback or function() end
            
            local Button = {Name = Text, Instance = nil}
            
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = Text .. "Button"
            ButtonFrame.Size = UDim2.new(0.95, 0, 0, 35)
            ButtonFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Text = ""
            ButtonFrame.Parent = TabPage
            
            Button.Instance = ButtonFrame
            table.insert(Tab.Elements, Button)
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame
            
            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = TachyonUI.SelectedTheme.Stroke
            ButtonStroke.Thickness = 1
            ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ButtonStroke.Parent = ButtonFrame
            
            local ButtonText = Instance.new("TextLabel")
            ButtonText.Size = UDim2.new(1, 0, 1, 0)
            ButtonText.BackgroundTransparency = 1
            ButtonText.Text = Text
            ButtonText.TextColor3 = TachyonUI.SelectedTheme.Text
            ButtonText.Font = Enum.Font.GothamSemibold
            ButtonText.TextSize = 14
            ButtonText.Parent = ButtonFrame
            
            ButtonFrame.MouseButton1Down:Connect(function()
                Utils:Tween(ButtonFrame, 0.1, {BackgroundColor3 = TachyonUI.SelectedTheme.Hover})
            end)
            
            ButtonFrame.MouseButton1Up:Connect(function()
                Utils:Tween(ButtonFrame, 0.1, {BackgroundColor3 = TachyonUI.SelectedTheme.Element})
                Callback()
            end)
            
            ButtonFrame.MouseEnter:Connect(function()
                Utils:Tween(ButtonFrame, 0.2, {BackgroundColor3 = TachyonUI.SelectedTheme.Hover})
                Utils:Tween(ButtonStroke, 0.2, {Color = TachyonUI.SelectedTheme.Accent})
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                Utils:Tween(ButtonFrame, 0.2, {BackgroundColor3 = TachyonUI.SelectedTheme.Element})
                Utils:Tween(ButtonStroke, 0.2, {Color = TachyonUI.SelectedTheme.Stroke})
            end)
            
            function Button:SetText(newText)
                ButtonText.Text = newText
            end
            
            return Button
        end

        function Tab:CreateToggle(options)
            options = options or {}
            local Text = options.Text or "Toggle"
            local Default = options.Default or false
            local Callback = options.Callback or function() end
            
            local Toggle = {Name = Text, Value = Default, Instance = nil}
            
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = Text .. "Toggle"
            ToggleFrame.Size = UDim2.new(0.95, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Text = ""
            ToggleFrame.Parent = TabPage
            
            Toggle.Instance = ToggleFrame
            table.insert(Tab.Elements, Toggle)
            
            local ToggleCorner = Instance.new("UICorner")
-- ... (rest of logic remains same, just ensuring Toggle object has Name and Instance)
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Size = UDim2.new(1, -50, 1, 0)
            ToggleText.Position = UDim2.new(0, 10, 0, 0)
            ToggleText.BackgroundTransparency = 1
            ToggleText.Text = Text
            ToggleText.TextColor3 = TachyonUI.SelectedTheme.Text
            ToggleText.Font = Enum.Font.GothamSemibold
            ToggleText.TextSize = 14
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = ToggleFrame
            
            -- Toggle Switch
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -45, 0.5, -9)
            Switch.BackgroundColor3 = Toggle.Value and TachyonUI.SelectedTheme.Accent or TachyonUI.SelectedTheme.Secondary
            Switch.BorderSizePixel = 0
            Switch.Parent = ToggleFrame
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch
            
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 14, 0, 14)
            Indicator.Position = Toggle.Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.BorderSizePixel = 0
            Indicator.Parent = Switch
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = Indicator
            
            function Toggle:Set(state)
                Toggle.Value = state
                Utils:Tween(Switch, 0.2, {BackgroundColor3 = Toggle.Value and TachyonUI.SelectedTheme.Accent or TachyonUI.SelectedTheme.Secondary})
                Utils:Tween(Indicator, 0.2, {Position = Toggle.Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                Callback(Toggle.Value)
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.Value)
            end)
            
            return Toggle
        end

        function Tab:CreateSlider(options)
            options = options or {}
            local Text = options.Text or "Slider"
            local Min = options.Min or 0
            local Max = options.Max or 100
            local Default = options.Default or 50
            local Increment = options.Increment or 1
            local Callback = options.Callback or function() end
            
            local Slider = {Name = Text, Value = Default, Instance = nil}
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = Text .. "Slider"
            SliderFrame.Size = UDim2.new(0.95, 0, 0, 50)
            SliderFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabPage
            
            Slider.Instance = SliderFrame
            table.insert(Tab.Elements, Slider)
-- ... (rest of logic same)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderText = Instance.new("TextLabel")
            SliderText.Size = UDim2.new(1, -20, 0, 20)
            SliderText.Position = UDim2.new(0, 10, 0, 5)
            SliderText.BackgroundTransparency = 1
            SliderText.Text = Text
            SliderText.TextColor3 = TachyonUI.SelectedTheme.Text
            SliderText.Font = Enum.Font.GothamSemibold
            SliderText.TextSize = 14
            SliderText.TextXAlignment = Enum.TextXAlignment.Left
            SliderText.Parent = SliderFrame
            
            local ValueDisplay = Instance.new("TextLabel")
            ValueDisplay.Size = UDim2.new(0, 50, 0, 20)
            ValueDisplay.Position = UDim2.new(1, -60, 0, 5)
            ValueDisplay.BackgroundTransparency = 1
            ValueDisplay.Text = tostring(Default)
            ValueDisplay.TextColor3 = TachyonUI.SelectedTheme.Accent
            ValueDisplay.Font = Enum.Font.GothamBold
            ValueDisplay.TextSize = 14
            ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
            ValueDisplay.Parent = SliderFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 4)
            Track.Position = UDim2.new(0, 10, 1, -15)
            Track.BackgroundColor3 = TachyonUI.SelectedTheme.Secondary
            Track.BorderSizePixel = 0
            Track.Parent = SliderFrame
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            Fill.BackgroundColor3 = TachyonUI.SelectedTheme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Trigger = Instance.new("TextButton")
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.BackgroundTransparency = 1
            Trigger.Text = ""
            Trigger.Parent = SliderFrame
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local rawValue = pos * (Max - Min) + Min
                local value = math.floor(rawValue / Increment + 0.5) * Increment
                value = math.clamp(value, Min, Max)
                
                Slider.Value = value
                ValueDisplay.Text = tostring(value)
                Utils:Tween(Fill, 0.1, {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)})
                Callback(value)
            end
            
            local dragging = false
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            
            Trigger.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            function Slider:Set(value)
                value = math.clamp(value, Min, Max)
                Slider.Value = value
                ValueDisplay.Text = tostring(value)
                Utils:Tween(Fill, 0.2, {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)})
                Callback(value)
            end
            
            return Slider
        end

        function Tab:CreateDropdown(options)
            options = options or {}
            local Text = options.Text or "Dropdown"
            local Options = options.Options or {}
            local Default = options.Default
            local Multi = options.Multi or false
            local Callback = options.Callback or function() end
            
            local Dropdown = {Value = Default, Open = false, Options = Options}
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = Text .. "Dropdown"
            DropdownFrame.Size = UDim2.new(0.95, 0, 0, 35)
            DropdownFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabPage
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 35)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame
            
            local DropdownText = Instance.new("TextLabel")
            DropdownText.Size = UDim2.new(1, -40, 0, 35)
            DropdownText.Position = UDim2.new(0, 10, 0, 0)
            DropdownText.BackgroundTransparency = 1
            DropdownText.Text = Text .. ": " .. (tostring(Default) or "None")
            DropdownText.TextColor3 = TachyonUI.SelectedTheme.Text
            DropdownText.Font = Enum.Font.GothamSemibold
            DropdownText.TextSize = 14
            DropdownText.TextXAlignment = Enum.TextXAlignment.Left
            DropdownText.Parent = DropdownFrame
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 0, 35)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = TachyonUI.SelectedTheme.TextMuted
            Arrow.TextSize = 12
            Arrow.Parent = DropdownFrame
            
            local OptionList = Instance.new("Frame")
            OptionList.Name = "Options"
            OptionList.Size = UDim2.new(1, 0, 0, 0)
            OptionList.Position = UDim2.new(0, 0, 0, 35)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = DropdownFrame
            
            local OptionListLayout = Instance.new("UIListLayout")
            OptionListLayout.Padding = UDim.new(0, 2)
            OptionListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionListLayout.Parent = OptionList
            
            local function UpdateDropdown()
                local targetHeight = Dropdown.Open and (35 + OptionListLayout.AbsoluteContentSize.Y + 5) or 35
                Utils:Tween(DropdownFrame, 0.3, {Size = UDim2.new(0.95, 0, 0, targetHeight)})
                Arrow.Text = Dropdown.Open and "▲" or "▼"
            end
            
            local function CreateOption(name)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = name .. "Option"
                OptionButton.Size = UDim2.new(0.9, 0, 0, 30)
                OptionButton.BackgroundColor3 = TachyonUI.SelectedTheme.Hover
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = name
                OptionButton.TextColor3 = (Dropdown.Value == name) and TachyonUI.SelectedTheme.Accent or TachyonUI.SelectedTheme.Text
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 13
                OptionButton.Parent = OptionList
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton
                
                OptionButton.MouseButton1Click:Connect(function()
                    Dropdown.Value = name
                    DropdownText.Text = Text .. ": " .. name
                    for _, child in pairs(OptionList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = (child.Text == name) and TachyonUI.SelectedTheme.Accent or TachyonUI.SelectedTheme.Text
                        end
                    end
                    if not Multi then
                        Dropdown.Open = false
                        UpdateDropdown()
                    end
                    Callback(name)
                end)
            end
            
            for _, opt in pairs(Options) do
                CreateOption(opt)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                UpdateDropdown()
            end)
            
            function Dropdown:Set(value)
                Dropdown.Value = value
                DropdownText.Text = Text .. ": " .. tostring(value)
                Callback(value)
            end
            
            return Dropdown
        end

        function Tab:CreateKeybind(options)
            options = options or {}
            local Text = options.Text or "Keybind"
            local Default = options.Default or Enum.KeyCode.RightShift
            local Callback = options.Callback or function() end
            
            local Keybind = {Value = Default, Binding = false}
            
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = Text .. "Keybind"
            KeybindFrame.Size = UDim2.new(0.95, 0, 0, 35)
            KeybindFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabPage
            
            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 6)
            KeybindCorner.Parent = KeybindFrame
            
            local KeybindText = Instance.new("TextLabel")
            KeybindText.Size = UDim2.new(1, -80, 1, 0)
            KeybindText.Position = UDim2.new(0, 10, 0, 0)
            KeybindText.BackgroundTransparency = 1
            KeybindText.Text = Text
            KeybindText.TextColor3 = TachyonUI.SelectedTheme.Text
            KeybindText.Font = Enum.Font.GothamSemibold
            KeybindText.TextSize = 14
            KeybindText.TextXAlignment = Enum.TextXAlignment.Left
            KeybindText.Parent = KeybindFrame
            
            local BindButton = Instance.new("TextButton")
            BindButton.Size = UDim2.new(0, 70, 0, 25)
            BindButton.Position = UDim2.new(1, -80, 0.5, -12)
            BindButton.BackgroundColor3 = TachyonUI.SelectedTheme.Secondary
            BindButton.Text = Default.Name
            BindButton.TextColor3 = TachyonUI.SelectedTheme.Text
            BindButton.Font = Enum.Font.GothamBold
            BindButton.TextSize = 12
            BindButton.Parent = KeybindFrame
            
            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 4)
            BindCorner.Parent = BindButton
            
            BindButton.MouseButton1Click:Connect(function()
                Keybind.Binding = true
                BindButton.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if Keybind.Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind.Binding = false
                    Keybind.Value = input.KeyCode
                    BindButton.Text = input.KeyCode.Name
                    Callback(input.KeyCode)
                end
            end)
            
            return Keybind
        end

        function Tab:CreateColorpicker(options)
            options = options or {}
            local Text = options.Text or "Colorpicker"
            local Default = options.Default or Color3.fromRGB(255, 255, 255)
            local Callback = options.Callback or function() end
            
            local Colorpicker = {Value = Default}
            
            local ColorpickerFrame = Instance.new("Frame")
            ColorpickerFrame.Name = Text .. "Colorpicker"
            ColorpickerFrame.Size = UDim2.new(0.95, 0, 0, 35)
            ColorpickerFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            ColorpickerFrame.BorderSizePixel = 0
            ColorpickerFrame.Parent = TabPage
            
            local ColorpickerCorner = Instance.new("UICorner")
            ColorpickerCorner.CornerRadius = UDim.new(0, 6)
            ColorpickerCorner.Parent = ColorpickerFrame
            
            local ColorpickerText = Instance.new("TextLabel")
            ColorpickerText.Size = UDim2.new(1, -40, 1, 0)
            ColorpickerText.Position = UDim2.new(0, 10, 0, 0)
            ColorpickerText.BackgroundTransparency = 1
            ColorpickerText.Text = Text
            ColorpickerText.TextColor3 = TachyonUI.SelectedTheme.Text
            ColorpickerText.Font = Enum.Font.GothamSemibold
            ColorpickerText.TextSize = 14
            ColorpickerText.TextXAlignment = Enum.TextXAlignment.Left
            ColorpickerText.Parent = ColorpickerFrame
            
            local ColorDisplay = Instance.new("TextButton")
            ColorDisplay.Size = UDim2.new(0, 25, 0, 25)
            ColorDisplay.Position = UDim2.new(1, -35, 0.5, -12)
            ColorDisplay.BackgroundColor3 = Default
            ColorDisplay.Text = ""
            ColorDisplay.Parent = ColorpickerFrame
            
            local DisplayCorner = Instance.new("UICorner")
            DisplayCorner.CornerRadius = UDim.new(0, 4)
            DisplayCorner.Parent = ColorDisplay
            
            ColorDisplay.MouseButton1Click:Connect(function()
                -- Basic color rotation for demo
                local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 255)}
                local currentIndex = 1
                for i, v in ipairs(colors) do
                    if v == Colorpicker.Value then currentIndex = i break end
                end
                local nextColor = colors[(currentIndex % #colors) + 1]
                Colorpicker:Set(nextColor)
            end)
            
            function Colorpicker:Set(color)
                Colorpicker.Value = color
                ColorDisplay.BackgroundColor3 = color
                Callback(color)
            end
            
            return Colorpicker
        end

        function Tab:CreateTextbox(options)
            options = options or {}
            local Text = options.Text or "Textbox"
            local Placeholder = options.Placeholder or "Enter text..."
            local Default = options.Default or ""
            local Callback = options.Callback or function() end
            
            local Textbox = {Value = Default}
            
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Name = Text .. "Textbox"
            TextboxFrame.Size = UDim2.new(0.95, 0, 0, 35)
            TextboxFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Parent = TabPage
            
            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 6)
            TextboxCorner.Parent = TextboxFrame
            
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -20, 1, 0)
            Input.Position = UDim2.new(0, 10, 0, 0)
            Input.BackgroundTransparency = 1
            Input.Text = Default
            Input.PlaceholderText = Placeholder
            Input.TextColor3 = TachyonUI.SelectedTheme.Text
            Input.PlaceholderColor3 = TachyonUI.SelectedTheme.TextMuted
            Input.Font = Enum.Font.GothamSemibold
            Input.TextSize = 14
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.Parent = TextboxFrame
            
            Input.FocusLost:Connect(function(enterPressed)
                Textbox.Value = Input.Text
                Callback(Input.Text)
            end)
            
            function Textbox:Set(text)
                Textbox.Value = text
                Input.Text = text
                Callback(text)
            end
            
            return Textbox
        end

        function Tab:CreateLabel(text)
            local Label = {Instance = nil}
            local LabelFrame = Instance.new("TextLabel")
            LabelFrame.Name = text .. "Label"
            LabelFrame.Size = UDim2.new(0.95, 0, 0, 20)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Text = text
            LabelFrame.TextColor3 = TachyonUI.SelectedTheme.Text
            LabelFrame.Font = Enum.Font.Gotham
            LabelFrame.TextSize = 14
            LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
            LabelFrame.Parent = TabPage
            Label.Instance = LabelFrame
            table.insert(Tab.Elements, Label)
            return Label
        end

        function Tab:CreateParagraph(title, content)
            local Para = {Instance = nil}
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Name = title .. "Paragraph"
            ParaFrame.Size = UDim2.new(0.95, 0, 0, 60)
            ParaFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Element
            ParaFrame.BorderSizePixel = 0
            ParaFrame.Parent = TabPage
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = ParaFrame
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.BackgroundTransparency = 1
            Title.Text = title
            Title.TextColor3 = TachyonUI.SelectedTheme.Accent
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = ParaFrame
            
            local Desc = Instance.new("TextLabel")
            Desc.Size = UDim2.new(1, -20, 0, 30)
            Desc.Position = UDim2.new(0, 10, 0, 25)
            Desc.BackgroundTransparency = 1
            Desc.Text = content
            Desc.TextColor3 = TachyonUI.SelectedTheme.TextMuted
            Desc.Font = Enum.Font.Gotham
            Desc.TextSize = 12
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.TextWrapped = true
            Desc.Parent = ParaFrame
            
            Para.Instance = ParaFrame
            table.insert(Tab.Elements, Para)
            return Para
        end

        function Tab:CreateDivider()
            local Div = {Instance = nil}
            local DivFrame = Instance.new("Frame")
            DivFrame.Name = "Divider"
            DivFrame.Size = UDim2.new(0.9, 0, 0, 1)
            DivFrame.BackgroundColor3 = TachyonUI.SelectedTheme.Stroke
            DivFrame.BorderSizePixel = 0
            DivFrame.Parent = TabPage
            Div.Instance = DivFrame
            table.insert(Tab.Elements, Div)
            return Div
        end

        return Tab
    end
    
    return Main
end

return TachyonUI
