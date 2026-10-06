--第一段

if getgenv().KL_TK_Hub_Loaded then
    return
end
getgenv().KL_TK_Hub_Loaded = true

pcall(function()
    task.spawn(function()
        pcall(function()
            game:HttpGet("https://abacus.jasoncameron.dev/hit/kl-tk-hub/rainbow_friends_loads")
        end)
    end)
end)

if getgenv().KL_TK_Connections then
    for _, c in ipairs(getgenv().KL_TK_Connections) do
        pcall(function() c:Disconnect() end)
    end
end
getgenv().KL_TK_Connections = {}

local Connections = getgenv().KL_TK_Connections
local function AddConn(c) table.insert(Connections, c) end

if getgenv().KL_TK_ESP then
    pcall(function() getgenv().KL_TK_ESP:Unload() end)
end

getgenv().KL_TK_State = {
    SpeedState = false,
    NoclipState = false,
    EspItemsOn = false,
    EspMonstersOn = false,
    EspPlayersOn = false,
    SpeedValue = 16,
    DefaultWalkSpeed = 16,
    NoclipOriginal = {},

    AutoPickupOn = false,
    AutoPickupSession = 0,

    FlightState = false,
    FlightSpeed = 50,
    FlightConn = nil,
    FlightBG = nil,
    FlightBV = nil,

    NoLightOffOn = false,
    NoLightOffColor = Color3.fromRGB(81, 81, 81),
    NoLightOffOldAmbient = nil,

    AutoVoteSkipOn = false,
    AutoBoxOn = false,
    InBox = false,
}

local State = getgenv().KL_TK_State

local repo    = "https://raw.githubusercontent.com/Q2674791739/UI/main/Obsidian/"
local ESP_URL = "https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"

local ESP          = loadstring(game:HttpGet(ESP_URL))()
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()
getgenv().KL_TK_ESP = ESP

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = false

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Lighting   = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local PLACE_IDS = {
    [8888615802]  = "RainbowFriends1",
    [1362298180]  = "RainbowFriends2",
    [7991339063]  = "MainLobby",
    [13622985049] = "Chapter1Lobby",
}

local GameType = PLACE_IDS[game.PlaceId]
if not GameType then
    GameType = Workspace:FindFirstChild("ignore") and "RainbowFriends2" or "RainbowFriends1"
end

local IsMainLobby       = (GameType == "MainLobby")
local IsChapter1Lobby   = (GameType == "Chapter1Lobby")
local IsRainbowFriends1 = (GameType == "RainbowFriends1")
local IsRainbowFriends2 = (GameType == "RainbowFriends2")

local GAME_CONFIGS = {
    RainbowFriends1 = {
        DisplayName    = "彩虹朋友第一章",
        InGame         = true,
        LoadAutoPickup = true,
        ItemNames      = (function()
            local items = { "FoodOrange", "FoodPink", "FoodGreen", "Battery" }
            for i = 1, 25 do
                table.insert(items, "Fuse" .. i)
                table.insert(items, "Block" .. i)
            end
            return items
        end)(),
        LookyFolder    = nil,
        ReturnCFrame   = CFrame.new(
            373.17746, 44.7480164, 135.617584,
            -0.997903705, 2.3134767e-08, -0.0647165775,
            2.8132078e-08, 1, -7.63071597e-08,
            0.0647165775, -7.79678047e-08, -0.997903705
        ),
    },

    RainbowFriends2 = {
        DisplayName    = "彩虹朋友第二章",
        InGame         = true,
        LoadAutoPickup = true,
        ItemNames      = { "LightBulb", "GasCanister", "CakeMix" },
        LookyFolder    = "ignore",
        ReturnCFrame   = CFrame.new(
            57.9840851, 137.597931, -8.2745142,
            -0.0595626235, -1.30958966e-07, 0.998224556,
            -5.83236304e-09, 1, 1.30843873e-07,
            -0.998224556, 1.97139616e-09, -0.0595626235
        ),
    },

    MainLobby = {
        DisplayName    = "主大厅",
        InGame         = true,
        LoadAutoPickup = false,
        ItemNames      = {},
        LookyFolder    = nil,
        ReturnCFrame   = CFrame.new(0, 0, 0),
    },

    Chapter1Lobby = {
        DisplayName    = "第一章大厅",
        InGame         = true,
        LoadAutoPickup = false,
        ItemNames      = {},
        LookyFolder    = nil,
        ReturnCFrame   = CFrame.new(0, 0, 0),
    },
}

