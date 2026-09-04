local Kavo = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local DEFAULT_THEME = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(32, 32, 38),
}

local themes = {
    SchemeColor = DEFAULT_THEME.SchemeColor,
    Background = DEFAULT_THEME.Background,
    Header = DEFAULT_THEME.Header,
    TextColor = DEFAULT_THEME.TextColor,
    ElementColor = DEFAULT_THEME.ElementColor,
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20),
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255, 255, 255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0, 0, 0),
        ElementColor = Color3.fromRGB(224, 224, 224),
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20),
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(64, 50, 71),
        Header = Color3.fromRGB(36, 28, 41),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(74, 58, 84),
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(26, 32, 58),
        Header = Color3.fromRGB(38, 45, 71),
        TextColor = Color3.fromRGB(200, 200, 200),
        ElementColor = Color3.fromRGB(38, 45, 71),
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95),
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(32, 32, 32),
        Header = Color3.fromRGB(24, 24, 24),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(24, 24, 24),
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(13, 15, 12),
        Header = Color3.fromRGB(36, 38, 35),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(24, 24, 24),
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(31, 41, 43),
        Header = Color3.fromRGB(22, 29, 31),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(22, 29, 31),
    },
}

local SettingsT = {}
local ConfigName = "KavoConfig.JSON"
local saveGeneration = 0

local function supportsFileConfigs()
    return typeof(readfile) == "function" and typeof(writefile) == "function"
end

local function normalizeConfigName(name)
    name = tostring(name or "KavoConfig")
    name = name:gsub("[^%w%-%._ ]", "_")
    if not name:lower():match("%.json$") then
        name = name .. ".json"
    end
    return name
end

local function loadSettings()
    SettingsT = {}
    if not supportsFileConfigs() then
        return false
    end

    local ok, contents = pcall(readfile, ConfigName)
    if not ok or type(contents) ~= "string" or contents == "" then
        pcall(writefile, ConfigName, HttpService:JSONEncode(SettingsT))
        return true
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if decodedOk and typeof(decoded) == "table" then
        SettingsT = decoded
        return true
    end

    pcall(writefile, ConfigName, HttpService:JSONEncode(SettingsT))
    return false
end

local function saveSettings()
    if not supportsFileConfigs() then
        return false
    end
    local ok = pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(SettingsT))
    end)
    return ok
end

local function queueSave()
    saveGeneration = saveGeneration + 1
    local generation = saveGeneration
    task.delay(0.18, function()
        if generation == saveGeneration then
            saveSettings()
        end
    end)
end

local function readSetting(key, fallback)
    local value = SettingsT[key]
    if value == nil then
        return fallback
    end
    return value
end

local function writeSetting(key, value)
    SettingsT[key] = value
    queueSave()
end

local function settingKey(tabName, sectionName, kind, name)
    return table.concat({
        tostring(tabName or "Tab"),
        tostring(sectionName or "Section"),
        tostring(kind or "Value"),
        tostring(name or "Unnamed"),
    }, "/")
end

local function colorToHex(color)
    return string.format(
        "%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function colorFromHex(value, fallback)
    if type(value) ~= "string" then
        return fallback
    end
    value = value:gsub("#", "")
    if #value ~= 6 then
        return fallback
    end
    local r = tonumber(value:sub(1, 2), 16)
    local g = tonumber(value:sub(3, 4), 16)
    local b = tonumber(value:sub(5, 6), 16)
    if not r or not g or not b then
        return fallback
    end
    return Color3.fromRGB(r, g, b)
end

local function encodeBinding(binding)
    if typeof(binding) ~= "EnumItem" then
        return nil
    end
    return binding.EnumType.Name .. ":" .. binding.Name
end

local function decodeBinding(value, fallback)
    if type(value) ~= "string" then
        return fallback
    end
    local enumTypeName, itemName = value:match("^([^:]+):(.+)$")
    if not enumTypeName or not itemName then
        return fallback
    end
    local ok, result = pcall(function()
        return Enum[enumTypeName][itemName]
    end)
    return ok and result or fallback
end

loadSettings()

function Kavo:SetConfigName(name)
    ConfigName = normalizeConfigName(name)
    loadSettings()
    return self
end

function Kavo:SaveConfig()
    saveSettings()
    return self
end

function Kavo:GetConfig()
    local copy = {}
    for key, value in pairs(SettingsT) do
        copy[key] = value
    end
    return copy
end

function Kavo:ClearConfig()
    SettingsT = {}
    saveSettings()
    return self
end

local LibName = tostring(math.random(1, 100)) .. tostring(math.random(1, 50)) .. tostring(math.random(1, 100))
local activeGui = nil

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    if parent then
        object.Parent = parent
    end
    return object
end

local function addCorner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
    }, parent)
end

