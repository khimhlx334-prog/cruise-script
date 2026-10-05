--================================================================--
--        KAIJOR HUB · ไก่จ๊อ ฮับ · CRUISE LINE TYCOON
--        v3.1.1 HOTFIX · แก้รันไม่ขึ้นในเกมจริง 100%
--   -------------------------------------------------------------
--   วิธีใช้: Delta → กด Attach/Inject ให้เขียวก่อน → วางสคริปต์
--   → Execute → จะมีการ์ดตัว "ก" เด้งยืนยันทันที
--================================================================--

local BRAND   = "KAIJOR HUB"
local VERSION = "3.1.2"
local LOGO    = "ก"

print("==== KAIJOR BOOT START v" .. VERSION .. " ====") -- เห็นบรรทัดนี้ = ไฟล์มาครบและเริ่มทำงานแล้ว

-- รอให้ตัวเกมโหลดเสร็จก่อนเสมอ (สาเหตุยอดฮิตของอาการกดแล้วเงียบ)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

--================================================================--
-- [0] กันรันซ้ำ + SERVICES (อยู่นอก xpcall เพื่อให้ return ได้)
--================================================================--
do
    local g = (type(getgenv) == "function" and getgenv()) or _G
    if g.KAIJOR_RUNNING then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "KAIJOR HUB · ไก่จ๊อ",
                Text = "สคริปต์รันอยู่แล้ว — ระบบกันรันซ้ำทำงาน",
                Duration = 4,
            })
        end)
        return
    end
    g.KAIJOR_RUNNING = true
end

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local StarterGui       = game:GetService("StarterGui")
local LP = Players.LocalPlayer

local requestFn = (type(request) == "function" and request)
    or (type(http_request) == "function" and http_request)
    or (type(http) == "table" and type(http.request) == "function" and http.request)
    or (type(syn) == "table" and type(syn.request) == "function" and syn.request)

local EXEC_NAME = (type(identifyexecutor) == "function" and identifyexecutor())
    or (type(getexecutorname) == "function" and getexecutorname())
    or "unknown"

local function log(tag, msg)
    print(string.format("[KAIJOR|%s] %s", tag, msg))
end

--================================================================--
-- [1] เซฟติ้ง
--================================================================--
local DEFAULTS = {
    speedEnabled  = false, speedKnots = 40,
    antiAfk = true, antiBan = true,
    boostFps = false, safeTween = false,
    webhookUrl = "", webhookDock = true, webhookMoney = true,
    moneyEveryMin = 5, autoSave = true,
}
local CONFIG_PATH = "kaijor_hub/config.json"
local CFG = {}
for k, v in pairs(DEFAULTS) do CFG[k] = v end

local function saveConfig()
    if type(writefile) ~= "function" then return end
    pcall(function()
        if type(isfolder) == "function" and not isfolder("kaijor_hub") then
            makefolder("kaijor_hub")
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(CFG))
    end)
end

pcall(function()
    if type(readfile) == "function" and type(isfile) == "function"
        and isfile(CONFIG_PATH) then
        local ok2, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_PATH))
        end)
        if ok2 and type(data) == "table" then
            for k, v in pairs(data) do CFG[k] = v end
        end
    end
end)

--================================================================--
-- [2] ระบบโนติฟาย achievement-style โลโก้ "ก" (สร้างก่อนเสมอ)
--================================================================--
local ORANGE = Color3.fromRGB(232, 145, 45)
local DARK   = Color3.fromRGB(16, 12, 10)
local PANEL  = Color3.fromRGB(28, 21, 16)
local LINE   = Color3.fromRGB(64, 46, 28)
local WHITE  = Color3.fromRGB(255, 244, 232)
local MUTE   = Color3.fromRGB(170, 150, 130)

local SAFE_PARENT = nil
do
    -- ลำดับ: gethui -> CoreGui -> PlayerGui (รอนานสุด 30 วิ)
    if type(gethui) == "function" then
        local ok2, res = pcall(gethui)
        if ok2 and res then SAFE_PARENT = res end
    end
    if not SAFE_PARENT then
        local ok3, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok3 and cg then SAFE_PARENT = cg end
    end
    if not SAFE_PARENT then
        local pg = LP:WaitForChild("PlayerGui", 30)
        if pg then SAFE_PARENT = pg end
    end
