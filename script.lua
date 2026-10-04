-- ========================================================
-- 🚢 Cruise Line Tycoon - Ultimate Hub (With Webhook Save System)
-- ========================================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ระบบ Anti-AFK
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

-- ระบบเซฟ / โหลด Webhook ผ่านไฟล์ (Workspace ของ Executor)
local webhookFileName = "CruiseTycoon_Webhook.txt"
local webhookUrl = ""

local function loadSavedWebhook()
    local success, content = pcall(function()
        if readfile and isfile and isfile(webhookFileName) then
            return readfile(webhookFileName)
        end
    end)
    if success and content then
        return content
    end
    return ""
end

local function saveWebhookToFile(url)
    pcall(function()
        if writefile then
            writefile(webhookFileName, url)
        end
    end)
end

webhookUrl = loadSavedWebhook()

-- ตัวแปรตั้งค่าและสถานะฟังก์ชัน
local settings = {
    autoPilot = false,
    selectedIsland = "เกาะ A",
    speedBoost = false,
    espShip = false,
    boostFps = false,
    webhookActive = false
}

local function sendWebhook(title, description, color)
    if not settings.webhookActive or webhookUrl == "" or not webhookUrl:match("^https://discord.com/api/webhooks/") then return end
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 3447003,
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    local success, encodedData = pcall(function() return HttpService:JSONEncode(data) end)
    if success then
        task.spawn(function()
            local req = (http_request or syn and syn.request or request)
            if req then
                pcall(function() req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = encodedData}) end)
            else
                pcall(function() HttpService:PostAsync(webhookUrl, encodedData) end)
            end
        end)
    end
end

-- สร้างหน้าต่าง UI หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CruiseTycoonUltimateUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- ส่วนหัว (Header) พร้อมปุ่มพับจอและปิด
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🚢 Cruise Line Tycoon - Pro Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- ปุ่มพับหน้าจอ (Minimize)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มปิด UI
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- คอนเทนเนอร์เนื้อหาข้างใน
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- ระบบพับหน้าจอ
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Container.Visible = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 480, 0, 40) or UDim2.new(0, 480, 0, 360)
    MinimizeBtn.Text = isMinimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab เมนูด้านซ้าย
local TabFrame = Instance.new("ScrollingFrame")
TabFrame.Size = UDim2.new(0, 130, 1, -10)
TabFrame.Position = UDim2.new(0, 10, 0, 5)
TabFrame.BackgroundTransparency = 1
TabFrame.ScrollBarThickness = 2
TabFrame.Parent = Container

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 6)
TabList.Parent = TabFrame

-- หน้าต่างเนื้อหา (Pages Container)
local PagesFrame = Instance.new("Frame")
PagesFrame.Size = UDim2.new(1, -155, 1, -10)
PagesFrame.Position = UDim2.new(0, 145, 0, 5)
PagesFrame.BackgroundTransparency = 1
PagesFrame.Parent = Container

local function createPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.Visible = false
    p.Parent = PagesFrame
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = p
    return p
end

local pageNav = createPage()
local pageShip = createPage()
local pageVisual = createPage()
local pageSetting = createPage()
pageNav.Visible = true

local function createTabBtn(text, targetPage, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.LayoutOrder = order
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        pageNav.Visible = false
        pageShip.Visible = false
        pageVisual.Visible = false
        pageSetting.Visible = false
        targetPage.Visible = true
    end)
end

createTabBtn("🧭 ขับเรือออโต้", pageNav, 1)
createTabBtn("⚡ แต่งเรือ/ความเร็ว", pageShip, 2)
createTabBtn("👁️ ภาพ & ESP", pageVisual, 3)
createTabBtn("⚙️ ตั้งค่า & Webhook", pageSetting, 4)

-- Helper สร้างปุ่มสวิตช์เปิด-ปิด (Toggle)
local function createToggle(parent, title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = title .. ": ปิด ❌"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize, btn.Font = 13, Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = title .. ": เปิด ✅"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = title .. ": ปิด ❌"
        end
        callback(active)
    end)
    return btn
end

-- ================= [TAB 1: ขับเรือออโต้ & เลือกเกาะ] =================
local IslandLabel = Instance.new("TextLabel")
IslandLabel.Size = UDim2.new(1, -10, 0, 20)
IslandLabel.BackgroundTransparency = 1
IslandLabel.Text = "เลือกเกาะปลายทาง (Auto Pilot):"
IslandLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
IslandLabel.TextSize = 12
IslandLabel.Font = Enum.Font.GothamMedium
IslandLabel.Parent = pageNav

