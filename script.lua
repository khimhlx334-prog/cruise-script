game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "FIFIA & NEWDAM",
    Text = "เทสระบบแจ้งเตือนเกมทำงานปกติ!",
    Duration = 5
})
ebhook", function(state)
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