end

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "KaijorNotify"
NotifyGui.ResetOnSpawn = false
NotifyGui.IgnoreGuiInset = true
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.DisplayOrder = 999

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "Holder"
NotifyHolder.AnchorPoint = Vector2.new(1, 0)
NotifyHolder.Position = UDim2.new(1, -12, 0, 12)
NotifyHolder.Size = UDim2.fromOffset(310, 620)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Parent = NotifyGui
local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Parent = NotifyHolder

local function toast(title, desc, dur)
    local ok, err = pcall(function()
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 64)
        card.BackgroundColor3 = PANEL
        card.BorderSizePixel = 0
        card.Position = UDim2.new(1.4, 0, 0, 0)
        local c1 = Instance.new("UICorner")
        c1.CornerRadius = UDim.new(0, 12)
        c1.Parent = card
        local st = Instance.new("UIStroke")
        st.Color = ORANGE
        st.Transparency = 0.35
        st.Thickness = 1.5
        st.Parent = card

        local logo = Instance.new("TextLabel")
        logo.Size = UDim2.fromOffset(40, 40)
        logo.Position = UDim2.new(0, 10, 0.5, -20)
        logo.BackgroundColor3 = ORANGE
        logo.Text = LOGO
        logo.Font = Enum.Font.GothamBold
        logo.TextSize = 22
        logo.TextColor3 = Color3.fromRGB(20, 14, 8)
        logo.Parent = card
        local c2 = Instance.new("UICorner")
        c2.CornerRadius = UDim.new(1, 0)
        c2.Parent = logo

        local t1 = Instance.new("TextLabel")
        t1.Position = UDim2.new(0, 60, 0, 10)
        t1.Size = UDim2.new(1, -70, 0, 20)
        t1.BackgroundTransparency = 1
        t1.Font = Enum.Font.GothamBold
        t1.TextSize = 13
        t1.TextXAlignment = Enum.TextXAlignment.Left
        t1.TextColor3 = WHITE
        t1.Text = title
        t1.Parent = card

        local t2 = Instance.new("TextLabel")
        t2.Position = UDim2.new(0, 60, 0, 30)
        t2.Size = UDim2.new(1, -70, 0, 26)
        t2.BackgroundTransparency = 1
        t2.Font = Enum.Font.Gotham
        t2.TextSize = 11
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.TextYAlignment = Enum.TextYAlignment.Top
        t2.TextColor3 = MUTE
        t2.Text = desc
        t2.Parent = card

        card.Parent = NotifyHolder
        TweenService:Create(card,
            TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.delay(dur or 3.5, function()
            pcall(function()
                local out = TweenService:Create(card,
                    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { Position = UDim2.new(1.4, 0, 0, 0) })
                out:Play()
                out.Completed:Wait()
                card:Destroy()
            end)
        end)
    end)
    if not ok then warn("[KAIJOR] toast error: " .. tostring(err)) end
end

local function nativeNotify(text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "KAIJOR HUB · ไก่จ๊อ", Text = text, Duration = dur or 4,
        })
    end)
end

if SAFE_PARENT then
    pcall(function() NotifyGui.Parent = SAFE_PARENT end)
else
    NotifyGui.Parent = LP:WaitForChild("PlayerGui")
end