local IslandBox = Instance.new("TextBox")
IslandBox.Size = UDim2.new(1, -10, 0, 35)
IslandBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
IslandBox.Text = "เกาะ A"
IslandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
IslandBox.TextSize, IslandBox.Font = 13, Enum.Font.Gotham
IslandBox.Parent = pageNav
Instance.new("UICorner", IslandBox).CornerRadius = UDim.new(0, 6)
IslandBox.FocusLost:Connect(function() settings.selectedIsland = IslandBox.Text end)

createToggle(pageNav, "ระบบขับเรือออโต้ (Auto Pilot & Tween)", function(state)
    settings.autoPilot = state
    task.spawn(function()
        while settings.autoPilot do
            task.wait(1)
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    print("กำลังนำเรือไปยัง: " .. settings.selectedIsland)
                end
            end)
        end
    end)
end)

-- ================= [TAB 2: ความเร็วเรือ & แต่งเรือ] =================
createToggle(pageShip, "เพิ่มความเร็วเรือ (Speed Boost)", function(state)
    settings.speedBoost = state
    task.spawn(function()
        while settings.speedBoost do
            task.wait(0.5)
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "VehicleSeat" or v.Name == "ShipSeat" then
                        if v.Occupant and v.Occupant.Parent == LocalPlayer.Character then
                            v.AssemblyLinearVelocity = v.AssemblyLinearVelocity * 1.5
                        end
                    end
                end
            end)
        end
    end)
end)

-- ================= [TAB 3: ภาพ & ESP เรือลำอื่น] =================
createToggle(pageVisual, "ESP มองเรือลำอื่น (Ship ESP)", function(state)
    settings.espShip = state
    task.spawn(function()
        while settings.espShip do
            task.wait(1)
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        if not hrp:FindFirstChild("ShipESP_Tag") then
                            local bg = Instance.new("BillboardGui", hrp)
                            bg.Name = "ShipESP_Tag"
                            bg.Size = UDim2.new(0, 100, 0, 40)
                            bg.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bg)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                            lbl.TextSize = 12
                            lbl.Font = Enum.Font.GothamBold
                            lbl.Text = "🚢 " .. p.Name
                        end
                    end
                end
            end)
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tag = p.Character.HumanoidRootPart:FindFirstChild("ShipESP_Tag")
                if tag then tag:Destroy() end
            end
        end
    end)
end)

createToggle(pageVisual, "Boost FPS (เพิ่มความลื่นไหล)", function(state)
    settings.boostFps = state
    if settings.boostFps then
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveTransparency = 1
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Boost FPS", Text = "รีสตาร์ทเกมเพื่อคืนค่ากราฟิกเดิม", Duration = 3})
    end
end)

-- ================= [TAB 4: ตั้งค่า & Webhook พร้อมระบบเซฟ] =================
local WHLab = Instance.new("TextLabel", pageSetting)
WHLab.Size, WHLab.BackgroundTransparency, WHLab.TextSize = UDim2.new(1, -10, 0, 20), 1, 12
WHLab.Text, WHLab.TextColor3, WHLab.Font = "Discord Webhook URL (บันทึกออโต้):", Color3.fromRGB(200, 200, 200), Enum.Font.GothamMedium

local WHBox = Instance.new("TextBox", pageSetting)
WHBox.Size, WHBox.BackgroundColor3 = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 45)
WHBox.PlaceholderText = "วางลิงก์ Webhook..."
WHBox.Text = webhookUrl -- โหลดค่าที่เซฟไว้มาใส่ช่องออโต้
WHBox.TextColor3, WHBox.TextSize = Color3.fromRGB(255, 255, 255), 12
Instance.new("UICorner", WHBox).CornerRadius = UDim.new(0, 6)

-- เมื่อพิมพ์เสร็จหรือกดออกช่อง จะทำการเซฟไฟล์ลงเครื่องทันที
WHBox.FocusLost:Connect(function()
    webhookUrl = WHBox.Text
    saveWebhookToFile(webhookUrl)
end)

createToggle(pageSetting, "เปิดใช้งานระบบส่ง Webhook", function(state)
    settings.webhookActive = state
    if state then
        sendWebhook("ระบบเชื่อมต่อสำเร็จ", "Cruise Line Tycoon Hub เปิดใช้งานระบบแจ้งเตือนผ่าน Webhook แล้ว!", 65280)
    end
end)

print("Cruise Line Tycoon Hub Loaded Successfully!")
