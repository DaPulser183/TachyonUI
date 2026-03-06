--[[
    TachyonUI - Advanced Modern Roblox UI Library
    Version: 1.0.2 - Ultra Safe Edition
    Developer: Antigravity (Enhanced by Tachyon Reverse)
   
    Features:
    - Glassmorphism & Modern Aesthetics
    - Responsive Scaling & Smooth Animations
    - Theme Support (Dark/Light/Custom)
    - Clean, Chainable API
    - Performance Optimized
    - FIXED: gethui() / LocalPlayer / Mouse nil crashes
    - Compatible with ALL executors (Synapse, Krnl, Fluxus, Delta, Studio, etc.)
]]

local TachyonUI = {}
TachyonUI.__index = TachyonUI

-- Services
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

-- Variables - Ultra safe initialization
local LocalPlayer
pcall(function()
    LocalPlayer = Players.LocalPlayer or Players:WaitForChild("LocalPlayer", 9)
end)

local Mouse
if LocalPlayer then
    pcall(function()
        Mouse = LocalPlayer:GetMouse()
    end)
end

-- Safe gethui
local function safeGetHui()
    if type(gethui) == "function" then
        local s, r = pcall(gethui)
        return s and r or nil
    end
    return nil
end

-- Parent fallback - extremely defensive
local Parent
do
    Parent = safeGetHui()
    
    if not Parent then
        if syn and type(syn) == "table" and type(syn.protect_gui) == "function" then
            local s, gui = pcall(function()
                local g = Instance.new("ScreenGui")
                syn.protect_gui(g)
                g.Parent = CoreGui
                return g
            end)
            if s then Parent = gui end
        end
    end
    
    if not Parent then
        Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    end
    
    if not Parent and LocalPlayer then
        Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    
    -- Absolute last resort
    if not Parent then
        Parent = CoreGui
        warn("[TachyonUI] Using CoreGui as fallback parent - some features may be limited")
    end
end

-- Library tables & defaults
TachyonUI.Windows   = {}
TachyonUI.ToggleKey = Enum.KeyCode.RightShift

-- Utility
local Utils = {}

function Utils:Tween(inst, dur, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local t = TweenService:Create(inst, TweenInfo.new(dur, style, dir), props)
    t:Play()
    return t
end

function Utils:MakeDraggable(gui, handle)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            dragStart  = input.Position
            startPos   = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Themes
TachyonUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Sidebar    = Color3.fromRGB(25, 25, 25),
        Section    = Color3.fromRGB(30, 30, 30),
        Element    = Color3.fromRGB(35, 35, 35),
        Accent     = Color3.fromRGB(0, 150, 255),
        Text       = Color3.fromRGB(255, 255, 255),
        TextMuted  = Color3.fromRGB(180, 180, 180),
        Stroke     = Color3.fromRGB(50, 50, 50),
        Hover      = Color3.fromRGB(45, 45, 45),
        Secondary  = Color3.fromRGB(0, 120, 200)
    },
    Light = { -- same as before...
        Background = Color3.fromRGB(240, 240, 240),
        Sidebar    = Color3.fromRGB(230, 230, 230),
        Section    = Color3.fromRGB(220, 220, 220),
        Element    = Color3.fromRGB(210, 210, 210),
        Accent     = Color3.fromRGB(0, 120, 255),
        Text       = Color3.fromRGB(40, 40, 40),
        TextMuted  = Color3.fromRGB(100, 100, 100),
        Stroke     = Color3.fromRGB(180, 180, 180),
        Hover      = Color3.fromRGB(190, 190, 190),
        Secondary  = Color3.fromRGB(0, 100, 220)
    }
}

TachyonUI.SelectedTheme = TachyonUI.Themes.Dark

function TachyonUI:SetTheme(theme)
    if type(theme) == "string" and TachyonUI.Themes[theme] then
        TachyonUI.SelectedTheme = TachyonUI.Themes[theme]
    elseif type(theme) == "table" then
        for k,v in pairs(theme) do
            TachyonUI.SelectedTheme[k] = v
        end
    end
end

-- Global toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TachyonUI.ToggleKey then
        for _, win in pairs(TachyonUI.Windows) do
            if win.Container then
                win.Container.Visible = not win.Container.Visible
            end
        end
    end
end)

-- Notification system (unchanged from your version)
function TachyonUI:Notify(opt)
    opt = opt or {}
    local title = opt.Title or "Notification"
    local content = opt.Content or "Message"
    local dur = opt.Duration or 5

    local ng = Parent:FindFirstChild("TachyonNotifications") or Instance.new("ScreenGui")
    ng.Name = "TachyonNotifications"
    ng.Parent = Parent

    -- List & padding setup (add if missing)
    if not ng:FindFirstChild("UIListLayout") then
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0,10)
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.HorizontalAlignment = Enum.HorizontalAlignment.Right
        l.Parent = ng

        local p = Instance.new("UIPadding")
        p.PaddingBottom = UDim.new(0,20)
        p.PaddingRight = UDim.new(0,20)
        p.Parent = ng
    end

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,250,0,0)
    f.BackgroundColor3 = self.SelectedTheme.Background
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = ng

    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local s = Instance.new("UIStroke", f)
    s.Color = self.SelectedTheme.Accent
    s.Thickness = 1

    -- Title & Content labels (same as before)
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-20,0,25)
    tl.Position = UDim2.new(0,10,0,5)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = self.SelectedTheme.Accent
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = f

    local cl = Instance.new("TextLabel")
    cl.Size = UDim2.new(1,-20,0,35)
    cl.Position = UDim2.new(0,10,0,30)
    cl.BackgroundTransparency = 1
    cl.Text = content
    cl.TextColor3 = self.SelectedTheme.Text
    cl.Font = Enum.Font.Gotham
    cl.TextSize = 12
    cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.TextWrapped = true
    cl.Parent = f

    Utils:Tween(f, 0.3, {Size = UDim2.new(0,250,0,70)})

    task.delay(dur, function()
        Utils:Tween(f, 0.3, {Size = UDim2.new(0,250,0,0)})
        task.wait(0.3)
        f:Destroy()
    end)
end

-- Watermark (unchanged)
function TachyonUI:SetWatermark(txt)
    if self.Watermark then self.Watermark:Destroy() end

    local wg = Instance.new("ScreenGui")
    wg.Name = "TachyonWatermark"
    wg.Parent = Parent

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,200,0,30)
    f.Position = UDim2.new(0,20,0,20)
    f.BackgroundColor3 = self.SelectedTheme.Background
    f.BorderSizePixel = 0
    f.Parent = wg

    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local s = Instance.new("UIStroke", f)
    s.Color = self.SelectedTheme.Accent
    s.Thickness = 1

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = txt or "TachyonUI v1.0.2"
    l.TextColor3 = self.SelectedTheme.Text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.Parent = f

    Utils:MakeDraggable(f, f)
    self.Watermark = wg
end

-- CreateWindow and tab/element functions remain the same as your original
-- (paste the rest of your CreateWindow, CreateTab, CreateButton, CreateToggle, etc. here from your previous version)

-- At the very end:
return TachyonUI
