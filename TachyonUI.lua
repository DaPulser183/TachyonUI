--[[
    TachyonUI - Advanced Modern Roblox UI Library
    Version: 1.0.1 - FIXED
    Developer: Antigravity (Enhanced by Tachyon Reverse)
   
    Features:
    - Glassmorphism & Modern Aesthetics
    - Responsive Scaling & Smooth Animations
    - Theme Support (Dark/Light/Custom)
    - Clean, Chainable API
    - Performance Optimized
    - FIXED: gethui() nil call errors
    - FIXED: Missing table initializations
    - FIXED: Toggle key binding
    - Compatible with ALL executors (Synapse, Krnl, Fluxus, Studio)
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

-- FIXED: Safe gethui() with proper nil checks
local function safeGetHui()
    local success, result = pcall(function()
        if gethui and type(gethui) == "function" then
            return gethui()
        end
    end)
    return success and result or nil
end

-- FIXED: Ultra-safe Parent fallback chain
local Parent = safeGetHui() 
    or (syn and syn.protect_gui and function() 
        local gui = Instance.new("ScreenGui")
        pcall(syn.protect_gui, gui)
        gui.Parent = CoreGui
        return gui 
    end) 
    or CoreGui:FindFirstChild("RobloxGui") 
    or CoreGui 
    or LocalPlayer:WaitForChild("PlayerGui")

-- FIXED: Initialize missing tables
TachyonUI.Windows = {}
TachyonUI.ToggleKey = Enum.KeyCode.RightShift  -- Default toggle key

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
    -- TODO: Update existing elements if any (advanced feature)
end

--[ Global Toggle Handler - FIXED ]--
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == TachyonUI.ToggleKey then
        for _, window in pairs(TachyonUI.Windows) do
            if window.Container then
                window.Container.Visible = not window.Container.Visible
            end
        end
    end
end)

--[ Notifications ]--
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
    if self.Watermark then 
        self.Watermark:Destroy() 
    end
   
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
    Label.Text = text or "TachyonUI v1.0.1"
    Label.TextColor3 = self.SelectedTheme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.Parent = Frame
   
    Utils:MakeDraggable(Frame, Frame)
    self.Watermark = WatermarkGui
end

function TachyonUI:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Tachyon UI"
    local Size = options.Size or UDim2.new(0, 600, 0, 450)
    local Theme = options.Theme or "Dark"
   
    self:SetTheme(Theme)
    self:Notify({Title = "UI Loaded", Content = "TachyonUI v1.0.1", Duration = 2})
   
    local Main = {}
    Main.Tabs = {}
    Main.CurrentTab = nil
    Main.Elements = {}  -- FIXED: For search functionality
   
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
    Main.Container = Container
   
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
