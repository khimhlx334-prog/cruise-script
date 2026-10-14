-- KaiJor Hub v0.2.0 | Standalone client UI and session monitor.
-- Run as a LocalScript or in a client Lua environment supporting Roblox APIs.
-- The background monitor reports session state. It is not account ban protection.

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
assert(player, "KaiJor Hub must run on the client.")
local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("KaiJorHub")
if previous then previous:Destroy() end

-- Separate lifetime: closing the visible UI does not stop the monitor.
-- Re-running the hub reuses this controller instead of spawning another loop.
local monitor = playerGui:FindFirstChild("KaiJorSessionMonitor")
if not monitor then
    monitor = Instance.new("ScreenGui")
    monitor.Name = "KaiJorSessionMonitor"
    monitor.ResetOnSpawn = false
    monitor.Enabled = false
    monitor:SetAttribute("Running", false)
    monitor:SetAttribute("Seconds", 0)
    monitor:SetAttribute("Samples", 0)
    monitor:SetAttribute("PlaceId", game.PlaceId)
    monitor:SetAttribute("CharacterState", "Waiting")
    local command = Instance.new("BindableEvent")
    command.Name = "Command"
    command.Parent = monitor
    monitor.Parent = playerGui

    local heartbeat, elapsed, interval = nil, 0, 0
    local function stop()
        if heartbeat then heartbeat:Disconnect(); heartbeat = nil end
        monitor:SetAttribute("Running", false)
    end
    local function start()
        if heartbeat then return end
        interval = 0
        monitor:SetAttribute("Running", true)
        heartbeat = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            interval = interval + dt
            if interval < 2 then return end
            interval = interval % 2
            monitor:SetAttribute("Seconds", math.floor(elapsed))
            monitor:SetAttribute("CharacterState", player.Character and "Present" or "Respawning")
            monitor:SetAttribute("Samples", monitor:GetAttribute("Samples") + 1)
        end)
    end
    local commands = command.Event:Connect(function(action)
        if action == "Start" then start()
        elseif action == "Stop" then stop() end
    end)
    local destroying
    destroying = monitor.Destroying:Connect(function()
        stop()
        commands:Disconnect()
        destroying:Disconnect()
    end)
    start()
end
local monitorCommand = monitor:WaitForChild("Command")

local colors = {
    background = Color3.fromRGB(15, 16, 24),
    panel = Color3.fromRGB(24, 25, 37),
    raised = Color3.fromRGB(33, 34, 49),
    border = Color3.fromRGB(49, 50, 69),
    text = Color3.fromRGB(244, 243, 255),
    muted = Color3.fromRGB(158, 159, 181),
    accent = Color3.fromRGB(158, 120, 255),
    mint = Color3.fromRGB(94, 220, 180),
}
local connections, activeTweens = {}, {}
local alive, reducedMotion = true, false
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function create(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 12)}, object)
end
local function stroke(object, color)
    return create("UIStroke", {Color = color or colors.border, Thickness = 1}, object)
end
local function label(parent, text, size, position, bounds, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = size or 14,
        Font = font or Enum.Font.Gotham, TextColor3 = color or colors.text,
        Position = position or UDim2.new(), Size = bounds or UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end
local function button(parent, text, size, position, color)
    local object = create("TextButton", {
        Size = size, Position = position, Text = text,
        BackgroundColor3 = color or colors.raised, BorderSizePixel = 0,
        TextColor3 = colors.text, TextSize = 14, Font = Enum.Font.GothamMedium,
        AutoButtonColor = true,
    }, parent)
    round(object, 10)
    return object
end
local function animate(object, props)
    if activeTweens[object] then activeTweens[object]:Cancel() end
    if reducedMotion then
        for key, value in pairs(props) do object[key] = value end
        return
    end
    local tween = TweenService:Create(object,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    activeTweens[object] = tween
    tween:Play()
end

local gui = create("ScreenGui", {
    Name = "KaiJorHub", ResetOnSpawn = false, DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
}, playerGui)
local root = create("Frame", {
    Name = "SafeArea", Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
}, gui)
local window = create("Frame", {
    Name = "Window", BackgroundColor3 = colors.background, BorderSizePixel = 0,
    Size = UDim2.fromOffset(620, 440), ClipsDescendants = true,
}, root)
round(window, 18)
stroke(window)
local header = create("Frame", {
    Name = "Header", BackgroundColor3 = colors.panel, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 76),
}, window)
local dragHandle = create("Frame", {
    Name = "DragHandle", Active = true, BackgroundTransparency = 1,
    Size = UDim2.new(1, -102, 1, 0),
}, header)
local emblem = label(header, "K", 23, UDim2.fromOffset(16, 17),
    UDim2.fromOffset(42, 42), colors.text, Enum.Font.GothamBold)
emblem.BackgroundTransparency = 0
emblem.BackgroundColor3 = colors.accent
emblem.TextXAlignment = Enum.TextXAlignment.Center
round(emblem, 13)
label(header, "KaiJor Hub", 21, UDim2.fromOffset(70, 13),
    UDim2.new(1, -178, 0, 30), colors.text, Enum.Font.GothamBold)
label(header, "CLIENT INTERFACE", 10, UDim2.fromOffset(70, 43),
    UDim2.new(1, -178, 0, 18), colors.muted)
local minimize = button(header, "-", UDim2.fromOffset(38, 38), UDim2.new(1, -94, 0, 19))
local close = button(header, "X", UDim2.fromOffset(38, 38), UDim2.new(1, -50, 0, 19))
local tabsBar = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 88),
    Size = UDim2.new(1, -32, 0, 40),
}, window)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabsBar)
local pageArea = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 142),
    Size = UDim2.new(1, -32, 1, -183),
}, window)
label(window, "KaiJor Hub  /  v0.2.0", 11,
    UDim2.new(0, 18, 1, -30), UDim2.new(1, -36, 0, 20), colors.muted)