local GameConfig      = GAME_CONFIGS[GameType] or GAME_CONFIGS.RainbowFriends1
local GameDisplayName = GameConfig.DisplayName

local ItemNameSet = {}
for _, n in ipairs(GameConfig.ItemNames) do ItemNameSet[n] = true end

local Window = Library:CreateWindow({
    Title = "KL彩虹朋友TK",
    Footer = "2674761739",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Bypass   = Window:AddTab("绕过", ""),
    ESP      = Window:AddTab("透视", ""),
    Features = Window:AddTab("传送", ""),
}

if IsMainLobby or IsChapter1Lobby then
    Tabs.Server = Window:AddTab("服务器", "")
end

Tabs.Settings = Window:AddTab("设置", "")

local function RestoreNoclip()
    for p, orig in pairs(State.NoclipOriginal) do
        if p and p.Parent then
            pcall(function() p.CanCollide = orig end)
        end
    end
    State.NoclipOriginal = {}
end

local function StopFlight()
    State.FlightState = false
    if State.FlightConn then
        pcall(function() State.FlightConn:Disconnect() end)
        State.FlightConn = nil
    end
    if State.FlightBG then
        pcall(function() State.FlightBG:Destroy() end)
        State.FlightBG = nil
    end
    if State.FlightBV then
        pcall(function() State.FlightBV:Destroy() end)
        State.FlightBV = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function CleanUp()
    State.SpeedState     = false
    State.NoclipState    = false
    State.EspItemsOn     = false
    State.EspMonstersOn  = false
    State.EspPlayersOn   = false
    State.NoLightOffOn   = false
    State.AutoVoteSkipOn = false
    State.AutoBoxOn      = false
    State.InBox          = false

    if State.NoLightOffOldAmbient then
        pcall(function()
            Lighting.Ambient = State.NoLightOffOldAmbient
        end)
        State.NoLightOffOldAmbient = nil
    end

    State.AutoPickupOn = false
    State.AutoPickupSession = (State.AutoPickupSession or 0) + 1

    StopFlight()
    RestoreNoclip()

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = State.DefaultWalkSpeed end

    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    Connections = {}
    getgenv().KL_TK_Connections = {}

    pcall(function() ESP:Unload() end)
    getgenv().KL_TK_ESP = nil

    getgenv().KL_TK_State = nil
    getgenv().KL_TK_CleanUp = nil
    getgenv().KL_TK_Hub_Loaded = nil
end

getgenv().KL_TK_CleanUp = CleanUp

if not GameConfig.InGame then
    local LobbyGroup = Tabs.Bypass:AddLeftGroupbox("大厅")

    LobbyGroup:AddLabel("当前：" .. GameDisplayName)
    LobbyGroup:AddLabel("游戏内功能（速度 / 穿墙 / 飞行 / 自动拾取）")
    LobbyGroup:AddLabel("进入游戏后自动加载")

else
    local BypassLeft = Tabs.Bypass:AddLeftGroupbox("角色")

    BypassLeft:AddToggle("SpeedToggle", {
        Text = "启用速度修改",
        Default = false,
        Tooltip = "开启时记录当前速度，关闭恢复",
    })

    BypassLeft:AddSlider("SpeedSlider", {
        Text = "玩家速度",
        Min = 0, Max = 100, Default = 16, Rounding = 0,
    })

    BypassLeft:AddDivider()

    BypassLeft:AddToggle("NoclipToggle", {
        Text = "穿墙",
        Default = false,
        Tooltip = "允许角色穿过固体物体",
    })

    BypassLeft:AddToggle("FlightToggle", {
        Text = "飞行",
        Default = false,
        Tooltip = "允许角色自由飞行",
    })

    BypassLeft:AddSlider("FlightSpeedSlider", {
        Text = "飞行速度",
        Min = 1, Max = 200, Default = 50, Rounding = 0,
    })

    BypassLeft:AddDivider()

    local NoLightToggle = BypassLeft:AddToggle("NoLightOffToggle", {
        Text = "环境光",
        Default = false,
        Tooltip = "持续调亮环境光，减少黑暗",
    })
    NoLightToggle:AddColorPicker("NoLightOffColor", {
        Text = "环境光颜色",
        Default = Color3.fromRGB(81, 81, 81),
        Transparency = 0,
    })

    local BypassRight = Tabs.Bypass:AddRightGroupbox("自动化")

    BypassRight:AddToggle("AutoVoteSkipToggle", {
        Text = "自动投票跳过",
        Default = false,
        Tooltip = "投票跳过出现时自动投一次 Yes",
    })
    Toggles.AutoVoteSkipToggle:OnChanged(function(v)
        State.AutoVoteSkipOn = v
    end)

    BypassRight:AddToggle("AutoBoxToggle", {
        Text = "自动躲避箱子",
        Default = false,
        Tooltip = "怪物追你时自动进箱子，停止追击自动出来",
    })
    Toggles.AutoBoxToggle:OnChanged(function(v)
        State.AutoBoxOn = v
    end)

    if GameConfig.LoadAutoPickup then
        BypassRight:AddToggle("AutoPickupItems", {
            Text = "自动拾取物品",
            Default = false,
            Tooltip = "循环传送到物品位置拾取，关闭时中断并传送回固定坐标",
        })
    end

    Toggles.SpeedToggle:OnChanged(function(v)
        State.SpeedState = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if v then
            State.DefaultWalkSpeed = hum.WalkSpeed
        else
            hum.WalkSpeed = State.DefaultWalkSpeed
        end
    end)

    Options.SpeedSlider:OnChanged(function(v) State.SpeedValue = v end)

    Toggles.NoclipToggle:OnChanged(function(v)
        State.NoclipState = v
        if not v then RestoreNoclip() end
    end)

    Toggles.FlightToggle:OnChanged(function(v)
        State.FlightState = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if v and char and hum and root then
            hum.PlatformStand = true

            local bg = Instance.new("BodyGyro")
            bg.P = 9e4
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = root.CFrame
            bg.Parent = root
            State.FlightBG = bg

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = root
            State.FlightBV = bv

            if State.FlightConn then State.FlightConn:Disconnect() end
            State.FlightConn = RunService.RenderStepped:Connect(function()
                if not State.FlightState then return end
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if not r or not bv or not bg then return end
                local cam = Workspace.CurrentCamera
                local speed = State.FlightSpeed or 50
                local moveVec = Vector3.zero
                pcall(function()
                    local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                    moveVec = controls:GetMoveVector()
                end)
                if moveVec.Magnitude > 0 then
                    local dir = (cam.CFrame.RightVector * moveVec.X + cam.CFrame.LookVector * -moveVec.Z).Unit
                    bv.Velocity = dir * speed
                else
                    bv.Velocity = Vector3.zero
                end
                bg.CFrame = cam.CFrame
            end)
            AddConn(State.FlightConn)
        else
            StopFlight()
        end
    end)

    Options.FlightSpeedSlider:OnChanged(function(v) State.FlightSpeed = v end)

    Toggles.NoLightOffToggle:OnChanged(function(v)
        State.NoLightOffOn = v

        if v then
            State.NoLightOffOldAmbient = Lighting.Ambient
        else
            if State.NoLightOffOldAmbient then
                Lighting.Ambient = State.NoLightOffOldAmbient
            end
        end
    end)

    Options.NoLightOffColor:OnChanged(function(v)
        State.NoLightOffColor = v
    end)

    if GameConfig.LoadAutoPickup then
        Toggles.AutoPickupItems:OnChanged(function(v)
            State.AutoPickupOn = v
            if v then
                State.AutoPickupSession = (State.AutoPickupSession or 0) + 1
                local mySession = State.AutoPickupSession

                task.spawn(function()
                    while State.AutoPickupOn and State.AutoPickupSession == mySession do
                        local c = LocalPlayer.Character
                        local h = c and c:FindFirstChild("HumanoidRootPart")
                        if not h then break end

                        local found = false

                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if not State.AutoPickupOn or State.AutoPickupSession ~= mySession then break end
                            if obj:IsA("Model") and ItemNameSet[obj.Name] and obj.PrimaryPart then
                                h.CFrame = obj.PrimaryPart.CFrame
                                task.wait(0.15)
                                h.CFrame = GameConfig.ReturnCFrame
                                found = true
                            end
                        end

                        if State.AutoPickupOn and State.AutoPickupSession == mySession and GameConfig.LookyFolder then
                            local folder = Workspace:FindFirstChild(GameConfig.LookyFolder)
                            if folder then
                                for _, obj in ipairs(folder:GetChildren()) do
                                    if not State.AutoPickupOn or State.AutoPickupSession ~= mySession then break end
                                    if obj:IsA("Model") and obj.Name == "Looky" and obj.PrimaryPart then
                                        h.CFrame = obj.PrimaryPart.CFrame
                                        task.wait(0.15)
                                        h.CFrame = GameConfig.ReturnCFrame
                                        found = true
                                    end
                                end
                            end
                        end

                        if not found then task.wait(0.3) end
                    end
                end)
            else
                State.AutoPickupSession = (State.AutoPickupSession or 0) + 1
                task.spawn(function()
                    task.wait(0.25)
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = GameConfig.ReturnCFrame
                    end
                end)
            end
        end)
    end
end

AddConn(RunService.RenderStepped:Connect(function()
    if State.SpeedState then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = State.SpeedValue end
    end
end))

AddConn(RunService.Stepped:Connect(function()
    if not State.NoclipState then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if State.NoclipOriginal[p] == nil then
                State.NoclipOriginal[p] = p.CanCollide
            end
            if p.CanCollide then p.CanCollide = false end
        end
    end
end))

AddConn(RunService.RenderStepped:Connect(function()
    if State.NoLightOffOn then
        Lighting.Ambient        = State.NoLightOffColor
        Lighting.OutdoorAmbient = State.NoLightOffColor
    end
end))
--第二段

local VirtualUser = game:GetService("VirtualUser")

AddConn(RunService.Heartbeat:Connect(function()
    if not State.AutoVoteSkipOn then return end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local permanent = pg:FindFirstChild("PermanentGUI")
    if not permanent then return end

    local vote = permanent:FindFirstChild("VoteSkip")
    if not vote or not vote.Visible then return end

    local yes = vote:FindFirstChild("Yes", true)
    if not yes or not yes.Visible then return end

    local label = yes:FindFirstChild("TextLabel", true)
    local btnText = label and label.Text or ""
    if btnText:find("已投票") or btnText:lower():find("voted") then
        return
    end

    local pos = yes.AbsolutePosition + yes.AbsoluteSize / 2

    if getconnections then
        for _, sigName in ipairs({
            "InputBegan", "InputEnded",
            "MouseButton1Click", "MouseButton1Down", "MouseButton1Up",
            "Activated", "TouchTap"
        }) do
            local sig = yes[sigName]
            if sig then
                local ok, conns = pcall(getconnections, sig)
                if ok and conns then
                    for _, conn in ipairs(conns) do
                        pcall(function()
                            if type(conn.Fire) == "function" then conn:Fire()
                            elseif type(conn.Function) == "function" then conn.Function() end
                        end)
                    end
                end
            end
        end
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(pos)
        task.wait(0.05)
        VirtualUser:Button1Up(pos)
    end)
end))

