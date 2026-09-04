# API Reference

## Library

### `Kavo.CreateLib(title, theme)`
Creates a new window.

- `title`: window title
- `theme`: built-in theme name or custom theme table
- returns: tabs object

### `Kavo:SetConfigName(name)`
Sets the JSON config file name and loads it. Call this before creating controls.

### `Kavo:SaveConfig()`
Immediately writes the current config table when file APIs are available.

### `Kavo:GetConfig()`
Returns a shallow copy of the currently loaded config table.

### `Kavo:ClearConfig()`
Clears the active config and saves the empty table.

### `Kavo:ToggleUI()`
Shows/hides the active UI.

### `Kavo:ChangeColor(property, color)`
Updates one of these live theme properties:

- `SchemeColor`
- `Background`
- `Header`
- `TextColor`
- `ElementColor`

---

## Tabs and sections

```lua
local Window = Kavo.CreateLib("Demo", "Midnight")
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat")
```

Use `NewSection(name, true)` to hide the section header.

The sidebar includes a search field. Typing filters tab names.

---

## Button

```lua
local button = Combat:NewButton("Run", "Runs the action", function()
    print("clicked")
end)

button:UpdateButton("Run again")
```

Buttons are not persisted because they have no state.

---

## Text box

```lua
local box = Combat:NewTextBox("Nickname", "Saved automatically", function(text)
    print(text)
end)

box:SetValue("Player")
print(box:GetValue())
```

The callback fires when Enter submits the textbox. Its value is saved when focus is lost.

---

## Toggle

```lua
local toggle = Combat:NewToggle("Enabled", "Feature state", function(enabled)
    print(enabled)
end)

toggle:SetValue(true)
toggle:SetValue(false, true) -- also fires callback
print(toggle:GetValue())
```

Legacy helper:

```lua
toggle:UpdateToggle("New label", true)
```

---

## Slider

Signature:

```lua
section:NewSlider(name, info, max, min, callback)
```

Example:

```lua
local slider = Combat:NewSlider("WalkSpeed", "Choose a value", 100, 16, function(value)
    print(value)
end)

slider:SetValue(32, true)
print(slider:GetValue())
```

Slider values are clamped to the supplied min/max and stored automatically.

---

## Dropdown

```lua
local dropdown = Combat:NewDropdown(
    "Mode",
    "Pick one",
    {"A", "B", "C"},
    function(value)
        print(value)
    end
)

dropdown:SetValue("B", true)
print(dropdown:GetValue())

dropdown:Refresh({"X", "Y", "Z"})
```

`SetValue` returns `false` when the requested option is not in the current list.

---

## Keybind

```lua
Combat:NewKeybind("Toggle menu", "Press a key", Enum.KeyCode.RightShift, function()
    Kavo:ToggleUI()
end)
```

Click the keybind control, then press a new key/button. The selected binding is persisted.

---

## Color picker

```lua
Combat:NewColorPicker(
    "Accent",
    "Choose a color",
    Color3.fromRGB(120, 90, 255),
    function(color)
        print(color)
    end
)
```

The selected static color is persisted as a hex value.

Rainbow mode is runtime-only and intentionally is not written every frame.

---

## Label

```lua
local label = Combat:NewLabel("Ready")
label:UpdateLabel("Running")
```

Labels are display-only and are not persisted.

---

## Config persistence behavior

Stateful controls use namespaced keys:

```text
<Tab>/<Section>/<ControlType>/<ControlName>
```

Example:

```text
Main/Combat/toggle/Enabled
Main/Combat/slider/WalkSpeed
```

This prevents most accidental collisions between controls with the same label.

Writes are debounced briefly, so dragging a slider does not write the config file for every tiny pointer update.

When `readfile` / `writefile` are unavailable, all config calls fail gracefully and the UI remains usable.