local reopen = button(root, "K", UDim2.fromOffset(48, 48), UDim2.fromOffset(16, 16), colors.accent)
reopen.Name = "Reopen"
reopen.Visible = false
reopen.TextSize = 22
reopen.Font = Enum.Font.GothamBold
stroke(reopen, colors.accent)

local pages, tabButtons = {}, {}
local function page(name)
    local object = create("ScrollingFrame", {
        Name = name, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = colors.accent,
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
    }, pageArea)
    create("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, object)
    create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, object)
    pages[name] = object
    return object
end
local function card(parent, height, order)
    local object = create("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = colors.panel,
        BorderSizePixel = 0, LayoutOrder = order,
    }, parent)
    round(object, 12)
    stroke(object)
    return object
end
local home = page("Home")
local hero = card(home, 142, 1)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 33, 78)),
        ColorSequenceKeypoint.new(1, colors.panel),
    }), Rotation = 20,
}, hero)
label(hero, "WELCOME TO KAIJOR", 10, UDim2.fromOffset(16, 13),
    UDim2.new(1, -32, 0, 18), colors.accent, Enum.Font.GothamBold)
label(hero, "Make it yours.", 26, UDim2.fromOffset(16, 35),
    UDim2.new(1, -32, 0, 42), colors.text, Enum.Font.GothamBold)
label(hero, "A clean workspace, built around you.", 13, UDim2.fromOffset(16, 79),
    UDim2.new(1, -32, 0, 45), colors.muted)
local status = card(home, 78, 2)
label(status, "INTERFACE STATUS", 10, UDim2.fromOffset(16, 12),
    UDim2.new(1, -32, 0, 16), colors.muted, Enum.Font.GothamBold)
local statusText = label(status, "Ready  /  Monitor running", 16, UDim2.fromOffset(16, 32),
    UDim2.new(1, -32, 0, 30), colors.mint, Enum.Font.GothamMedium)
local hint = card(home, 88, 3)
label(hint, "Move freely", 15, UDim2.fromOffset(16, 11), UDim2.new(1, -32, 0, 24),
    colors.text, Enum.Font.GothamMedium)
label(hint, "Drag the header to move. Tap - to minimize and K to reopen.", 12,
    UDim2.fromOffset(16, 37), UDim2.new(1, -32, 0, 40), colors.muted)

local controls = page("Controls")
local monitorCard = card(controls, 264, 1)
label(monitorCard, "BACKGROUND MONITOR", 11, UDim2.fromOffset(16, 14),
    UDim2.new(1, -32, 0, 22), colors.accent, Enum.Font.GothamBold)
local monitorText = label(monitorCard, "", 13, UDim2.fromOffset(16, 48),
    UDim2.new(1, -32, 0, 142), colors.text)
monitorText.TextYAlignment = Enum.TextYAlignment.Top
local monitorButton = button(monitorCard, "Stop monitor", UDim2.new(1, -32, 0, 42),
    UDim2.fromOffset(16, 205))
local note = card(controls, 128, 2)
label(note, "Session monitoring only", 15, UDim2.fromOffset(16, 12),
    UDim2.new(1, -32, 0, 32), colors.text, Enum.Font.GothamMedium)
label(note, "No account ban protection. Monitoring continues after closing this UI and ends when you leave the game.", 12,
    UDim2.fromOffset(16, 49), UDim2.new(1, -32, 0, 66), colors.muted)
local function refreshMonitor()
    local running = monitor:GetAttribute("Running")
    local seconds = monitor:GetAttribute("Seconds") or 0
    statusText.Text = running and "Ready  /  Monitor running" or "Ready  /  Monitor stopped"
    statusText.TextColor3 = running and colors.mint or colors.muted
    monitorButton.Text = running and "Stop monitor" or "Start monitor"
    monitorText.Text = string.format("Status: %s\nActive time: %02d:%02d\nSamples: %d\nPlace ID: %s\nCharacter: %s\nAccount protection: unavailable",
        running and "Running" or "Stopped", math.floor(seconds / 60), seconds % 60,
        monitor:GetAttribute("Samples") or 0, tostring(monitor:GetAttribute("PlaceId")),
        monitor:GetAttribute("CharacterState") or "Waiting")
