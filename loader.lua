local CoreGui = game:GetService("CoreGui")

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

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
gui.DisplayOrder = 100
gui.Parent = parent

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0, 244)
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 25)
panel.BorderSizePixel = 0
panel.Parent = gui

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(390, 244)
sizeLimit.Parent = panel

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(43, 199, 215)
border.Thickness = 1
border.Parent = panel

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.BackgroundColor3 = Color3.fromRGB(43, 199, 215)
accent.BorderSizePixel = 0
accent.Parent = panel

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(18, 14)
title.Size = UDim2.new(1, -65, 0, 26)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "NKS"
title.TextColor3 = Color3.fromRGB(225, 252, 255)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(18, 42)
subtitle.Size = UDim2.new(1, -36, 0, 20)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "KEY SYSTEM  /  CYAN STUD"
subtitle.TextColor3 = Color3.fromRGB(114, 147, 153)
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -43, 0, 10)
close.Size = UDim2.fromOffset(32, 32)
close.BackgroundColor3 = Color3.fromRGB(28, 39, 44)
close.BorderSizePixel = 0
close.Font = Enum.Font.Gotham
close.Text = "×"
close.TextColor3 = Color3.fromRGB(185, 220, 225)
close.TextSize = 22
close.Parent = panel

local label = Instance.new("TextLabel")
label.Position = UDim2.fromOffset(18, 74)
label.Size = UDim2.new(1, -36, 0, 18)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "LICENSE KEY"
label.TextColor3 = Color3.fromRGB(129, 192, 199)
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = panel

local input = Instance.new("TextBox")
input.Position = UDim2.fromOffset(18, 98)
input.Size = UDim2.new(1, -36, 0, 42)
input.BackgroundColor3 = Color3.fromRGB(25, 33, 38)
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.Font = Enum.Font.Code
input.PlaceholderText = "Masukkan license key"
input.PlaceholderColor3 = Color3.fromRGB(111, 130, 134)
input.Text = ""
input.TextColor3 = Color3.fromRGB(226, 245, 247)
input.TextSize = 14
input.TextTruncate = Enum.TextTruncate.AtEnd
input.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = input

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(52, 88, 94)
inputStroke.Parent = input

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(18, 147)
status.Size = UDim2.new(1, -36, 0, 20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Masukkan key untuk melanjutkan."
status.TextColor3 = Color3.fromRGB(142, 166, 169)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextTruncate = Enum.TextTruncate.AtEnd
status.Parent = panel

local submit = Instance.new("TextButton")
submit.Position = UDim2.new(0, 18, 1, -60)
submit.Size = UDim2.new(1, -36, 0, 42)
submit.BackgroundColor3 = Color3.fromRGB(38, 194, 210)
submit.BorderSizePixel = 0
submit.Font = Enum.Font.GothamBold
submit.Text = "EXECUTE"
submit.TextColor3 = Color3.fromRGB(10, 28, 31)
submit.TextSize = 14
submit.Parent = panel

close.Activated:Connect(function()
    gui:Destroy()
end)

local busy = false

local function submitKey()
    if busy then return end

    local key = input.Text:match("^%s*(.-)%s*$")
    if key == "" then
        status.Text = "Masukkan key terlebih dahulu."
        status.TextColor3 = Color3.fromRGB(255, 140, 140)
        return
    end

    busy = true
    submit.Text = "MEMUAT..."
    status.Text = "Menghubungi server..."
    status.TextColor3 = Color3.fromRGB(129, 192, 199)

    local ok, response = pcall(httpRequest, {
        Url = "https://nks-loader.nks.workers.dev",
        Method = "GET",
        Headers = {
            Authorization = "Bearer " .. key,
            ["X-NKS-Username"] = HttpService:UrlEncode(Players.LocalPlayer.Name),
            ["X-NKS-Display-Name"] = HttpService:UrlEncode(Players.LocalPlayer.DisplayName),
            ["X-NKS-User-Id"] = tostring(Players.LocalPlayer.UserId),
        },
    })

    if not gui.Parent then return end

    if not ok or type(response) ~= "table" then
        status.Text = "Gagal menghubungi server."
    elseif response.StatusCode ~= 200 or type(response.Body) ~= "string" then
        status.Text = "Key ditolak atau server error: " .. tostring(response.StatusCode)
    else
        local chunk, err = loadstring(response.Body)
        if chunk then
            if type(writefile) == "function" then
                pcall(writefile, "NKS_key.txt", key)
            end
            key = nil
            input.Text = ""
            gui:Destroy()
            chunk()
            return
        end
        status.Text = "Script gagal dimuat."
        warn("[NKS] " .. tostring(err))
    end

    status.TextColor3 = Color3.fromRGB(255, 140, 140)
    busy = false
    submit.Text = "EXECUTE"
end

submit.Activated:Connect(submitKey)

if type(readfile) == "function" then
    local ok, savedKey = pcall(readfile, "NKS_key.txt")
    if ok and type(savedKey) == "string" and savedKey:match("%S") then
        input.Text = savedKey
        task.defer(submitKey)
    end
end
