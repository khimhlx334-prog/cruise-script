local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ลบอันเก่าทิ้งก่อน
if PlayerGui:FindFirstChild("FNJHub_UI") then
    PlayerGui.FNJHub_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FNJHub_UI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainPlayer = MainFrame
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🍗 FIFIA&NEWDAM&JAOMONGMONG HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("UI Loaded in PlayerGui Successfully!")
= createPage()
local pageVisual = createPage()
local pageSetting = createPage()
pageNav.Visible = true

local function createTabBtn(text, targetPage, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
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
    btn.TextSize, btn.Font = 12, Enum.Font.GothamBold
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

-- ================= [TAB 4: ตั้งค่า & Webhook พร้อมปุ่ม Save/Cancel] =================
local WHLab = Instance.new("TextLabel", pageSetting)
WHLab.Size, WHLab.BackgroundTransparency, WHLab.TextSize = UDim2.new(1, -10, 0, 20), 1, 12
WHLab.Text, WHLab.TextColor3, WHLab.Font = "Discord Webhook URL:", Color3.fromRGB(200, 200, 200), Enum.Font.GothamMedium

local WHBox = Instance.new("TextBox", pageSetting)
WHBox.Size, WHBox.BackgroundColor3 = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 45)
WHBox.PlaceholderText = "วางลิงก์ Webhook..."
WHBox.Text = webhookUrl
WHBox.TextColor3, WHBox.TextSize = Color3.fromRGB(255, 255, 255), 12
Instance.new("UICorner", WHBox).CornerRadius = UDim.new(0, 6)

WHBox.Changed:Connect(function(property)
    if property == "Text" then
        tempWebhookUrl = WHBox.Text
    end
end)

-- ปุ่ม Save และ Cancel
local BtnHolder = Instance.new("Frame", pageSetting)
BtnHolder.Size = UDim2.new(1, -10, 0, 32)
BtnHolder.BackgroundTransparency = 1

local SaveBtn = Instance.new("TextButton", BtnHolder)
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SaveBtn.Text = "💾 บันทึก Webhook"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize, SaveBtn.Font = 12, Enum.Font.GothamBold
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

SaveBtn.MouseButton1Click:Connect(function()
    webhookUrl = tempWebhookUrl
    saveWebhookToFile(webhookUrl)
    SaveBtn.Text = "✅ บันทึกแล้ว!"
    task.wait(1.5)
    SaveBtn.Text = "💾 บันทึก Webhook"
end)

local CancelBtn = Instance.new("TextButton", BtnHolder)
CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
CancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
CancelBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CancelBtn.Text = "❌ ยกเลิกการแก้"
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.TextSize, CancelBtn.Font = 12, Enum.Font.GothamBold
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)

CancelBtn.MouseButton1Click:Connect(function()
    webhookUrl = loadSavedWebhook()
    WHBox.Text = webhookUrl
    tempWebhookUrl = webhookUrl
    CancelBtn.Text = "🔄 คืนค่าแล้ว"
    task.wait(1.5)
    CancelBtn.Text = "❌ ยกเลิกการแก้"
end)

createToggle(pageSetting, "เปิดใช้งานระบบส่ง Webhook", function(state)
    settings.webhookActive = state
    if state then
        sendWebhook("ระบบเชื่อมต่อสำเร็จ", "FIFIA & NEWDAM & JAOMONGMONG HUB เปิดใช้งานระบบแจ้งเตือนผ่าน Webhook แล้ว!", 65280)
    end
end)

print("FIFIA & NEWDAM & JAOMONGMONG HUB Loaded Successfully!")
มเร็วเรือ (Speed Boost)", function(state)
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