local function copyTheme(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function mixColor(first, second, alpha)
    alpha = math.clamp(alpha, 0, 1)
    return Color3.new(
        first.R + (second.R - first.R) * alpha,
        first.G + (second.G - first.G) * alpha,
        first.B + (second.B - first.B) * alpha
    )
end

local function colorLuminance(color)
    return color.R * 0.299 + color.G * 0.587 + color.B * 0.114
end

local function pointerPosition(inputObject)
    return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
end

local function isPointerPress(inputObject)
    return inputObject.UserInputType == Enum.UserInputType.MouseButton1
        or inputObject.UserInputType == Enum.UserInputType.Touch
end

local function newLifecycle()
    local lifecycle = {
        Connections = {},
        Tweens = {},
        Destroyed = false,
    }

    function lifecycle:Connect(signal, callback)
        if self.Destroyed then
            return nil
        end
        local connection = signal:Connect(callback)
        table.insert(self.Connections, connection)
        return connection
    end

    function lifecycle:Track(connection)
        if connection then
            table.insert(self.Connections, connection)
        end
        return connection
    end

    function lifecycle:Untrack(connection)
        for index = #self.Connections, 1, -1 do
            if self.Connections[index] == connection then
                table.remove(self.Connections, index)
                break
            end
        end
    end

    function lifecycle:Tween(object, properties, duration, style, direction)
        if self.Destroyed or not object then
            return nil
        end
        local previous = self.Tweens[object]
        if previous then
            pcall(function()
                previous:Cancel()
            end)
        end
        local animation = TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.16,
                style or Enum.EasingStyle.Quad,
                direction or Enum.EasingDirection.Out
            ),
            properties
        )
        self.Tweens[object] = animation
        animation:Play()
        return animation
    end

    function lifecycle:ForgetTween(object)
        local animation = self.Tweens[object]
        if animation then
            pcall(function()
                animation:Cancel()
            end)
            self.Tweens[object] = nil
        end
    end

    function lifecycle:Destroy()
        if self.Destroyed then
            return
        end
        self.Destroyed = true
        for _, animation in pairs(self.Tweens) do
            pcall(function()
                animation:Cancel()
            end)
        end
        table.clear(self.Tweens)
        for _, connection in ipairs(self.Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(self.Connections)
    end

    return lifecycle
end

local function enableDragging(frame, parent, lifecycle)
    parent = parent or frame
    local ownsLifecycle = lifecycle == nil
    lifecycle = lifecycle or newLifecycle()

    local dragging = false
    local dragType = nil
    local dragInput = nil
    local dragOrigin = Vector2.new(0, 0)
    local frameOrigin = parent.Position

    frame.Active = true

    lifecycle:Connect(frame.InputBegan, function(inputObject)
        if not isPointerPress(inputObject) then
            return
        end
        dragging = true
        dragType = inputObject.UserInputType
        dragInput = inputObject
        dragOrigin = pointerPosition(inputObject)
        frameOrigin = parent.Position
    end)

    lifecycle:Connect(UserInputService.InputChanged, function(inputObject)
        if not dragging then
            return
        end

        local validMouseMove = dragType == Enum.UserInputType.MouseButton1
            and inputObject.UserInputType == Enum.UserInputType.MouseMovement
        local validTouchMove = dragType == Enum.UserInputType.Touch
            and inputObject == dragInput

        if not validMouseMove and not validTouchMove then
            return
        end

        local delta = pointerPosition(inputObject) - dragOrigin
        parent.Position = UDim2.new(
            frameOrigin.X.Scale,
            frameOrigin.X.Offset + delta.X,
            frameOrigin.Y.Scale,
            frameOrigin.Y.Offset + delta.Y
        )
    end)

    lifecycle:Connect(UserInputService.InputEnded, function(inputObject)
        if dragType == Enum.UserInputType.MouseButton1
            and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragType = nil
            dragInput = nil
        elseif dragType == Enum.UserInputType.Touch
            and inputObject == dragInput then
            dragging = false
            dragType = nil
            dragInput = nil
        end
    end)

    if ownsLifecycle then
        lifecycle:Connect(frame.AncestryChanged, function(_, nextParent)
            if nextParent == nil then
                lifecycle:Destroy()
            end
        end)
    end

    return lifecycle
end

function Kavo:DraggingEnabled(frame, parent)
    enableDragging(frame, parent)
end

function Kavo:ToggleUI()
    if activeGui and activeGui.Parent then
        activeGui.Enabled = not activeGui.Enabled
        return
    end

    local existing = CoreGui:FindFirstChild(LibName)
    if existing and existing:IsA("ScreenGui") then
        existing.Enabled = not existing.Enabled
    end
end

function Kavo.CreateLib(kavName, themeList)
    kavName = kavName or "Library"

    if typeof(themeList) == "string" and themeStyles[themeList] then
        themeList = copyTheme(themeStyles[themeList])
    elseif typeof(themeList) ~= "table" then
        themeList = copyTheme(themes)
    end

    for key, fallback in pairs(DEFAULT_THEME) do
        if themeList[key] == nil then
            themeList[key] = fallback
        end
    end

    table.insert(Kavo, kavName)

    local lifecycle = newLifecycle()
    local disposed = false
    local themeBindings = {}

    local function palette()
        local mutedAmount = colorLuminance(themeList.Background) > 0.7 and 0.46 or 0.42
        return {
            Accent = themeList.SchemeColor,
            Background = themeList.Background,
            Header = themeList.Header,
            Text = themeList.TextColor,
            Element = themeList.ElementColor,
            Sidebar = mixColor(themeList.Header, themeList.Background, 0.18),
            SurfaceRaised = mixColor(themeList.ElementColor, themeList.TextColor, 0.045),
            Hover = mixColor(themeList.ElementColor, themeList.TextColor, 0.09),
            Pressed = mixColor(themeList.ElementColor, themeList.SchemeColor, 0.2),
            AccentSoft = mixColor(themeList.ElementColor, themeList.SchemeColor, 0.2),
            Border = mixColor(themeList.Background, themeList.TextColor, 0.14),
            Muted = mixColor(themeList.TextColor, themeList.Background, mutedAmount),
            Track = mixColor(themeList.ElementColor, themeList.TextColor, 0.12),
            OnAccent = colorLuminance(themeList.SchemeColor) > 0.62
                    and Color3.fromRGB(20, 22, 25)
                or Color3.fromRGB(248, 249, 252),
        }
    end

    local function bindTheme(callback)
        local binding = { Callback = callback }
        table.insert(themeBindings, binding)
        callback(palette())
        return function()
            binding.Callback = nil
            for index = #themeBindings, 1, -1 do
                if themeBindings[index] == binding then
                    table.remove(themeBindings, index)
                    break
                end
            end
        end
    end

    local function applyTheme()
        local colors = palette()
        for _, binding in ipairs(themeBindings) do
            if binding.Callback then
                pcall(binding.Callback, colors)
            end
        end
    end

    function Kavo:ChangeColor(property, color)
        if property == "Background"
            or property == "SchemeColor"
            or property == "Header"
            or property == "TextColor"
            or property == "ElementColor" then
            themeList[property] = color
            applyTheme()
        end
    end

    local ScreenGui = create("ScreenGui", {
        Name = LibName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 50,
    })

    local parented = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not parented then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    activeGui = ScreenGui

    local WINDOW_WIDTH = 600
    local WINDOW_HEIGHT = 380
    local HEADER_HEIGHT = 44
    local SIDEBAR_WIDTH = 154
    local ROW_HEIGHT = 38

    local Root = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, ScreenGui)

    local Scale = create("UIScale", {
        Scale = 1,
    }, Root)

    local Shadow = create("Frame", {
        Name = "Shadow",
        Position = UDim2.fromOffset(0, 5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, Root)
    addCorner(Shadow, 12)

    local Main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = themeList.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    }, Root)
    addCorner(Main, 10)
    local MainStroke = create("UIStroke", {
        Thickness = 1,
        Transparency = 0.18,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, Main)

    local Header = create("Frame", {
        Name = "MainHeader",
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        BackgroundColor3 = themeList.Header,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, Main)

    local HeaderCover = create("Frame", {
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, Header)

    local HeaderDivider = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        ZIndex = 6,
    }, Header)

    local AccentMark = create("Frame", {
        Position = UDim2.fromOffset(12, 13),
        Size = UDim2.fromOffset(3, 16),
        BorderSizePixel = 0,
        ZIndex = 7,
    }, Header)
    addCorner(AccentMark, 2)

    local Title = create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(23, 0),
        Size = UDim2.new(1, -112, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = kavName,
        RichText = true,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 7,
    }, Header)

    local DragArea = create("Frame", {
        Name = "DragArea",
        Size = UDim2.new(1, -86, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 8,
    }, Header)

    local Minimize = create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -39, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Font = Enum.Font.GothamSemibold,
        Text = "—",
        TextSize = 15,
        ZIndex = 8,
    }, Header)
    addCorner(Minimize, 6)

    local Close = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -7, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = "×",
        TextSize = 18,
        ZIndex = 8,
    }, Header)
    addCorner(Close, 6)

    local Body = create("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, HEADER_HEIGHT),
        Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, Main)

    local Sidebar = create("Frame", {
        Name = "MainSide",
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, Body)

    local SidebarDivider = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, Sidebar)

    local SearchShell = create("Frame", {
        Name = "SearchShell",
        Position = UDim2.fromOffset(7, 8),
        Size = UDim2.new(1, -14, 0, 30),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, Sidebar)
    addCorner(SearchShell, 6)
    local SearchStroke = create("UIStroke", {
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, SearchShell)
    local SearchBox = create("TextBox", {
        Name = "TabSearch",
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search tabs...",
        Text = "",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, SearchShell)

    local TabFrames = create("ScrollingFrame", {
        Name = "tabFrames",
        Position = UDim2.fromOffset(7, 44),
        Size = UDim2.new(1, -14, 1, -52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ZIndex = 3,
    }, Sidebar)

    local TabLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, TabFrames)

    local Pages = create("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(SIDEBAR_WIDTH, 0),
        Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, Body)

    local Tooltip = create("Frame", {
        Name = "Tooltip",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, SIDEBAR_WIDTH / 2, 1, -8),
        Size = UDim2.new(1, -SIDEBAR_WIDTH - 20, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 60,
    }, Body)
    addCorner(Tooltip, 6)
    local TooltipStroke = create("UIStroke", {
        Thickness = 1,
        Transparency = 1,
    }, Tooltip)
    local TooltipText = create("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "",
        TextSize = 12,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 61,
    }, Tooltip)

    bindTheme(function(colors)
        Main.BackgroundColor3 = colors.Background
        MainStroke.Color = colors.Border
        Header.BackgroundColor3 = colors.Header
        HeaderCover.BackgroundColor3 = colors.Header
        HeaderDivider.BackgroundColor3 = colors.Border
        AccentMark.BackgroundColor3 = colors.Accent
        Title.TextColor3 = colors.Text
        Sidebar.BackgroundColor3 = colors.Sidebar
        SidebarDivider.BackgroundColor3 = colors.Border
        SearchShell.BackgroundColor3 = colors.Element
        SearchStroke.Color = colors.Border
        SearchBox.TextColor3 = colors.Text
        SearchBox.PlaceholderColor3 = colors.Muted
        TabFrames.ScrollBarImageColor3 = colors.Accent
        Tooltip.BackgroundColor3 = colors.SurfaceRaised
        TooltipStroke.Color = colors.Border
        TooltipText.TextColor3 = colors.Text
    end)

    local function styleHeaderButton(button, danger)
        local hovering = false
        bindTheme(function(colors)
            button.TextColor3 = danger and mixColor(colors.Text, Color3.fromRGB(255, 105, 115), 0.3) or colors.Muted
            if hovering then
                button.BackgroundColor3 = danger
                        and mixColor(colors.Element, Color3.fromRGB(210, 55, 68), 0.35)
                    or colors.Hover
                button.BackgroundTransparency = 0
            else
                button.BackgroundTransparency = 1
            end
        end)
        lifecycle:Connect(button.MouseEnter, function()
            hovering = true
            local colors = palette()
            lifecycle:Tween(button, {
                BackgroundTransparency = 0,
                BackgroundColor3 = danger
                        and mixColor(colors.Element, Color3.fromRGB(210, 55, 68), 0.35)
                    or colors.Hover,
                TextColor3 = colors.Text,
            }, 0.14)
        end)
        lifecycle:Connect(button.MouseLeave, function()
            hovering = false
            local colors = palette()
            lifecycle:Tween(button, {
                BackgroundTransparency = 1,
                TextColor3 = danger and mixColor(colors.Text, Color3.fromRGB(255, 105, 115), 0.3) or colors.Muted,
            }, 0.14)
        end)
    end

    styleHeaderButton(Minimize, false)
    styleHeaderButton(Close, true)
    enableDragging(DragArea, Root, lifecycle)

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local viewport = camera.ViewportSize
        local widthScale = (viewport.X - 24) / WINDOW_WIDTH
        local heightScale = (viewport.Y - 24) / WINDOW_HEIGHT
        Scale.Scale = math.clamp(math.min(widthScale, heightScale, 1), 0.68, 1)
    end

    updateScale()
    if workspace.CurrentCamera then
        lifecycle:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateScale)
    end

    local tooltipToken = 0
    local function showTip(text)
        tooltipToken = tooltipToken + 1
        local token = tooltipToken
        TooltipText.Text = tostring(text or "")
        Tooltip.Visible = true
        lifecycle:Tween(Tooltip, { BackgroundTransparency = 0.04 }, 0.14)
        lifecycle:Tween(TooltipStroke, { Transparency = 0.25 }, 0.14)
        lifecycle:Tween(TooltipText, { TextTransparency = 0 }, 0.14)
        task.delay(2.2, function()
            if disposed or token ~= tooltipToken or not Tooltip.Parent then
                return
            end
            lifecycle:Tween(Tooltip, { BackgroundTransparency = 1 }, 0.16)
            lifecycle:Tween(TooltipStroke, { Transparency = 1 }, 0.16)
            lifecycle:Tween(TooltipText, { TextTransparency = 1 }, 0.16)
            task.delay(0.18, function()
                if not disposed and token == tooltipToken and Tooltip.Parent then
                    Tooltip.Visible = false
                end
            end)
        end)
    end

    local minimized = false
    local windowAnimating = false
    lifecycle:Connect(Minimize.Activated, function()
        if windowAnimating then
            return
        end
        windowAnimating = true
        minimized = not minimized

        if minimized then
            Minimize.Text = "□"
            lifecycle:Tween(Root, { Size = UDim2.fromOffset(WINDOW_WIDTH, HEADER_HEIGHT) }, 0.18)
            task.delay(0.19, function()
                if not disposed and minimized then
                    Body.Visible = false
                end
                windowAnimating = false
            end)
        else
            Body.Visible = true
            Minimize.Text = "—"
            lifecycle:Tween(Root, { Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT) }, 0.18)
            task.delay(0.19, function()
                windowAnimating = false
            end)
        end
    end)

    local function dispose()
        if disposed then
            return
        end
        disposed = true
        tooltipToken = tooltipToken + 1
        lifecycle:Destroy()
        table.clear(themeBindings)
        if activeGui == ScreenGui then
            activeGui = nil
        end
        if ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end

    lifecycle:Connect(Close.Activated, function()
        if disposed then
            return
        end
        Close.Active = false
        Minimize.Active = false
        lifecycle:Tween(Root, {
            Size = UDim2.fromOffset(0, 0),
        }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.17, dispose)
    end)

    lifecycle:Connect(ScreenGui.Destroying, function()
        if not disposed then
            disposed = true
            lifecycle:Destroy()
            table.clear(themeBindings)
            if activeGui == ScreenGui then
                activeGui = nil
            end
        end
    end)

    lifecycle:Connect(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabFrames.CanvasSize = UDim2.fromOffset(0, TabLayout.AbsoluteContentSize.Y + 2)
    end)

    local pointerSession = nil

    local function startPointerSession(inputObject, updateCallback, finishCallback)
        if not isPointerPress(inputObject) then
            return
        end
        pointerSession = {
            Type = inputObject.UserInputType,
            TouchInput = inputObject.UserInputType == Enum.UserInputType.Touch and inputObject or nil,
            Update = updateCallback,
            Finish = finishCallback,
        }
        updateCallback(pointerPosition(inputObject))
    end

    lifecycle:Connect(UserInputService.InputChanged, function(inputObject)
        local session = pointerSession
        if not session then
            return
        end
        if session.Type == Enum.UserInputType.MouseButton1
            and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            session.Update(pointerPosition(inputObject))
        elseif session.Type == Enum.UserInputType.Touch
            and inputObject == session.TouchInput then
            session.Update(pointerPosition(inputObject))
        end
    end)

    lifecycle:Connect(UserInputService.InputEnded, function(inputObject)
        local session = pointerSession
        if not session then
            return
        end
        local mouseEnded = session.Type == Enum.UserInputType.MouseButton1
            and inputObject.UserInputType == Enum.UserInputType.MouseButton1
        local touchEnded = session.Type == Enum.UserInputType.Touch
            and inputObject == session.TouchInput
        if mouseEnded or touchEnded then
            pointerSession = nil
            if session.Finish then
                session.Finish()
            end
        end
    end)

    local function styleSurface(frame, stroke)
        local hovered = false
        local pressed = false
        local currentColors = palette()

        local function refresh(animate)
            local target = pressed and currentColors.Pressed or (hovered and currentColors.Hover or currentColors.Element)
            if animate then
                lifecycle:Tween(frame, { BackgroundColor3 = target }, 0.14)
            else
                frame.BackgroundColor3 = target
            end
            if stroke then
                stroke.Color = hovered and mixColor(currentColors.Border, currentColors.Accent, 0.32)
                    or currentColors.Border
            end
        end

        bindTheme(function(colors)
            currentColors = colors
            refresh(false)
        end)

        frame.Active = true
        lifecycle:Connect(frame.MouseEnter, function()
            hovered = true
            refresh(true)
        end)
        lifecycle:Connect(frame.MouseLeave, function()
            hovered = false
            pressed = false
            refresh(true)
        end)
        lifecycle:Connect(frame.InputBegan, function(inputObject)
            if isPointerPress(inputObject) then
                pressed = true
                refresh(true)
            end
        end)
        lifecycle:Connect(frame.InputEnded, function(inputObject)
            if isPointerPress(inputObject) then
                pressed = false
                refresh(true)
            end
        end)
    end

    local function makeRow(parent, height)
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, height or ROW_HEIGHT),
            BackgroundColor3 = themeList.ElementColor,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, parent)
        addCorner(row, 6)
        local stroke = create("UIStroke", {
            Thickness = 1,
            Transparency = 0.45,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, row)
        styleSurface(row, stroke)
        return row, stroke
    end

    local function makeLabel(parent, text, position, size, textSize, font)
        local label = create("TextLabel", {
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            Font = font or Enum.Font.GothamMedium,
            Text = text,
            RichText = true,
            TextSize = textSize or 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, parent)
        bindTheme(function(colors)
            label.TextColor3 = colors.Text
        end)
        return label
    end

    local function makeInfoButton(parent, tip, rightOffset)
        local info = create("TextButton", {
            Name = "Info",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, rightOffset or -6, 0, ROW_HEIGHT / 2),
            Size = UDim2.fromOffset(24, 24),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = "i",
            TextSize = 12,
            ZIndex = 12,
        }, parent)
        addCorner(info, 6)
        local hovering = false
        bindTheme(function(colors)
            info.TextColor3 = hovering and colors.Text or colors.Muted
            info.BackgroundColor3 = colors.Hover
            info.BackgroundTransparency = hovering and 0 or 1
        end)
        lifecycle:Connect(info.MouseEnter, function()
            hovering = true
            local colors = palette()
            lifecycle:Tween(info, {
                BackgroundTransparency = 0,
                BackgroundColor3 = colors.Hover,
                TextColor3 = colors.Text,
            }, 0.12)
        end)
        lifecycle:Connect(info.MouseLeave, function()
            hovering = false
            lifecycle:Tween(info, {
                BackgroundTransparency = 1,
                TextColor3 = palette().Muted,
            }, 0.12)
        end)
        lifecycle:Connect(info.Activated, function()
            showTip(tip)
        end)
        return info
    end

    local function transparentButton(parent, position, size)
        return create("TextButton", {
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 8,
        }, parent)
    end

    local keybinds = {}
    local captureRecord = nil

    local function bindingName(binding)
        if binding == Enum.UserInputType.Touch then
            return "TOUCH"
        elseif binding == Enum.UserInputType.MouseButton1 then
            return "M1"
        elseif binding == Enum.UserInputType.MouseButton2 then
            return "M2"
        elseif typeof(binding) == "EnumItem" then
            return string.upper(binding.Name)
        elseif binding ~= nil then
            return string.upper(tostring(binding))
        end
        return "NONE"
    end

    local function bindingFromInput(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.Keyboard
            or string.find(inputObject.UserInputType.Name, "Gamepad") then
            if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
                return inputObject.KeyCode
            end
        elseif inputObject.UserInputType == Enum.UserInputType.Touch then
            return Enum.UserInputType.Touch
        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1
            or inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            return inputObject.UserInputType
        end
        return nil
    end

    local function inputMatchesBinding(inputObject, binding)
        if typeof(binding) ~= "EnumItem" then
            return false
        end
        if binding.EnumType == Enum.KeyCode then
            return inputObject.KeyCode == binding
        end
        return inputObject.UserInputType == binding
    end

    lifecycle:Connect(UserInputService.InputBegan, function(inputObject, gameProcessed)
        if captureRecord then
            local binding = bindingFromInput(inputObject)
            if binding then
                local record = captureRecord
                captureRecord = nil
                record.Binding = binding
                record.Capturing = false
                record.Display.Text = bindingName(binding)
                record.Refresh()
                if record.ConfigKey then
                    writeSetting(record.ConfigKey, encodeBinding(binding))
                end
            end
            return
        end

        if gameProcessed then
            return
        end

        for _, record in ipairs(keybinds) do
            if inputMatchesBinding(inputObject, record.Binding) then
                record.Callback()
            end
        end
    end)

    local Tabs = {}
    local tabRecords = {}
    local selectedTab = nil

    local function selectTab(record)
        if selectedTab == record then
            return
        end
        selectedTab = record
        for _, other in ipairs(tabRecords) do
            other.Page.Visible = other == record
            other.Selected = other == record
            other.Refresh(true)
        end
    end

    lifecycle:Connect(SearchBox:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(SearchBox.Text)
        for _, record in ipairs(tabRecords) do
            record.Button.Visible = query == ""
                or string.find(string.lower(record.Name), query, 1, true) ~= nil
        end
    end)

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"

        local tabButton = create("TextButton", {
            Name = tabName .. "TabButton",
            Size = UDim2.new(1, 0, 0, 31),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            Text = "  " .. tabName,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 4,
        }, TabFrames)
        addCorner(tabButton, 5)

        local indicator = create("Frame", {
            Name = "Indicator",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(2, 17),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, tabButton)
        addCorner(indicator, 2)

        local page = create("ScrollingFrame", {
            Name = "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            Visible = false,
            ZIndex = 3,
        }, Pages)

        create("UIPadding", {
            PaddingTop = UDim.new(0, 9),
            PaddingBottom = UDim.new(0, 9),
            PaddingLeft = UDim.new(0, 9),
            PaddingRight = UDim.new(0, 9),
        }, page)

        local pageLayout = create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 9),
        }, page)

        lifecycle:Connect(pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            page.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 18)
        end)

        local record = {
            Name = tabName,
            Button = tabButton,
            Indicator = indicator,
            Page = page,
            Selected = false,
            Hovered = false,
        }

        function record.Refresh(animate)
            local colors = palette()
            local backgroundTransparency = record.Selected and 0 or (record.Hovered and 0.35 or 1)
            local backgroundColor = record.Selected and colors.AccentSoft or colors.Hover
            local textColor = record.Selected and colors.Text or (record.Hovered and colors.Text or colors.Muted)
            if animate then
                lifecycle:Tween(tabButton, {
                    BackgroundTransparency = backgroundTransparency,
                    BackgroundColor3 = backgroundColor,
                    TextColor3 = textColor,
                }, 0.16)
                lifecycle:Tween(indicator, {
                    BackgroundTransparency = record.Selected and 0 or 1,
                    BackgroundColor3 = colors.Accent,
                }, 0.16)
            else
                tabButton.BackgroundTransparency = backgroundTransparency
                tabButton.BackgroundColor3 = backgroundColor
                tabButton.TextColor3 = textColor
                indicator.BackgroundTransparency = record.Selected and 0 or 1
                indicator.BackgroundColor3 = colors.Accent
            end
            page.ScrollBarImageColor3 = colors.Accent
        end

        bindTheme(function()
            record.Refresh(false)
        end)
        lifecycle:Connect(tabButton.MouseEnter, function()
            record.Hovered = true
            record.Refresh(true)
        end)
        lifecycle:Connect(tabButton.MouseLeave, function()
            record.Hovered = false
            record.Refresh(true)
        end)
        lifecycle:Connect(tabButton.Activated, function()
            selectTab(record)
        end)

        table.insert(tabRecords, record)
        table.insert(Tabs, tabName)
        if #tabRecords == 1 then
            selectTab(record)
        end

        local Sections = {}

        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            hidden = hidden or false

            local sectionFrame = create("Frame", {
                Name = "sectionFrame",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, page)

            local sectionHeaderHeight = hidden and 0 or 22
            local sectionHeader = create("Frame", {
                Name = "sectionHead",
                Size = UDim2.new(1, 0, 0, sectionHeaderHeight),
                BackgroundTransparency = 1,
                Visible = not hidden,
            }, sectionFrame)

            local sectionAccent = create("Frame", {
                Position = UDim2.fromOffset(1, 5),
                Size = UDim2.fromOffset(2, 12),
                BorderSizePixel = 0,
            }, sectionHeader)
            addCorner(sectionAccent, 2)

            local sectionName = create("TextLabel", {
                Name = "sectionName",
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -10, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Text = secName,
                RichText = true,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, sectionHeader)

            bindTheme(function(colors)
                sectionAccent.BackgroundColor3 = colors.Accent
                sectionName.TextColor3 = colors.Muted
            end)

            local sectionInners = create("Frame", {
                Name = "sectionInners",
                Position = UDim2.fromOffset(0, sectionHeaderHeight),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, sectionFrame)

            local sectionLayout = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            }, sectionInners)

            local function updateSectionFrame()
                local innerHeight = sectionLayout.AbsoluteContentSize.Y
                sectionInners.Size = UDim2.new(1, 0, 0, innerHeight)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionHeaderHeight + innerHeight)
            end

            lifecycle:Connect(sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"), updateSectionFrame)
            updateSectionFrame()

            local Elements = {}

            function Elements:NewButton(bname, tipINf, callback)
                local ButtonFunction = {}
                bname = bname or "Click Me!"
                tipINf = tipINf or "Tip: Clicking this nothing will happen!"
                callback = callback or function() end
                local configId = settingKey(tabName, secName, "keybind", keytext)
                first = decodeBinding(readSetting(configId, nil), first)

                local row = makeRow(sectionInners, ROW_HEIGHT)
                local accent = create("Frame", {
                    Position = UDim2.fromOffset(0, 10),
                    Size = UDim2.fromOffset(2, 16),
                    BorderSizePixel = 0,
                }, row)
                addCorner(accent, 2)
                bindTheme(function(colors)
                    accent.BackgroundColor3 = colors.Accent
                end)

                local label = makeLabel(
                    row,
                    bname,
                    UDim2.fromOffset(11, 0),
                    UDim2.new(1, -51, 1, 0),
                    13,
                    Enum.Font.GothamMedium
                )
                local action = transparentButton(row, UDim2.fromOffset(0, 0), UDim2.new(1, -32, 1, 0))
                makeInfoButton(row, tipINf)

                lifecycle:Connect(action.Activated, function()
                    callback()
                    lifecycle:Tween(accent, { Size = UDim2.fromOffset(2, 22) }, 0.08)
                    task.delay(0.09, function()
                        if not disposed and accent.Parent then
                            lifecycle:Tween(accent, { Size = UDim2.fromOffset(2, 16) }, 0.12)
                        end
                    end)
                end)

                function ButtonFunction:UpdateButton(newTitle)
                    label.Text = newTitle
                end

                return ButtonFunction
            end

            function Elements:NewTextBox(tname, tTip, callback)
                local TextBoxFunctions = {}
                tname = tname or "Textbox"
                tTip = tTip or "Gets a value of Textbox"
                callback = callback or function() end
                local configId = settingKey(tabName, secName, "textbox", tname)
                local savedText = tostring(readSetting(configId, ""))

                local row = makeRow(sectionInners, ROW_HEIGHT)
                makeLabel(
                    row,
                    tname,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(0.43, -10, 1, 0),
                    13,
                    Enum.Font.GothamMedium
                )

                local textBox = create("TextBox", {
                    Name = "TextBox",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0.5, 0),
                    Size = UDim2.new(0.52, -4, 0, 24),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "Type here",
                    Text = savedText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)
                addCorner(textBox, 5)
                create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                }, textBox)
                local inputStroke = create("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.32,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                }, textBox)
                local focused = false

                local function refreshInput(animate)
                    local colors = palette()
                    local properties = {
                        BackgroundColor3 = focused and colors.SurfaceRaised or colors.Track,
                    }
                    if animate then
                        lifecycle:Tween(textBox, properties, 0.15)
                        lifecycle:Tween(inputStroke, {
                            Color = focused and colors.Accent or colors.Border,
                            Transparency = focused and 0.05 or 0.32,
                        }, 0.15)
                    else
                        textBox.BackgroundColor3 = properties.BackgroundColor3
                        inputStroke.Color = focused and colors.Accent or colors.Border
                        inputStroke.Transparency = focused and 0.05 or 0.32
                    end
                    textBox.TextColor3 = colors.Text
                    textBox.PlaceholderColor3 = colors.Muted
                end

                bindTheme(function()
                    refreshInput(false)
                end)
                lifecycle:Connect(textBox.Focused, function()
                    focused = true
                    refreshInput(true)
                end)
                lifecycle:Connect(textBox.FocusLost, function(enterPressed)
                    focused = false
                    refreshInput(true)
                    writeSetting(configId, textBox.Text)
                    if enterPressed then
                        callback(textBox.Text)
                    end
                end)
                makeInfoButton(row, tTip)

                function TextBoxFunctions:SetValue(newValue, fireCallback)
                    textBox.Text = tostring(newValue or "")
                    writeSetting(configId, textBox.Text)
                    if fireCallback then
                        callback(textBox.Text)
                    end
                end

                function TextBoxFunctions:GetValue()
                    return textBox.Text
                end

                return TextBoxFunctions
            end

            function Elements:NewToggle(tname, nTip, callback)
                local TogFunction = {}
                tname = tname or "Toggle"
                nTip = nTip or "Prints Current Toggle State"
                callback = callback or function() end
                local configId = settingKey(tabName, secName, "toggle", tname)
                local toggled = readSetting(configId, false) == true

                local row = makeRow(sectionInners, ROW_HEIGHT)
                local nameLabel = makeLabel(
                    row,
                    tname,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(1, -92, 1, 0),
                    13,
                    Enum.Font.GothamMedium
                )

                local switch = create("TextButton", {
                    Name = "Switch",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0.5, 0),
                    Size = UDim2.fromOffset(38, 20),
                    BackgroundColor3 = themeList.ElementColor,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 10,
                }, row)
                addCorner(switch, 10)
                local knob = create("Frame", {
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.fromOffset(14, 14),
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, switch)
                addCorner(knob, 7)

                local function refreshToggle(animate)
                    local colors = palette()
                    local switchColor = toggled and colors.Accent or colors.Track
                    local knobPosition = toggled and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
                    if animate then
                        lifecycle:Tween(switch, { BackgroundColor3 = switchColor }, 0.16)
                        lifecycle:Tween(knob, { Position = knobPosition }, 0.16)
                    else
                        switch.BackgroundColor3 = switchColor
                        knob.Position = knobPosition
                    end
                    knob.BackgroundColor3 = toggled and colors.OnAccent or colors.Muted
                end

                local function setToggle(value, fireCallback)
                    toggled = value == true
                    refreshToggle(true)
                    writeSetting(configId, toggled)
                    if fireCallback then
                        callback(toggled)
                    end
                end

                bindTheme(function()
                    refreshToggle(false)
                end)
                local labelAction = transparentButton(row, UDim2.fromOffset(0, 0), UDim2.new(1, -82, 1, 0))
                lifecycle:Connect(labelAction.Activated, function()
                    setToggle(not toggled, true)
                end)
                lifecycle:Connect(switch.Activated, function()
                    setToggle(not toggled, true)
                end)
                makeInfoButton(row, nTip)

                function TogFunction:UpdateToggle(newText, isTogOn)
                    if newText ~= nil then
                        nameLabel.Text = newText
                    end
                    if isTogOn == nil then
                        isTogOn = false
                    end
                    setToggle(isTogOn, true)
                end

                function TogFunction:SetValue(value, fireCallback)
                    setToggle(value, fireCallback == true)
                end

                function TogFunction:GetValue()
                    return toggled
                end

                return TogFunction
            end

            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                slidInf = slidInf or "Slider"
                slidTip = slidTip or "Slider tip here"
                maxvalue = tonumber(maxvalue) or 500
                minvalue = tonumber(minvalue) or 16
                callback = callback or function() end

                local SliderFunctions = {}
                local minimum = math.min(minvalue, maxvalue)
                local maximum = math.max(minvalue, maxvalue)
                local configId = settingKey(tabName, secName, "slider", slidInf)
                local value = math.clamp(tonumber(readSetting(configId, minimum)) or minimum, minimum, maximum)

                local row = makeRow(sectionInners, 45)
                makeLabel(
                    row,
                    slidInf,
                    UDim2.fromOffset(10, 1),
                    UDim2.new(1, -96, 0, 24),
                    13,
                    Enum.Font.GothamMedium
                )

                local valueLabel = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -38, 0, 1),
                    Size = UDim2.fromOffset(54, 24),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = tostring(value),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, row)

                local hitArea = create("TextButton", {
                    Position = UDim2.fromOffset(10, 24),
                    Size = UDim2.new(1, -48, 0, 17),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 9,
                }, row)

                local track = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.new(1, 0, 0, 4),
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, hitArea)
                addCorner(track, 2)
                local fill = create("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, track)
                addCorner(fill, 2)
                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(12, 12),
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, track)
                addCorner(knob, 6)
                local knobStroke = create("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.2,
                }, knob)

                local ratio = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                valueLabel.Text = tostring(value)

                local function refreshSlider(animate)
                    local colors = palette()
                    local fillSize = UDim2.new(ratio, 0, 1, 0)
                    local knobPosition = UDim2.new(ratio, 0, 0.5, 0)
                    if animate then
                        lifecycle:Tween(fill, { Size = fillSize }, 0.08, Enum.EasingStyle.Linear)
                        lifecycle:Tween(knob, { Position = knobPosition }, 0.08, Enum.EasingStyle.Linear)
                    else
                        fill.Size = fillSize
                        knob.Position = knobPosition
                    end
                    track.BackgroundColor3 = colors.Track
                    fill.BackgroundColor3 = colors.Accent
                    knob.BackgroundColor3 = colors.Text
                    knobStroke.Color = colors.Border
                    valueLabel.TextColor3 = colors.Accent
                end

                local function setFromPointer(position)
                    local width = math.max(hitArea.AbsoluteSize.X, 1)
                    ratio = math.clamp((position.X - hitArea.AbsolutePosition.X) / width, 0, 1)
                    local nextValue = math.floor(minimum + (maximum - minimum) * ratio + 0.5)
                    value = nextValue
                    valueLabel.Text = tostring(value)
                    refreshSlider(true)
                    writeSetting(configId, value)
                    callback(value)
                end

                bindTheme(function()
                    refreshSlider(false)
                end)
                lifecycle:Connect(hitArea.InputBegan, function(inputObject)
                    if isPointerPress(inputObject) then
                        startPointerSession(inputObject, setFromPointer)
                    end
                end)
                makeInfoButton(row, slidTip)

                function SliderFunctions:SetValue(newValue, fireCallback)
                    value = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
                    ratio = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                    valueLabel.Text = tostring(value)
                    refreshSlider(true)
                    writeSetting(configId, value)
                    if fireCallback then
                        callback(value)
                    end
                end

                function SliderFunctions:GetValue()
                    return value
                end

                return SliderFunctions
            end

            function Elements:NewDropdown(dropname, dropinf, list, callback)
                local DropFunction = {}
                dropname = dropname or "Dropdown"
                dropinf = dropinf or "Dropdown info"
                list = list or {}
                callback = callback or function() end

                local opened = false
                local options = {}
                local configId = settingKey(tabName, secName, "dropdown", dropname)
                local selectedValue = readSetting(configId, nil)
                local optionHeight = 30

                local function isValidSelection(value)
                    for _, optionValue in next, list do
                        if optionValue == value then
                            return true
                        end
                    end
                    return false
                end

                if not isValidSelection(selectedValue) then
                    selectedValue = nil
                end

                local container, containerStroke = makeRow(sectionInners, ROW_HEIGHT)
                container.Name = "dropFrame"
                makeLabel(
                    container,
                    dropname,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(0.48, -10, 0, ROW_HEIGHT),
                    13,
                    Enum.Font.GothamMedium
                )
                local selectionLabel = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -59, 0, 0),
                    Size = UDim2.new(0.45, -12, 0, ROW_HEIGHT),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = selectedValue ~= nil and tostring(selectedValue) or "Select",
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 9,
                }, container)
                local chevron = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0, ROW_HEIGHT / 2),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = "⌄",
                    TextSize = 13,
                    ZIndex = 9,
                }, container)
                local headerAction = transparentButton(
                    container,
                    UDim2.fromOffset(0, 0),
                    UDim2.new(1, -30, 0, ROW_HEIGHT)
                )
                makeInfoButton(container, dropinf)

                local optionsHolder = create("Frame", {
                    Position = UDim2.fromOffset(5, ROW_HEIGHT),
                    Size = UDim2.new(1, -10, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Visible = false,
                }, container)
                local optionsLayout = create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                }, optionsHolder)

                bindTheme(function(colors)
                    selectionLabel.TextColor3 = selectedValue and colors.Accent or colors.Muted
                    chevron.TextColor3 = colors.Muted
                    containerStroke.Color = opened and mixColor(colors.Border, colors.Accent, 0.55) or colors.Border
                end)

                local function targetHeight()
                    if not opened then
                        return ROW_HEIGHT
                    end
                    return ROW_HEIGHT + optionsLayout.AbsoluteContentSize.Y + 6
                end

                local function refreshOpen(animated)
                    local height = targetHeight()
                    optionsHolder.Size = UDim2.new(1, -10, 0, math.max(0, height - ROW_HEIGHT - 6))
                    if opened then
                        optionsHolder.Visible = true
                    end
                    if animated then
                        lifecycle:Tween(container, { Size = UDim2.new(1, 0, 0, height) }, 0.18)
                        lifecycle:Tween(chevron, { Rotation = opened and 180 or 0 }, 0.16)
                        if not opened then
                            task.delay(0.19, function()
                                if not disposed and not opened and optionsHolder.Parent then
                                    optionsHolder.Visible = false
                                end
                            end)
                        end
                    else
                        container.Size = UDim2.new(1, 0, 0, height)
                        chevron.Rotation = opened and 180 or 0
                        optionsHolder.Visible = opened
                    end
                    local colors = palette()
                    containerStroke.Color = opened and mixColor(colors.Border, colors.Accent, 0.55) or colors.Border
                end

                local function setOpened(value)
                    opened = value
                    refreshOpen(true)
                end

                lifecycle:Connect(headerAction.Activated, function()
                    setOpened(not opened)
                end)

                local function clearOptions()
                    for _, optionRecord in ipairs(options) do
                        if optionRecord.Unbind then
                            optionRecord.Unbind()
                        end
                        for _, connection in ipairs(optionRecord.Connections) do
                            connection:Disconnect()
                            lifecycle:Untrack(connection)
                        end
                        lifecycle:ForgetTween(optionRecord.Button)
                        if optionRecord.Button.Parent then
                            optionRecord.Button:Destroy()
                        end
                    end
                    table.clear(options)
                end

                local function addOption(optionValue)
                    local option = create("TextButton", {
                        Name = "optionSelect",
                        Size = UDim2.new(1, 0, 0, optionHeight),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Font = Enum.Font.Gotham,
                        Text = "  " .. tostring(optionValue),
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    }, optionsHolder)
                    addCorner(option, 5)
                    local hovered = false
                    local optionRecord = {
                        Button = option,
                        Connections = {},
                    }
                    optionRecord.Unbind = bindTheme(function(colors)
                        option.TextColor3 = hovered and colors.Text or colors.Muted
                        option.BackgroundColor3 = colors.Hover
                        option.BackgroundTransparency = hovered and 0.15 or 1
                    end)
                    table.insert(optionRecord.Connections, lifecycle:Connect(option.MouseEnter, function()
                        hovered = true
                        local colors = palette()
                        lifecycle:Tween(option, {
                            BackgroundTransparency = 0.15,
                            BackgroundColor3 = colors.Hover,
                            TextColor3 = colors.Text,
                        }, 0.12)
                    end))
                    table.insert(optionRecord.Connections, lifecycle:Connect(option.MouseLeave, function()
                        hovered = false
                        lifecycle:Tween(option, {
                            BackgroundTransparency = 1,
                            TextColor3 = palette().Muted,
                        }, 0.12)
                    end))
                    table.insert(optionRecord.Connections, lifecycle:Connect(option.Activated, function()
                        selectedValue = optionValue
                        selectionLabel.Text = tostring(optionValue)
                        selectionLabel.TextColor3 = palette().Accent
                        writeSetting(configId, optionValue)
                        callback(optionValue)
                        setOpened(false)
                    end))
                    table.insert(options, optionRecord)
                end

                local function rebuild(newList)
                    clearOptions()
                    for _, optionValue in next, newList do
                        addOption(optionValue)
                    end
                    task.defer(function()
                        if not disposed and container.Parent then
                            refreshOpen(false)
                        end
                    end)
                end

                rebuild(list)

                function DropFunction:Refresh(newList)
                    list = newList or {}
                    rebuild(list)
                    if not isValidSelection(selectedValue) then
                        selectedValue = nil
                        selectionLabel.Text = "Select"
                    end
                end

                function DropFunction:SetValue(newValue, fireCallback)
                    if not isValidSelection(newValue) then
                        return false
                    end
                    selectedValue = newValue
                    selectionLabel.Text = tostring(newValue)
                    selectionLabel.TextColor3 = palette().Accent
                    writeSetting(configId, newValue)
                    if fireCallback then
                        callback(newValue)
                    end
                    return true
                end

                function DropFunction:GetValue()
                    return selectedValue
                end

                return DropFunction
            end

            function Elements:NewKeybind(keytext, keyinf, first, callback)
                keytext = keytext or "KeybindText"
                keyinf = keyinf or "KebindInfo"
                callback = callback or function() end

                local row = makeRow(sectionInners, ROW_HEIGHT)
                makeLabel(
                    row,
                    keytext,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(1, -132, 1, 0),
                    13,
                    Enum.Font.GothamMedium
                )

                local bindButton = create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0.5, 0),
                    Size = UDim2.fromOffset(88, 24),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamSemibold,
                    Text = bindingName(first),
                    TextSize = 10,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10,
                }, row)
                addCorner(bindButton, 5)
                local bindStroke = create("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.3,
                }, bindButton)

                local record = {
                    ConfigKey = configId,
                    Binding = first,
                    Callback = callback,
                    Display = bindButton,
                    Capturing = false,
                }

                function record.Refresh(animate)
                    local colors = palette()
                    local properties = {
                        BackgroundColor3 = record.Capturing and colors.AccentSoft or colors.Track,
                        TextColor3 = record.Capturing and colors.Accent or colors.Text,
                    }
                    if animate then
                        lifecycle:Tween(bindButton, properties, 0.15)
                        lifecycle:Tween(bindStroke, {
                            Color = record.Capturing and colors.Accent or colors.Border,
                            Transparency = record.Capturing and 0.05 or 0.3,
                        }, 0.15)
                    else
                        bindButton.BackgroundColor3 = properties.BackgroundColor3
                        bindButton.TextColor3 = properties.TextColor3
                        bindStroke.Color = record.Capturing and colors.Accent or colors.Border
                        bindStroke.Transparency = record.Capturing and 0.05 or 0.3
                    end
                end

                bindTheme(function()
                    record.Refresh(false)
                end)
                lifecycle:Connect(bindButton.Activated, function()
                    if captureRecord and captureRecord ~= record then
                        captureRecord.Capturing = false
                        captureRecord.Display.Text = bindingName(captureRecord.Binding)
                        captureRecord.Refresh(true)
                    end
                    captureRecord = record
                    record.Capturing = true
                    bindButton.Text = "PRESS…"
                    record.Refresh(true)
                end)
                table.insert(keybinds, record)
                makeInfoButton(row, keyinf)
            end

            function Elements:NewColorPicker(colText, colInf, defcolor, callback)
                colText = colText or "ColorPicker"
                colInf = colInf or "Select a color"
                defcolor = defcolor or Color3.fromRGB(1, 1, 1)
                callback = callback or function() end
                local configId = settingKey(tabName, secName, "color", colText)
                defcolor = colorFromHex(readSetting(configId, nil), defcolor)

                local hue, saturation, value = Color3.toHSV(defcolor)
                local colorOpened = false
                local rainbow = false
                local rainbowConnection = nil

                local container, containerStroke = makeRow(sectionInners, ROW_HEIGHT)
                container.Name = "colorElement"
                local titleLabel = makeLabel(
                    container,
                    colText,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(1, -116, 0, ROW_HEIGHT),
                    13,
                    Enum.Font.GothamMedium
                )

                local swatch = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -59, 0, ROW_HEIGHT / 2),
                    Size = UDim2.fromOffset(28, 18),
                    BackgroundColor3 = defcolor,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, container)
                addCorner(swatch, 5)
                local swatchStroke = create("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.25,
                }, swatch)

                local chevron = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0, ROW_HEIGHT / 2),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = "⌄",
                    TextSize = 13,
                    ZIndex = 9,
                }, container)
                local headerAction = transparentButton(
                    container,
                    UDim2.fromOffset(0, 0),
                    UDim2.new(1, -30, 0, ROW_HEIGHT)
                )
                makeInfoButton(container, colInf)

                local picker = create("Frame", {
                    Position = UDim2.fromOffset(6, ROW_HEIGHT + 3),
                    Size = UDim2.new(1, -12, 0, 88),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Visible = false,
                }, container)

                local sv = create("Frame", {
                    Name = "SaturationValue",
                    Position = UDim2.fromOffset(2, 3),
                    Size = UDim2.new(1, -148, 0, 78),
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                }, picker)
                addCorner(sv, 5)

                local whiteOverlay = create("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                }, sv)
                create("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                }, whiteOverlay)

                local blackOverlay = create("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                }, sv)
                create("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                }, blackOverlay)

                local svInput = transparentButton(sv, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))
                svInput.ZIndex = 12
                local svMarker = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(saturation, 1 - value),
                    Size = UDim2.fromOffset(10, 10),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 13,
                }, sv)
                addCorner(svMarker, 5)
                local svMarkerStroke = create("UIStroke", {
                    Thickness = 2,
                    Color = Color3.new(1, 1, 1),
                    Transparency = 0,
                }, svMarker)

                local hueBar = create("Frame", {
                    Name = "Hue",
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -124, 0, 3),
                    Size = UDim2.fromOffset(16, 78),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                }, picker)
                addCorner(hueBar, 5)
                create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                    }),
                }, hueBar)
                local hueInput = transparentButton(hueBar, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))
                hueInput.ZIndex = 12
                local hueMarker = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, hue),
                    Size = UDim2.new(1, 6, 0, 3),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 13,
                }, hueBar)
                addCorner(hueMarker, 2)

                local rainbowLabel = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -3, 0, 7),
                    Size = UDim2.fromOffset(91, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = "Rainbow",
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, picker)
                local rainbowSwitch = create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -4, 0, 31),
                    Size = UDim2.fromOffset(38, 20),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 10,
                }, picker)
                addCorner(rainbowSwitch, 10)
                local rainbowKnob = create("Frame", {
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.fromOffset(14, 14),
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, rainbowSwitch)
                addCorner(rainbowKnob, 7)

                local function currentColor()
                    return Color3.fromHSV(hue, saturation, value)
                end

                local function refreshColor(fireCallback)
                    local selected = currentColor()
                    sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    svMarker.Position = UDim2.fromScale(saturation, 1 - value)
                    hueMarker.Position = UDim2.fromScale(0.5, hue)
                    swatch.BackgroundColor3 = selected
                    if fireCallback then
                        callback(selected)
                    end
                end

                local function refreshRainbow(animate)
                    local colors = palette()
                    local knobPosition = rainbow and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
                    local switchColor = rainbow and colors.Accent or colors.Track
                    if animate then
                        lifecycle:Tween(rainbowSwitch, { BackgroundColor3 = switchColor }, 0.16)
                        lifecycle:Tween(rainbowKnob, { Position = knobPosition }, 0.16)
                    else
                        rainbowSwitch.BackgroundColor3 = switchColor
                        rainbowKnob.Position = knobPosition
                    end
                    rainbowKnob.BackgroundColor3 = rainbow and colors.OnAccent or colors.Muted
                end

                local function setRainbow(enabled)
                    rainbow = enabled
                    if rainbowConnection then
                        rainbowConnection:Disconnect()
                        lifecycle:Untrack(rainbowConnection)
                        rainbowConnection = nil
                    end
                    if rainbow then
                        rainbowConnection = RunService.RenderStepped:Connect(function()
                            hue = (time() * 0.12) % 1
                            saturation = 1
                            value = 1
                            refreshColor(true)
                        end)
                        lifecycle:Track(rainbowConnection)
                    end
                    refreshRainbow(true)
                end

                local function setSVFromPointer(position)
                    if rainbow then
                        setRainbow(false)
                    end
                    local relativeX = (position.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1)
                    local relativeY = (position.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1)
                    saturation = math.clamp(relativeX, 0, 1)
                    value = 1 - math.clamp(relativeY, 0, 1)
                    refreshColor(true)
                    writeSetting(configId, colorToHex(currentColor()))
                end

                local function setHueFromPointer(position)
                    if rainbow then
                        setRainbow(false)
                    end
                    local relativeY = (position.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1)
                    hue = math.clamp(relativeY, 0, 1)
                    refreshColor(true)
                    writeSetting(configId, colorToHex(currentColor()))
                end

                bindTheme(function(colors)
                    titleLabel.TextColor3 = colors.Text
                    chevron.TextColor3 = colors.Muted
                    containerStroke.Color = colorOpened and mixColor(colors.Border, colors.Accent, 0.55) or colors.Border
                    swatchStroke.Color = colors.Border
                    rainbowLabel.TextColor3 = colors.Muted
                    svMarkerStroke.Color = colors.OnAccent
                    refreshRainbow(false)
                end)

                local function setColorOpened(valueOpened)
                    colorOpened = valueOpened
                    if colorOpened then
                        picker.Visible = true
                    end
                    local height = colorOpened and 133 or ROW_HEIGHT
                    lifecycle:Tween(container, { Size = UDim2.new(1, 0, 0, height) }, 0.18)
                    lifecycle:Tween(chevron, { Rotation = colorOpened and 180 or 0 }, 0.16)
                    if not colorOpened then
                        task.delay(0.19, function()
                            if not disposed and not colorOpened and picker.Parent then
                                picker.Visible = false
                            end
                        end)
                    end
                    local colors = palette()
                    containerStroke.Color = colorOpened and mixColor(colors.Border, colors.Accent, 0.55) or colors.Border
                end

                lifecycle:Connect(headerAction.Activated, function()
                    setColorOpened(not colorOpened)
                end)
                lifecycle:Connect(svInput.InputBegan, function(inputObject)
                    if isPointerPress(inputObject) then
                        startPointerSession(inputObject, setSVFromPointer)
                    end
                end)
                lifecycle:Connect(hueInput.InputBegan, function(inputObject)
                    if isPointerPress(inputObject) then
                        startPointerSession(inputObject, setHueFromPointer)
                    end
                end)
                lifecycle:Connect(rainbowSwitch.Activated, function()
                    setRainbow(not rainbow)
                end)
                refreshColor(false)
            end

            function Elements:NewLabel(title)
                local labelFunctions = {}
                title = title or "Label"

                local row = create("Frame", {
                    Name = "label",
                    Size = UDim2.new(1, 0, 0, 31),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                }, sectionInners)
                addCorner(row, 5)
                local accent = create("Frame", {
                    Size = UDim2.new(0, 2, 1, 0),
                    BorderSizePixel = 0,
                }, row)
                local label = create("TextLabel", {
                    Position = UDim2.fromOffset(10, 0),
                    Size = UDim2.new(1, -18, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    RichText = true,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }, row)
                bindTheme(function(colors)
                    row.BackgroundColor3 = colors.AccentSoft
                    accent.BackgroundColor3 = colors.Accent
                    label.TextColor3 = colors.Text
                end)

                function labelFunctions:UpdateLabel(newText)
                    label.Text = newText
                end

                return labelFunctions
            end

            return Elements
        end

        return Sections
    end

    return Tabs
end

return Kavo
