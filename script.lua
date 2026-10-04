-- ==========================================================
-- 🚢 Cruise Line Tycoon - Modern UI + Webhook + Anti-AFK & Anti-Ban
-- ==========================================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ระบบ Anti-AFK และ Anti-Ban แบบทำงานอัตโนมัติ
local function setupProtection()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    pcall(function()
        for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
            connection:Disable()
        end
    end)
    
    -- ป้องกันการตรวจจับเบื้องต้น (Anti-Ban Basic Hook)
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end
setupProtection()

-- สร้าง UI ดีไซน์เรียบง่าย ทันสมัย
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local UrlTextBox = Instance.new("TextBox")
local TextBoxCorner = Instance.new("UICorner")
local SaveButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local StatusLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "CruiseModernUI"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 37)
MainFrame.Position = UDim2.new(0.5, -175, 0.4, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 210)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🚢 Cruise Line Tycoon Notifier"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleLabel

CloseButton.Parent = MainFrame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 14
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UrlTextBox.Parent = MainFrame
UrlTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
UrlTextBox.Position = UDim2.new(0.1, 0, 0, 65)
UrlTextBox.Size = UDim2.new(0.8, 0, 0, 40)
UrlTextBox.Font = Enum.Font.Gotham
UrlTextBox.PlaceholderText = "วาง Discord Webhook URL ที่นี่..."
UrlTextBox.Text = ""
UrlTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UrlTextBox.TextSize = 12

TextBoxCorner.CornerRadius = UDim.new(0, 8)
TextBoxCorner.Parent = UrlTextBox

SaveButton.Parent = MainFrame
SaveButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SaveButton.Position = UDim2.new(0.1, 0, 0, 118)
SaveButton.Size = UDim2.new(0.8, 0, 0, 40)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Text = "💾 บันทึกและเริ่มทำงาน (Start)"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.TextSize = 13

ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = SaveButton

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0.1, 0, 0, 168)
StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "สถานะ: รอใส่ Webhook URL..."
StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
StatusLabel.TextSize = 12

local WEBHOOK_URL = ""
local departureMoney = 0
local lastState = "Docked"
local isRunning = false

local function getStatValue(keywords)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, key in ipairs(keywords) do
            local stat = leaderstats:FindFirstChild(key)
            if stat then return tostring(stat.Value) end
        end
    end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, v in pairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextBox") then
                for _, key in ipairs(keywords) do
                    if string.find(string.lower(v.Text), string.lower(key)) then
                        local num = string.match(v.Text, "%d+[%d%,%.]*")
                        if num then return num end
                    end
                end
            end
        end
    end
    return "0"
end

local function getCurrentStats()
    local fuel = getStatValue({"Fuel", "น้ำมัน", "Gas"})
    local elec = getStatValue({"Electricity", "Power", "Electric", "ไฟฟ้า"})
    local supplies = getStatValue({"Supplies", "Food", "Supply", "เสบียง"})
    local money = getStatValue({"Money", "Cash", "Beli", "Coins", "Dollar", "$"})
    return fuel, elec, supplies, money
end

local function sendWebhook(title, description, color, fields)
    if WEBHOOK_URL == "" then return end
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
    if not httpRequest then return end

    local payload = {
        embeds = {{
            title = title,
            description = description,
            color = color,
            fields = fields,
            footer = { text = "Cruise Line Tycoon • Modern Notifier (10 Knots Speed)" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    httpRequest({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

local function notifyDeparture()
    local fuel, elec, supplies, money = getCurrentStats()
    local cleanMoney = tonumber(string.gsub(tostring(money), "[^%d.]", "")) or 0
    departureMoney = cleanMoney

    local fields = {
        { name = "⛽ น้ำมันที่มี", value = "**" .. fuel .. "** t", inline = true },
        { name = "⚡ ไฟฟ้าที่มี", value = "**" .. elec .. "** หน่วย", inline = true },
        { name = "📦 เสบียงที่มี", value = "**" .. supplies .. "** t", inline = true },
        { name = "💰 เงินคงเหลือปัจจุบัน", value = "💵 **$" .. string.format("%'d", cleanMoney) .. "**", inline = false }
    }
    sendWebhook("🚢 [Cruise Line Tycoon] เรือกำลังออกจากท่าเรือ!", "เรือเริ่มออกเดินทาง (ความเร็วตั้งไว้ที่ 10 น็อต) สรุปทรัพยากรตอนออก:", 3447003, fields)
end

local function notifyArrival()
    local fuel, elec, supplies, currentMoney = getCurrentStats()
    local cleanMoney = tonumber(string.gsub(tostring(currentMoney), "[^%d.]", "")) or 0
    local earned = cleanMoney - departureMoney
    if earned < 0 then earned = 0 end

    local fields = {
        { name = "🎉 รายได้ที่ได้รับรอบนี้", value = "➕ **$" .. string.format("%'d", earned) .. "**", inline = false },
        { name = "⛽ น้ำมันคงเหลือ", value = "**" .. fuel .. "** t", inline = true },
        { name = "⚡ ไฟฟ้าคงเหลือ", value = "**" .. elec .. "** หน่วย", inline = true },
        { name = "📦 เสบียงคงเหลือ", value = "**" .. supplies .. "** t", inline = true },
        { name = "💰 เงินรวมปัจจุบัน", value = "💵 **$" .. string.format("%'d", cleanMoney) .. "**", inline = false }
    }
    sendWebhook("🏝 [Cruise Line Tycoon] เรือถึงจุดหมายแล้ว!", "เรือเทียบท่าเรียบร้อย สรุปกำไรและทรัพยากร:", 5763719, fields)
end

SaveButton.MouseButton1Click:Connect(function()
    local url = UrlTextBox.Text
    if string.find(url, "https://discord.com/api/webhooks/") then
        WEBHOOK_URL = url
        script.Running = true
        isRunning = true
        StatusLabel.Text = "สถานะ: ทำงานปกติ (Anti-AFK & Anti-Ban เปิดอยู่)"
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        
        sendWebhook("🟢 [System] เชื่อมต่อสำเร็จ!", "เปิดใช้งานระบบแจ้งเตือนผ่าน UI และระบบป้องกันอัตโนมัติเรียบร้อยแล้ว", 65280, {})
    else
        StatusLabel.Text = "สถานะ: URL Webhook ไม่ถูกต้อง!"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ลูปเช็กสถานะเรือและการเดินทาง (รองรับความเร็ว 10 น็อต)
task.spawn(function()
    while task.wait(5) do
        if isRunning and WEBHOOK_URL ~= "" then
            local currentState = "Docked"
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            
            if playerGui then
                for _, v in pairs(playerGui:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("TextBox") then
                        local text = string.lower(v.Text)
                        if string.find(text, "sailing") or string.find(text, "traveling") or string.find(text, "departed") then
                            currentState = "Sailing"
                            break
                        end
                    end
                end
            end

            if lastState == "Docked" and currentState == "Sailing" then
                lastState = "Sailing"
                notifyDeparture()
            elseif lastState == "Sailing" and currentState == "Docked" then
                lastState = "Docked"
                notifyArrival()
            end
        end
    end
end)