local BoxCooldown = 0

local IgnoreBoxMonsters = {
    ["Green"]  = true,
    ["Purple"] = true,
    ["Orange"] = true,
    ["Yellow"] = true,
}

local DistanceHistory = {}
local HISTORY_SIZE = 6
local MIN_SHRINK   = 0.15

local function ClickBox()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local survivor = pg and pg:FindFirstChild("SurvivorHud")
    local buttons = survivor and survivor:FindFirstChild("buttons")
    local btn = buttons and buttons:FindFirstChild("BoxButton")
    if not btn or not btn.Visible then return false end

    if not getconnections then return false end

    local fired = false
    for _, sigName in ipairs({
        "InputBegan", "InputEnded",
        "MouseButton1Click", "MouseButton1Down", "MouseButton1Up",
        "Activated", "TouchTap"
    }) do
        local sig = btn[sigName]
        if sig then
            local ok, conns = pcall(getconnections, sig)
            if ok and conns and #conns > 0 then
                for _, conn in ipairs(conns) do
                    pcall(function()
                        if type(conn.Fire) == "function" then
                            conn:Fire()
                            fired = true
                        elseif type(conn.Function) == "function" then
                            conn.Function()
                            fired = true
                        end
                    end)
                end
            end
        end
    end
    return fired
