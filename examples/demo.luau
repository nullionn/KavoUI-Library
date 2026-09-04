local Kavo = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nullionn/KavoUI-Library/main/source.luau"
))()

Kavo:SetConfigName("KavoDemo")

local Window = Kavo.CreateLib("Kavo Modern Demo", "Midnight")

local Main = Window:NewTab("Main")
local General = Main:NewSection("General")

General:NewLabel("Values below are automatically persisted.")

local Enabled = General:NewToggle("Enabled", "Example saved toggle", function(value)
    print("Enabled:", value)
end)

local Power = General:NewSlider("Power", "Example saved slider", 100, 0, function(value)
    print("Power:", value)
end)

local Mode = General:NewDropdown("Mode", "Example saved dropdown", {
    "Balanced",
    "Fast",
    "Maximum",
}, function(value)
    print("Mode:", value)
end)

local Name = General:NewTextBox("Profile Name", "Saved when focus is lost", function(value)
    print("Profile:", value)
end)

General:NewKeybind("Toggle UI", "Click then press a key", Enum.KeyCode.RightShift, function()
    Kavo:ToggleUI()
end)

General:NewColorPicker(
    "Accent Preview",
    "Example saved color",
    Color3.fromRGB(86, 76, 251),
    function(color)
        Kavo:ChangeColor("SchemeColor", color)
    end
)

local Utilities = Window:NewTab("Utilities")
local Actions = Utilities:NewSection("Actions")

Actions:NewButton("Print current config", "Shows current values", function()
    print(Kavo:GetConfig())
end)

Actions:NewButton("Clear config", "Deletes saved values in the active config", function()
    Kavo:ClearConfig()
end)
