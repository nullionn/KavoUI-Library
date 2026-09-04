# KavoUI Library — Modernized

A refreshed, backward-friendly Kavo-style Roblox UI library with a cleaner interface, responsive scaling, touch support, live themes, tab search, and automatic JSON configuration persistence.

## Highlights

- Modern compact window and controls
- Searchable tab sidebar
- Mouse + touch dragging and sliders
- Built-in themes + custom theme tables
- Runtime theme color changes
- Automatic config saving for supported controls
- Restores saved toggle, slider, dropdown, textbox, keybind, and color values
- Debounced config writes to avoid hammering the filesystem
- Getter/setter helpers for common controls
- Lifecycle cleanup for events and tweens

> Config persistence uses `readfile` / `writefile` when those APIs are available. In environments without file APIs, the UI still works; persistence simply becomes a no-op.

## Quick start

```lua
local Kavo = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nullionn/KavoUI-Library/main/source.luau"
))()

-- Optional: choose this BEFORE creating controls.
Kavo:SetConfigName("MyGameConfig")

local Window = Kavo.CreateLib("My Script", "Midnight")
local Main = Window:NewTab("Main")
local General = Main:NewSection("General")

General:NewButton("Say hello", "Runs a callback", function()
    print("Hello!")
end)

local Enabled = General:NewToggle("Enabled", "Turns the feature on/off", function(value)
    print("Enabled:", value)
end)

local Speed = General:NewSlider("Speed", "Choose a speed", 100, 10, function(value)
    print("Speed:", value)
end)

local Mode = General:NewDropdown("Mode", "Choose a mode", {
    "Legit",
    "Fast",
    "Chaos",
}, function(value)
    print("Mode:", value)
end)
```

## Configs

Configs save automatically after a control changes. The default file is:

```
KavoConfig.JSON
```

Use a different file per script/game:

```lua
Kavo:SetConfigName("MyGame")
```

The library automatically adds `.json` if you omit it.

Manual helpers:

```lua
Kavo:SaveConfig()       -- force an immediate write
local data = Kavo:GetConfig()
Kavo:ClearConfig()      -- clear saved values
```

Config keys are namespaced by tab, section, control type, and control name, so similarly named controls in different sections do not overwrite each other.

## Themes

Built-in themes:

```text
DarkTheme
LightTheme
BloodTheme
GrapeTheme
Ocean
Midnight
Sentinel
Synapse
Serpent
```

Example:

```lua
local Window = Kavo.CreateLib("Example", "Ocean")
```

Custom theme:

```lua
local Window = Kavo.CreateLib("Example", {
    SchemeColor = Color3.fromRGB(120, 90, 255),
    Background = Color3.fromRGB(20, 21, 26),
    Header = Color3.fromRGB(16, 17, 21),
    TextColor = Color3.fromRGB(245, 245, 248),
    ElementColor = Color3.fromRGB(28, 29, 35),
})
```

Change one theme value while the UI is open:

```lua
Kavo:ChangeColor("SchemeColor", Color3.fromRGB(255, 90, 140))
```

## Controls

```lua
section:NewButton(name, info, callback)
section:NewTextBox(name, info, callback)
section:NewToggle(name, info, callback)
section:NewSlider(name, info, max, min, callback)
section:NewDropdown(name, info, list, callback)
section:NewKeybind(name, info, defaultBinding, callback)
section:NewColorPicker(name, info, defaultColor, callback)
section:NewLabel(text)
```

Some controls return helper objects:

```lua
local toggle = section:NewToggle("God Mode", "Example", function(v) end)
toggle:SetValue(true)
print(toggle:GetValue())

local slider = section:NewSlider("Power", "Example", 100, 0, function(v) end)
slider:SetValue(75, true) -- true = also fire callback
print(slider:GetValue())

local box = section:NewTextBox("Name", "Example", function(v) end)
box:SetValue("Leo")
print(box:GetValue())

local dropdown = section:NewDropdown("Team", "Example", {"Red", "Blue"}, function(v) end)
dropdown:SetValue("Blue", true)
print(dropdown:GetValue())
```

For the complete API with examples, see [docs/API.md](docs/API.md).

## Other helpers

```lua
Kavo:ToggleUI()
Kavo:DraggingEnabled(frame, parent)
```

## Backward compatibility

The classic Kavo-style flow remains the same:

```lua
local Window = Kavo.CreateLib("Title", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Stuff")
```

The new config and setter/getter APIs are additive, so existing scripts do not need to use them.

## License

Add the license you want this project distributed under.