--================================================================--
-- [3] MAIN BOOT — ครอบด้วย xpcall: พังตรงไหนก็รู้ ไม่รันเงียบ
--================================================================--
local function main()
    toast("กำลังรันสคริปต์…", "KAIJOR HUB v" .. VERSION .. " กำลังบู๊ตระบบทั้งหมด")
    nativeNotify("ระบบกำลังรันสคริปต์ KAIJOR HUB v" .. VERSION)

    -- ---------- ตัวช่วย ----------
    local function fmt(n)
        local s = tostring(math.floor(n or 0))
        return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
    end

    local DOCK_WORDS = { "dock", "berth", "pier", "port", "moor", "arrived", "docked" }
    local BLOCK_WORDS = {
        "report", "flag", "anticheat", "anti_cheat", "telemetry",
        "aclog", "banlog", "watchdog", "cheatlog", "security",
    }
    local SHIP_WORDS = { "ship", "boat", "yacht", "liner", "cruise", "vessel" }
    local KNOT_TO_STUDS = 1.6878

    local function ownPlot()
        local folder = Workspace:FindFirstChild("Tycoons") or Workspace:FindFirstChild("Plots")
        if not folder then return nil end
        for _, plot in ipairs(folder:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and tostring(owner.Value) == LP.Name then return plot end
        end
        return nil
    end

    local shipCache = nil
    local function findShip()
        if shipCache and shipCache.Parent then return shipCache end
        local plot = ownPlot()
        if not plot then return nil end
        for _, d in ipairs(plot:GetDescendants()) do
            if d:IsA("Model") then
                local n = string.lower(d.Name)
                for _, w in ipairs(SHIP_WORDS) do
                    if string.find(n, w, 1, true) then
                        shipCache = d
                        return d
                    end
                end
            end
        end
        return nil
    end

    -- ---------- เว็บฮุก ----------
    local sendWebhook
    do
        local COLOR = 15263021
        sendWebhook = function(title, desc, fields)
            if not requestFn then return false end
            if (CFG.webhookUrl or "") == "" then return false end
            local body = {
                username = "KAIJOR HUB · ไก่จ๊อ",
                embeds = { {
                    title = title, description = desc, color = COLOR,
                    fields = fields or {},
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    footer = { text = "KAIJOR HUB v" .. VERSION },
                } },
            }
            local ok, res = pcall(function()
                return requestFn({
                    Url = CFG.webhookUrl, Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(body),
                })
            end)
            return ok and res ~= nil
                and (res.StatusCode == 200 or res.StatusCode == 204)
        end
    end

    -- ---------- money ----------
    local money = { cur = 0, gainedWindow = 0, gainedSession = 0 }
    task.spawn(function()
        pcall(function()
            local ls = LP:WaitForChild("leaderstats", 20)
            local cash = ls and ls:WaitForChild("Cash", 20)
            if not cash then return end
            money.cur = cash.Value
            cash.Changed:Connect(function(v)
                local d = v - money.cur
                if d > 0 then
                    money.gainedWindow += d
                    money.gainedSession += d
                end
                money.cur = v
            end)
        end)
    end)
    task.spawn(function()
        while true do
            task.wait(math.max(1, CFG.moneyEveryMin) * 60)
            if CFG.webhookMoney and CFG.webhookUrl ~= "" then
                sendWebhook("รายงานเงินอัตโนมัติ · MONEY REPORT",
                    "สรุปยอดเงินจาก KAIJOR HUB", {
                    { name = "เงินปัจจุบัน", value = "฿" .. fmt(money.cur), inline = true },
                    { name = "ได้มารอบนี้", value = "+฿" .. fmt(money.gainedWindow), inline = true },
                    { name = "รวมเซสชันนี้", value = "+฿" .. fmt(money.gainedSession), inline = true },
                    { name = "รายงานทุก", value = CFG.moneyEveryMin .. " นาที", inline = true },
                })
                money.gainedWindow = 0
            end
        end
    end)

    -- ---------- dock watcher ----------
    task.spawn(function()
        local dockCooldown = 0
        while true do
            local plot = ownPlot()
            if plot then
                plot.DescendantAdded:Connect(function(inst)
                    if os.clock() < dockCooldown then return end
                    local n = string.lower(inst.Name)
                    for _, w in ipairs(DOCK_WORDS) do
                        if string.find(n, w, 1, true) then
                            dockCooldown = os.clock() + 30
                            if CFG.webhookDock and CFG.webhookUrl ~= "" then
                                sendWebhook("เรือเทียบท่าแล้ว · SHIP DOCKED",
                                    "ระบบตรวจพบเรือเทียบท่าเรียบร้อย", {
                                    { name = "ท่าที่เทียบ", value = inst:GetFullName(), inline = false },
                                    { name = "พล็อต", value = plot.Name, inline = true },
                                    { name = "เงินตอนนี้", value = "฿" .. fmt(money.cur), inline = true },
                                })
                            end
                            toast("เรือเทียบท่าแล้ว", inst.Name .. " · ฿" .. fmt(money.cur))
                            break
                        end
                    end
                end)
                return
            end
            task.wait(5)
        end
    end)

    -- ---------- สปีด + ทวีนเซฟ ----------
    local function applySpeed()
        if not CFG.speedEnabled then return end
        local ship = findShip()
        if not ship then return end
        pcall(function()
            ship:SetAttribute("KaijorSpeedKnots", CFG.speedKnots)
            ship:SetAttribute("KaijorStudsPerSec", CFG.speedKnots * KNOT_TO_STUDS)
        end)
        pcall(function()
            for _, d in ipairs(ship:GetDescendants()) do
                if d:IsA("NumberValue") or d:IsA("IntValue") then
                    local n = string.lower(d.Name)
                    if n:find("speed") or n:find("knot") or n:find("velocity") then
                        d.Value = CFG.speedKnots * (n:find("stud") and KNOT_TO_STUDS or 1)
                    end
                end
            end
        end)
    end

    local Tween = { dir = 1, accum = 0, saved = {}, errStreak = 0 }
    local function tweenNoclip(on)
        local ship = findShip()
        if not ship then return end
        pcall(function()
            if on then
                for _, pD in ipairs(ship:GetDescendants()) do
                    if pD:IsA("BasePart") then
                        Tween.saved[pD] = pD.CanCollide
                        pD.CanCollide = false
                    end
                end
            else
                for pD, v in pairs(Tween.saved) do
                    if pD.Parent then pD.CanCollide = v end
                end
                Tween.saved = {}
            end
        end)
    end

    RunService.Heartbeat:Connect(function(dt)
        if CFG.speedEnabled then applySpeed() end
        if not CFG.safeTween then return end
        local ok = pcall(function()
            local ship = findShip()
            if not ship then return end
            local cf = ship:GetPivot()
            local speed = math.clamp(CFG.speedKnots * KNOT_TO_STUDS, 1, 120)
            local step = math.clamp(speed * dt, 0, 40)
            local offset = Tween.dir * step
            ship:PivotTo(cf + Vector3.new(0, 0, offset))
            Tween.accum += math.abs(offset)
            if Tween.accum >= 160 then
                Tween.accum = 0
                Tween.dir = -Tween.dir
            end
            Tween.errStreak = 0
        end)
        if not ok then
            Tween.errStreak += 1
            if Tween.errStreak > 240 then
                CFG.safeTween = false
                tweenNoclip(false)
                toast("ทวีนเรือหยุดอัตโนมัติ", "แมพขัดขวางการขยับจากไคลเอนต์ (server-owned)")
            end
        end
    end)

    -- ---------- anti-afk ----------
    local afkConn = nil
    local function setAntiAfk(state)
        if state and not afkConn then
            afkConn = LP.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        elseif not state and afkConn then
            afkConn:Disconnect()
            afkConn = nil
        end
    end

    -- ---------- anti-ban 6 ชั้น ----------
    local BLOCKS = 0
    local antiBanOn = false
    local lastBlockToast = 0
    local function blocked(kind)
        BLOCKS += 1
        if os.clock() - lastBlockToast > 6 then
            lastBlockToast = os.clock()
            toast("แอนตี้-แบนทำงาน", "บล็อก " .. kind .. " · สะสม " .. BLOCKS .. " ครั้ง")
        end
    end
    local function setAntiBan(state)
        if state == antiBanOn then return end
        antiBanOn = state
        if not state then return end
        if type(hookmetamethod) == "function" then
            pcall(function()
                local old
                old = hookmetamethod(game, "__namecall", function(self, ...)
                    if antiBanOn then
                        local m = getnamecallmethod()
                        if self == LP and (m == "Kick" or m == "kick") then
                            blocked("Kick()")
                            return nil
                        end
                        if typeof(self) == "Instance"
                            and (m == "FireServer" or m == "InvokeServer") then
                            local n = string.lower(self.Name)
                            for _, w in ipairs(BLOCK_WORDS) do
                                if string.find(n, w, 1, true) then
                                    blocked("remote:" .. self.Name)
                                    return nil
                                end
                            end
                        end
                    end
                    return old(self, ...)
                end)
            end)
        end
        if type(hookfunction) == "function" then
            pcall(function()
                local old
                old = hookfunction(LP.Kick, function(...)
                    if type(checkcaller) == "function" and checkcaller() then
                        return old(...)
                    end
                    blocked("Kick(c)")
                    return nil
                end)
            end)
        end
        task.spawn(function()
            pcall(function()
                local roots = {
                    LP:FindFirstChild("PlayerScripts"),
                    LP:FindFirstChild("PlayerGui"),
                }
                local sp = game:GetService("StarterPlayer")
                local sps = sp and sp:FindFirstChild("StarterPlayerScripts")
                if sps then table.insert(roots, sps) end
                for _, root in ipairs(roots) do
                    if root then
                        for _, sc in ipairs(root:GetDescendants()) do
                            if sc:IsA("LocalScript") then
                                local n = string.lower(sc.Name)
                                for _, w in ipairs(BLOCK_WORDS) do
                                    if string.find(n, w, 1, true) then
                                        pcall(function()
                                            sc.Disabled = true
             
