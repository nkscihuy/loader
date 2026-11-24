local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local httpRequest = request or http_request or (syn and syn.request)
if type(httpRequest) ~= "function" then
    warn("[NKS] Executor tidak menyediakan fungsi request.")
    return
end

local parent = (gethui and gethui()) or CoreGui
local old = parent:FindFirstChild("NKSKeyPrompt")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "NKSKeyPrompt"
gui.ResetOnSpawn = false
gui.Parent = parent

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(300, 150)
panel.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.fromOffset(12, 5)
title.BackgroundTransparency = 1
title.Text = "NKS — Masukkan key"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -35, 0, 5)
close.Size = UDim2.fromOffset(30, 30)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 24
close.Parent = panel

local input = Instance.new("TextBox")
input.Position = UDim2.fromOffset(12, 46)
input.Size = UDim2.new(1, -24, 0, 38)
input.BackgroundColor3 = Color3.fromRGB(44, 47, 56)
input.TextColor3 = Color3.new(1, 1, 1)
input.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
input.PlaceholderText = "License key"
input.ClearTextOnFocus = false
input.Text = ""
input.TextSize = 14
input.Font = Enum.Font.Code
input.Parent = panel

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = input

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 87)
status.Size = UDim2.new(1, -105, 0, 45)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 140, 140)
status.TextSize = 12
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.Parent = panel

local submit = Instance.new("TextButton")
submit.Position = UDim2.new(1, -90, 1, -50)
submit.Size = UDim2.fromOffset(78, 38)
submit.BackgroundColor3 = Color3.fromRGB(0, 160, 180)
submit.TextColor3 = Color3.new(1, 1, 1)
submit.Text = "Jalankan"
submit.TextSize = 13
submit.Font = Enum.Font.GothamBold
submit.Parent = panel

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 6)
submitCorner.Parent = submit

close.Activated:Connect(function()
    gui:Destroy()
end)

local busy = false
submit.Activated:Connect(function()
    if busy then return end

    local key = input.Text:match("^%s*(.-)%s*$")
    if key == "" then
        status.Text = "Masukkan key terlebih dahulu."
        return
    end

    busy = true
    submit.Text = "Memuat..."
    status.Text = ""

    local ok, response = pcall(httpRequest, {
        Url = "https://nks-loader.nks.workers.dev",
        Method = "GET",
        Headers = {
            Authorization = "Bearer " .. key,
        },
    })

    key = nil
    if not gui.Parent then return end

    if not ok or type(response) ~= "table" then
        status.Text = "Gagal menghubungi server."
    elseif response.StatusCode ~= 200 or type(response.Body) ~= "string" then
        status.Text = "Key ditolak atau server error. Status: " .. tostring(response.StatusCode)
    else
        local chunk, err = loadstring(response.Body)
        if chunk then
            input.Text = ""
            gui:Destroy()
            chunk()
            return
        end
        status.Text = "Script gagal dimuat."
        warn("[NKS] " .. tostring(err))
    end

    busy = false
    submit.Text = "Jalankan"
end)