end
connect(monitor:GetAttributeChangedSignal("Samples"), refreshMonitor)
connect(monitor:GetAttributeChangedSignal("Running"), refreshMonitor)
connect(monitorButton.Activated, function()
    monitorCommand:Fire(monitor:GetAttribute("Running") and "Stop" or "Start")
end)
refreshMonitor()

local settings = page("Settings")
local motionCard = card(settings, 114, 1)
label(motionCard, "Reduced motion", 15, UDim2.fromOffset(16, 12),
    UDim2.new(1, -32, 0, 24), colors.text, Enum.Font.GothamMedium)
local motionButton = button(motionCard, "Reduced motion: OFF",
    UDim2.new(1, -32, 0, 42), UDim2.fromOffset(16, 55))
connect(motionButton.Activated, function()
    reducedMotion = not reducedMotion
    motionButton.Text = "Reduced motion: " .. (reducedMotion and "ON" or "OFF")
    if reducedMotion then
        for _, tween in pairs(activeTweens) do tween:Cancel() end
    end
end)
local resetCard = card(settings, 114, 2)
label(resetCard, "Window position", 15, UDim2.fromOffset(16, 12),
    UDim2.new(1, -32, 0, 24), colors.text, Enum.Font.GothamMedium)
local reset = button(resetCard, "Center window", UDim2.new(1, -32, 0, 42), UDim2.fromOffset(16, 55))

local selected = "Home"
local function selectPage(name)
    selected = name
    for key, object in pairs(pages) do object.Visible = key == name end
    for key, object in pairs(tabButtons) do
        animate(object, {BackgroundColor3 = key == name and colors.accent or colors.panel})
    end
end
for order, name in ipairs({"Home", "Controls", "Settings"}) do
    local tab = button(tabsBar, name, UDim2.new(1 / 3, -16 / 3, 1, 0), UDim2.new())
    tab.Name, tab.LayoutOrder = name, order
    tabButtons[name] = tab
    connect(tab.Activated, function() selectPage(name) end)
end

local initialized = false
local function clampPosition(x, y)
    local bounds, size = root.AbsoluteSize, window.AbsoluteSize
    return math.clamp(x, 0, math.max(0, bounds.X - size.X)),
        math.clamp(y, 0, math.max(0, bounds.Y - size.Y))
end
local function centerWindow()
    local bounds, size = root.AbsoluteSize, window.AbsoluteSize
    window.Position = UDim2.fromOffset(math.max(0, (bounds.X - size.X) / 2),
        math.max(0, (bounds.Y - size.Y) / 2))
end
local function fitWindow()
    local bounds = root.AbsoluteSize
    if bounds.X <= 0 or bounds.Y <= 0 then return end
    window.Size = UDim2.fromOffset(math.min(620, math.max(1, bounds.X - 24)),
        math.min(440, math.max(1, bounds.Y - 24)))
    if not initialized then
        initialized = true
        centerWindow()
    else
        local x, y = clampPosition(window.Position.X.Offset, window.Position.Y.Offset)
        window.Position = UDim2.fromOffset(x, y)
    end
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), fitWindow)
connect(reset.Activated, centerWindow)

local dragInput, dragStart, startPosition
connect(dragHandle.InputBegan, function(input)
    if dragInput then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput, dragStart, startPosition = input, input.Position, window.Position
    end
end)
connect(Input.InputChanged, function(input)
    if not dragInput then return end
    local isTouch = dragInput.UserInputType == Enum.UserInputType.Touch
    if (isTouch and input ~= dragInput)
        or (not isTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
    local delta = input.Position - dragStart
    local x, y = clampPosition(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
    window.Position = UDim2.fromOffset(x, y)
end)
connect(Input.InputEnded, function(input)
    if input == dragInput then dragInput = nil end
end)
local function toggleWindow()
    dragInput = nil
    window.Visible = not window.Visible
    reopen.Visible = not window.Visible
end
connect(minimize.Activated, toggleWindow)
connect(reopen.Activated, toggleWindow)
connect(Input.InputBegan, function(input, processed)
    if not processed and not Input:GetFocusedTextBox()
        and input.KeyCode == Enum.KeyCode.RightShift then toggleWindow() end
end)
connect(close.Activated, function() gui:Destroy() end)
connect(gui.Destroying, function()
    alive = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for _, tween in pairs(activeTweens) do tween:Cancel() end
    dragInput = nil
end)

selectPage(selected)
fitWindow()
task.defer(function() if alive then fitWindow() end end)