end

local function IsChasingMe(m, hrp)
    local hum = m:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return false end

    local count = 0
    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
        if t.Speed > 0.1 then count += 1 end
    end
    if count < 2 then
        DistanceHistory[m] = nil
        return false
    end

    if not m.PrimaryPart then return false end
    local d = (hrp.Position - m.PrimaryPart.Position).Magnitude

    if d > 60 then
        DistanceHistory[m] = nil
        return false
    end

    if d < 15 then
        return true
    end

    local hist = DistanceHistory[m]
    if not hist then
        hist = {}
        DistanceHistory[m] = hist
    end
    table.insert(hist, d)
    if #hist > HISTORY_SIZE then table.remove(hist, 1) end

    if #hist < HISTORY_SIZE then return false end

    local totalShrink = hist[1] - hist[#hist]
    if totalShrink < MIN_SHRINK * (#hist - 1) then return false end

    local decreases = 0
    for i = 2, #hist do
        if hist[i] < hist[i - 1] then decreases += 1 end
    end
    return decreases >= (#hist - 2)
end

local function ShouldExitBox(hrp)
    local folder = Workspace:FindFirstChild("Monsters")
    if not folder then return true end

    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") and not IgnoreBoxMonsters[m.Name] then
            local hum = m:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")

            local animCount = 0
            if animator then
                for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                    if t.Speed > 0.1 then animCount += 1 end
                end
            end

            local dist = math.huge
            if m.PrimaryPart then
                dist = (hrp.Position - m.PrimaryPart.Position).Magnitude
            end

            if animCount >= 2 or dist < 40 then
                return false
            end
        end
    end

    return true
end

AddConn(RunService.Heartbeat:Connect(function()
    if not State.AutoBoxOn then return end
    if tick() - BoxCooldown < 1 then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local folder = Workspace:FindFirstChild("Monsters")
    if not folder then return end

    local chasingMe = false
    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") and not IgnoreBoxMonsters[m.Name] then
            if IsChasingMe(m, hrp) then
                chasingMe = true
                break
            end
        end
    end

    if chasingMe and not State.InBox then
        if ClickBox() then
            State.InBox = true
            BoxCooldown = tick()
        end
    elseif not chasingMe and State.InBox then
        if ShouldExitBox(hrp) then
            if ClickBox() then
                State.InBox = false
                BoxCooldown = tick()
            end
        end
    end
end))

ESP:SetFont(Enum.Font.SourceSans)
ESP:SetTextTransparency(1)
ESP:SetShowDistance(false)
ESP:SetMatchColors(true)
ESP:SetFillTransparency(0.75)
ESP:SetOutlineTransparency(0)
ESP:SetRenderLimit(240)

local EspItemsColor    = Color3.fromRGB(0, 255, 0)
local EspMonstersColor = Color3.fromRGB(255, 0, 0)
local EspPlayersColor  = Color3.fromRGB(255, 255, 255)

local ESPTabbox    = Tabs.ESP:AddLeftTabbox("ESP")
local ESPToggleTab = ESPTabbox:AddTab("透视")
local ESPConfigTab = ESPTabbox:AddTab("设置")

ESPToggle = ESPToggleTab

ESPToggle:AddToggle("EspItemsToggle",    { Text = "物品透视", Default = false })
ESPToggle:AddToggle("EspMonstersToggle", { Text = "怪物透视", Default = false })
ESPToggle:AddToggle("EspPlayersToggle",  { Text = "玩家透视", Default = false })

ESPConfigTab:AddSlider("EspFillTransparency",    { Text = "填充透明度", Min = 0, Max = 1, Default = 0.75, Rounding = 2 })
ESPConfigTab:AddSlider("EspOutlineTransparency", { Text = "轮廓透明度", Min = 0, Max = 1, Default = 0,    Rounding = 2 })

Toggles.EspItemsToggle:OnChanged(function(v)    State.EspItemsOn = v end)
Toggles.EspMonstersToggle:OnChanged(function(v) State.EspMonstersOn = v end)
Toggles.EspPlayersToggle:OnChanged(function(v)  State.EspPlayersOn = v end)
Options.EspFillTransparency:OnChanged(function(v)    ESP:SetFillTransparency(v) end)
Options.EspOutlineTransparency:OnChanged(function(v) ESP:SetOutlineTransparency(v) end)

local function SafeAddESP(obj, color)
    if not obj then return end
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
    if ESP.ElementsEnabled[obj] then return end
    ESP:AddESP({ Object = obj, Text = "", Color = color })
end

AddConn(RunService.Heartbeat:Connect(function()
    if State.EspItemsOn then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and ItemNameSet[obj.Name] then
                SafeAddESP(obj, EspItemsColor)
            end
        end
        if GameConfig.LookyFolder then
            local folder = Workspace:FindFirstChild(GameConfig.LookyFolder)
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == "Looky" then
                        SafeAddESP(obj, EspItemsColor)
                    end
                end
            end
        end
    else
        for obj, _ in pairs(ESP.ElementsEnabled) do
            if obj and obj.Parent then
                if ItemNameSet[obj.Name] or obj.Name == "Looky" then
                    ESP:RemoveESP(obj)
                end
            end
        end
    end
end))

AddConn(RunService.Heartbeat:Connect(function()
    local folder = Workspace:FindFirstChild("Monsters")
    if not folder then return end
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") then
            if State.EspMonstersOn then
                SafeAddESP(obj, EspMonstersColor)
            elseif ESP.ElementsEnabled[obj] then
                ESP:RemoveESP(obj)
            end
        end
    end
end))

AddConn(RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            if State.EspPlayersOn then
                SafeAddESP(pl.Character, EspPlayersColor)
            elseif ESP.ElementsEnabled[pl.Character] then
                ESP:RemoveESP(pl.Character)
            end
        end
    end
end))

if IsMainLobby then
    local G = Tabs.Features:AddLeftGroupbox("主大厅")

    G:AddButton({
        Text = "传送到第一章入口",
        Tooltip = "传送到第一章播放按钮附近，自己手动点播放",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(-95.3506, 41.5980, 133.283)
            Library:Notify("已传送 | 请手动点击屏幕上的播放按钮", 3)
        end,
        DoubleClick = false,
    })

    G:AddDivider()

    G:AddButton({
        Text = "传送到加入游戏",
        Tooltip = "传送到加入游戏区域",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(-141.8161, 41.8480, 118.9807)
            Library:Notify("已传送 | 加入游戏", 3)
        end,
        DoubleClick = false,
    })

    G:AddDivider()

    G:AddButton({
        Text = "传送到孤寂之地",
        Tooltip = "传送到孤寂之地",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(-250.2633, 41.5980, 429.4426)
            Library:Notify("已传送 | 孤寂之地", 3)
        end,
        DoubleClick = false,
    })

elseif IsChapter1Lobby then
    local G = Tabs.Features:AddLeftGroupbox("第一章大厅")

    G:AddButton({
        Text = "传送到第二章入口",
        Tooltip = "传送到第二章播放按钮附近，自己手动点播放",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(349.7559, 58.2641, -1014.0363)
            Library:Notify("已传送 | 请手动点击屏幕上的播放按钮", 3)
        end,
        DoubleClick = false,
    })

elseif IsRainbowFriends1 then
    local G2 = Tabs.Features:AddRightGroupbox("第一章 - 传送")
    G2:AddButton({
        Text = "完成追逐 (Finish Chase)",
        Tooltip = "传送到追逐结束位置",
        Func = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(
                    -357.648285, 18.2980289, 623.609192,
                    0.791546643, 9.20364673e-10, -0.61110872,
                    -6.9823658e-09, 1, -7.53794449e-09,
                    0.61110872, 1.02336193e-08, 0.791546643
                )
            end
        end,
        DoubleClick = false,
    })
    G2:AddButton({
        Text = "传送到存放点",
        Tooltip = "传送到第一章存放点",
        Func = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = GameConfig.ReturnCFrame
            end
        end,
        DoubleClick = false,
    })

elseif IsRainbowFriends2 then
    local G = Tabs.Features:AddLeftGroupbox("第二章 - 点位")

    local POINTS = {
        ["跳楼机"]       = CFrame.new(152.9097, 130.6000, 12.1412),
        ["矿洞"]         = CFrame.new(228.9772, 137.5980, -35.7501),
        ["城堡王座"]     = CFrame.new(287.7671, 134.2114, 88.6063),
        ["游乐场"]       = CFrame.new(146.4681, 118.7435, -149.1116),
        ["迷雾入口"]     = CFrame.new(183.4760, 115.0980, -59.2102),
        ["滑索"]         = CFrame.new(73.1512, 135.5980, 74.2128),
        ["城堡后门"]     = CFrame.new(242.4726, 131.3050, 86.5526),
        ["城堡前门"]     = CFrame.new(194.6516, 127.6392, 25.5750),
        ["摩天轮"]       = CFrame.new(59.0865, 136.0940, 127.6592),
        ["木桥"]         = CFrame.new(158.5423, 142.9890, 77.5520),
    }

    local pointKeys = {}
    for k, _ in pairs(POINTS) do
        table.insert(pointKeys, k)
    end
    table.sort(pointKeys)

    G:AddDropdown("RF2PointSelect", {
        Values = pointKeys,
        Default = pointKeys[1],
        Text = "选择点位",
        Multi = false,
    })

    G:AddButton({
        Text = "前往所选点位",
        Tooltip = "传送到下拉框选中的点位",
        Func = function()
            local sel = Options.RF2PointSelect.Value
            local target = POINTS[sel]
            if not target then
                Library:Notify("请先选择点位", 3)
                return
            end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = target
            Library:Notify("已传送 | " .. tostring(sel), 3)
        end,
        DoubleClick = false,
    })

    local G2 = Tabs.Features:AddRightGroupbox("第二章 - 快捷")

    G2:AddButton({
        Text = "传送到存放点",
        Tooltip = "传送到第二章存放点",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = GameConfig.ReturnCFrame
            Library:Notify("已传送 | 存放点", 3)
        end,
        DoubleClick = false,
    })

    G2:AddButton({
        Text = "传送到安全屋",
        Tooltip = "传送到第二章安全屋",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(52.0137, 135.9980, -36.6328)
            Library:Notify("已传送 | 安全屋", 3)
        end,
        DoubleClick = false,
    })

    G2:AddButton({
        Text = "传送到追逐战终点",
        Tooltip = "传送到第二章追逐战终点",
        Func = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(1262.1940, -171.3022, 529.5480)
            Library:Notify("已传送 | 追逐战终点", 3)
        end,
        DoubleClick = false,
    })

else
    local G = Tabs.Features:AddLeftGroupbox("未知场景")
    G:AddLabel("当前场景未配置传送功能")
end

if IsMainLobby or IsChapter1Lobby then
    local ServerGroup = Tabs.Server:AddLeftGroupbox("服务器")

    ServerGroup:AddButton({
        Text = "传送到人少的服务器",
        Tooltip = "自动寻找并加入当前在线人数最少的服务器",
        Func = function()
            local HttpService     = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")

            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

            local ok, res = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if not ok or not res or not res.data or #res.data == 0 then
                Library:Notify("未找到可用服务器", 3)
                return
            end

            table.sort(res.data, function(a, b)
                return a.playing < b.playing
            end)

            local chosen = nil
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    chosen = s
                    break
                end
            end

            if not chosen then
                chosen = res.data[1]
            end

            if not chosen or chosen.id == game.JobId then
                Library:Notify("当前已是最少人服务器", 3)
                return
            end

            Library:Notify("正在传送 | 人数：" .. chosen.playing, 3)

            local ok2, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LocalPlayer)
            end)

            if not ok2 then
                Library:Notify("传送失败：" .. tostring(err), 4)
            end
        end,
        DoubleClick = false,
    })

    ServerGroup:AddDivider()

    ServerGroup:AddButton({
        Text = "复制当前服务器 JobId",
        Tooltip = "复制当前所在服务器的 JobId，方便分享",
        Func = function()
            local jobId = game.JobId
            if jobId and jobId ~= "" then
                if setclipboard then
                    setclipboard(jobId)
                    Library:Notify("已复制 JobId: " .. jobId, 4)
                else
                    Library:Notify("当前环境不支持 setclipboard", 4)
                end
            else
                Library:Notify("无法获取 JobId", 3)
            end
        end,
        DoubleClick = false,
    })

    local JoinGroup = Tabs.Server:AddRightGroupbox("加入指定服务器")

    JoinGroup:AddInput("JobIdInput", {
        Text = "输入服务器Id",
        Default = "",
        Numeric = false,
        Placeholder = "粘贴 JobId",
    })

    JoinGroup:AddButton({
        Text = "传送至指定服务器",
        Tooltip = "输入 JobId 后点击，传送到对应的服务器",
        Func = function()
            local jobId = Options.JobIdInput.Value
            if not jobId or jobId == "" then
                Library:Notify("请输入 JobId", 3)
                return
            end

            Library:Notify("正在传送 | " .. jobId, 3)

            local ok, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(
                    game.PlaceId, jobId, LocalPlayer
                )
            end)

            if not ok then
                Library:Notify("传送失败：" .. tostring(err), 4)
            end
        end,
        DoubleClick = false,
    })
end

local MenuGroup = Tabs.Settings:AddRightGroupbox("菜单", { PopOutEnabled = false })

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "打开快捷键",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "自定义光标",
    Default = Library.ShowCustomCursor,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI缩放",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "圆角半径",
    Default = Library.CornerRadius,
    Min = 0, Max = 20,
    Rounding = 0,
    Callback = function(value)
        Window:SetCornerRadius(value)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单绑定"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift", NoUI = true, Text = "菜单快捷键",
})

MenuGroup:AddButton("卸载", function()
    if getgenv().KL_TK_CleanUp then
        getgenv().KL_TK_CleanUp()
    end
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("KL-TK-Hub")
SaveManager:SetFolder("KL-TK-Hub/彩虹朋友")
SaveManager:SetSubFolder("Config")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library:Notify("KL彩虹朋友TK 加载成功 | 检测到 " .. GameDisplayName, 4)
SaveManager:LoadAutoloadConfig()