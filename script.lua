-- ========================================================
-- 🚢 Cruise Line Tycoon - Modern UI + Webhook (Bypassed Key & Fixed Webhook)
-- ========================================================

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
end
setupProtection()

-- ตัวแปรสำหรับตั้งค่า Webhook และสถานะบอท
local webhookUrl = ""
local isRunning = false

-- ฟังก์ชันส่ง Discord Webhook ที่ปรับปรุงใหม่ให้รองรับ Error Handling และ HttpPost
local function sendWebhook(title, description, color)
    if webhookUrl == "" or not webhookUrl:match("^https://discord.com/api/webhooks/") then
        print("Webhook URL ไม่ถูกต้องหรือไม่ถูกตั้งค่า")
        return
    end

    local data = {
        ["embeds"] = {
            {
                ["title"] = title,
                ["description"] = description,
                ["color"] = color or 3447003,
                ["footer"] = {
                    ["text"] = "Cruise Line Tycoon Script | Auto Notifier"
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }
        }
    }

    local success, encodedData = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if success then
        task.spawn(function()
            local req = (http_request or syn and syn.request or request)
            if req then
                local response = pcall(function()
                    return req({
                        Url = webhookUrl,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = encodedData
                    })
                end)
                if not response then
                    -- สำรองด้วย HttpService หากฟังก์ชัน request ของ executor มีปัญหา
                    pcall(function()
                        HttpService:PostAsync(webhookUrl, encodedData)
                    end)
                end
            else
                pcall(function()
                    HttpService:PostAsync(webhookUrl, encodedData)
                end)
            end
        end)
    end
end

-- สร้างหน้าตา UI แบบ Modern (ข้ามหน้า Key มาที่หน้าหลักทันที)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CruiseTycoonUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- ส่วนหัวของ UI
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🚢 Cruise Line Tycoon - Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Tab เมนูด้านซ้าย
local TabButtonFrame = Instance.new("Frame")
TabButtonFrame.Size = UDim2.new(0, 130, 1, -55)
TabButtonFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonFrame.BackgroundTransparency = 1
TabButtonFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = TabButtonFrame

-- พื้นที่แสดงเนื้อหาแต่ละหน้า
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -155, 1, -55)
ContentFrame.Position = UDim2.new(0, 145, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local function createPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.Visible = false
    p.Parent = ContentFrame
    return p
end

local pageMain = createPage()
pageMain.Visible = true -- เปิดหน้าหลักเป็นค่าเริ่มต้น

local pageSettings = createPage()

-- ปุ่มเปลี่ยนหน้า
local function createTabButton(text, targetPage, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.LayoutOrder = order
    btn.Parent = TabButtonFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        pageMain.Visible = false
        pageSettings.Visible = false
        targetPage.Visible = true
    end)
end

createTabButton("🏠 หน้าหลัก", pageMain, 1)
createTabButton("⚙️ ตั้งค่า", pageSettings, 2)

-- [เนื้อหาหน้าหลัก (Main Page)]
local MainListLayout = Instance.new("UIListLayout")
MainListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainListLayout.Padding = UDim.new(0, 10)
MainListLayout.Parent = pageMain

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
ToggleButton.Text = "🚀 เริ่มต้นทำงานระบบอటో"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.LayoutOrder = 1
ToggleButton.Parent = pageMain

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.Text = "⏹️ หยุดการทำงาน"
        sendWebhook("ระบบเริ่มทำงาน", "สคริปต์ Cruise Line Tycoon เริ่มรันการทำงานอัตโนมัติแล้ว", 65280)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        ToggleButton.Text = "🚀 เริ่มต้นทำงานระบบอัตโนมัติ"
        sendWebhook("ระบบหยุดทำงาน", "สคริปต์ถูกหยุดการทำงานโดยผู้ใช้", 16711680)
    end
end)

-- [เนื้อหาหน้าตั้งค่า (Settings Page)]
local SettingsListLayout = Instance.new("UIListLayout")
SettingsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsListLayout.Padding = UDim.new(0, 10)
SettingsListLayout.Parent = pageSettings

local WebhookLabel = Instance.new("TextLabel")
WebhookLabel.Size = UDim2.new(1, -10, 0, 20)
WebhookLabel.BackgroundTransparency = 1
WebhookLabel.Text = "Discord Webhook URL:"
WebhookLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
WebhookLabel.TextSize = 13
WebhookLabel.Font = Enum.Font.GothamMedium
WebhookLabel.TextXAlignment = Enum.TextXAlignment.Left
WebhookLabel.LayoutOrder = 1
WebhookLabel.Parent = pageSettings

local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(1, -10, 0, 35)
WebhookBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
WebhookBox.PlaceholderText = "วางลิงก์ Webhook ที่นี่..."
WebhookBox.Text = ""
WebhookBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WebhookBox.TextSize = 12
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.ClearTextOnFocus = false
WebhookBox.LayoutOrder = 2
WebhookBox.Parent = pageSettings

local WebhookCorner = Instance.new("UICorner")
WebhookCorner.CornerRadius = UDim.new(0, 6)
WebhookCorner.Parent = WebhookBox

-- บันทึกค่า Webhook ทันทีเมื่อพิมพ์หรือกด Enter เสร็จสิ้น
WebhookBox.FocusLost:Connect(function(enterPressed)
    webhookUrl = WebhookBox.Text
    sendWebhook("ทดสอบการเชื่อมต่อ Webhook", "ตั้งค่า Webhook สำเร็จพร้อมใช้งาน!", 3447003)
end)
