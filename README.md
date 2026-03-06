# 🌌 TachyonUI

TachyonUI is a modern, high-performance Roblox Luau UI library designed for premium exploits and legitimate game tools. It features a sleek glassmorphism aesthetic, smooth animations, and a powerful configuration system.

## 🚀 Loading the Library

Add this to your script to load the latest version of TachyonUI:

```lua
local TachyonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/TachyonUI.lua"))()
```

## 🛠️ Basic Usage

```lua
local Window = TachyonUI:CreateWindow({
    Title = "Tachyon UI",
    Theme = "Dark" -- "Dark" or "Light"
})

local Tab = Window:CreateTab("Main")

Tab:CreateButton({
    Text = "Click Me",
    Callback = function()
        TachyonUI:Notify({Title = "Pressed", Content = "Button clicked!"})
    end
})

Tab:CreateToggle({
    Text = "Enable Hacks",
    Default = false,
    Callback = function(state)
        print("Toggled:", state)
    end
})
```

## ✨ Features

- **Theming**: Dark and Light modes out of the box.
- **Search**: Fuzzy search in the sidebar for elements and tabs.
- **Config**: Save and load settings automatically.
- **Animations**: Silky smooth quart-easing transitions.
- **Modern UI**: UIStroke, UICorner, and Gradient support.
- **Anti-Exploit**: GUID-based naming and obfuscated internal calls.

## 📜 Documentation

Full documentation and element list can be found in the [Walkthrough](file:///C:/Users/Administrator/.gemini/antigravity/brain/4b2581f3-2944-427f-a6d3-9ec3a7dd1480/walkthrough.md).
