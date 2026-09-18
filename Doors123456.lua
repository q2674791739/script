-- 第1段代码
local repo = "https://raw.githubusercontent.com/Q2674791739/UI/main/Obsidian/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
if not ReplicatedStorage:FindFirstChild("RemotesFolder") or not ReplicatedStorage:FindFirstChild("GameData") then
    Library:Notify("此脚本仅适用于 Doors 游戏", 5)
    return
end

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
ESPLibrary:SetFadeTime(0.25)

local EspObjects = {}
local ESPConnections = {}
local Main_Game = nil
local Main_Game_Loaded = false

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Connections = {}
local OldFogEnd = nil
local PlayerESP = 0

local DoorColor = Color3.new(0, 1, 1)
local ItemsColor = Color3.new(0, 1, 1)
local ObjectiveColor = Color3.new(0, 1, 1)
local TaskPointColor = Color3.new(0.2, 0.8, 1)
local GoldColor = Color3.new(1, 0.84, 0)
local ChestColor = Color3.new(0, 1, 1)
local LadderColor = Color3.new(0, 0, 1)
local PlayerColor = Color3.new(1, 1, 1)
local HidingPlaceColor = Color3.new(1, 0.3, 1)
local EntityColor = Color3.new(0.5, 0.5, 0.5)

local function RefreshToggle(toggleName)
    Toggles[toggleName]:SetValue(false)
    Toggles[toggleName]:SetValue(true)
end

local function GetCurrentRoom()
    return workspace.CurrentRooms and workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
end

local CachedPlayers = {}

local function UpdatePlayerCache()
    CachedPlayers = Players:GetPlayers()
end
table.insert(Connections, Players.PlayerAdded:Connect(UpdatePlayerCache))
table.insert(Connections, Players.PlayerRemoving:Connect(UpdatePlayerCache))
UpdatePlayerCache()

local function IsHeldByAnyPlayer(item)
    for _, player in pairs(CachedPlayers) do
        if player.Character and item:IsDescendantOf(player.Character) then
            return true
        end
        if player.Backpack and item:IsDescendantOf(player.Backpack) then
            return true
        end
    end
    return false
end
-- 第2段代码
local ESPBlacklist = {}

local function AddESP(obj, text, color)
    if table.find(ESPBlacklist, obj) then return end
    ESPLibrary:AddESP({
        Object = obj,
        Text = text,
        Color = color
    })
    if not table.find(EspObjects, obj) then
        table.insert(EspObjects, obj)
    end
end

local function RemoveESP(obj)
    ESPLibrary:RemoveESP(obj)
    for i = #EspObjects, 1, -1 do
        if EspObjects[i] == obj then
            table.remove(EspObjects, i)
        end
    end
end

local function BlacklistESP(obj)
    table.insert(ESPBlacklist, obj)
    RemoveESP(obj)
end

local function GetObjectRoom(obj)
    if not workspace.CurrentRooms then return nil end
    for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
        if obj:IsDescendantOf(room) then
            return tonumber(room.Name)
        end
    end
    return nil
end

local function AddTaskESP(obj, text, color)
    AddESP(obj, text, color)
    task.spawn(function()
        if obj.Name == "FuseObtain" then
            local hitbox = obj:WaitForChild("Hitbox", 5)
            if hitbox and hitbox:FindFirstChild("FuseModel") then
                hitbox.FuseModel:GetPropertyChangedSignal("LocalTransparencyModifier"):Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "MinesAnchor" then
            obj:GetAttributeChangedSignal("Activated"):Once(function()
                BlacklistESP(obj)
            end)
        elseif obj.Name == "MinesGenerator" then
            local lever = obj:WaitForChild("Lever", 5)
            if lever and lever:FindFirstChild("Sound") then
                lever.Sound.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "LeverForGate" then
            local main = obj:WaitForChild("Main", 5)
            if main and main:FindFirstChild("SoundToPlay") then
                main.SoundToPlay.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "TimerLever" then
            local main = obj:WaitForChild("Main", 5)
            if main and main:FindFirstChild("SoundToPlay") then
                main.SoundToPlay.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "WaterPump" then
            local wheel = obj:WaitForChild("Wheel", 5)
            if wheel and wheel:FindFirstChild("Sound") then
                wheel.Sound.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "VineGuillotine" then
            local lever = obj:WaitForChild("Lever", 5)
            if lever and lever:FindFirstChild("ActivateEventPrompt") then
                lever.ActivateEventPrompt:GetAttributeChangedSignal("Interactions"):Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "MinesGateButton" then
            local gate = obj.Parent and obj.Parent:WaitForChild("MinesGate", 5)
            if gate and gate:FindFirstChild("Main") and gate.Main:FindFirstChild("SoundOpen") then
                gate.Main.SoundOpen.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        elseif obj.Name == "GardenGateButton" then
            local gate = obj.Parent and obj.Parent:WaitForChild("GardenGate", 5)
            if gate and gate:FindFirstChild("Collision") and gate.Collision:FindFirstChild("Sound") then
                gate.Collision.Sound.Played:Once(function()
                    BlacklistESP(obj)
                end)
            end
        end
    end)
end
-- 第2段代码(续)
local function AddRoomESP(obj, text, color)
    if obj.Parent and obj.Parent.Name == "Drops" then
        AddESP(obj, text, color)
        return
    end

    local objRoom = obj:GetAttribute("ParentRoom")
    if not objRoom then
        objRoom = GetObjectRoom(obj)
        if objRoom then
            obj:SetAttribute("ParentRoom", objRoom)
        end
    end

    if not objRoom then
        AddESP(obj, text, color)
        return
    end

    if ESPConnections[obj] then
        ESPConnections[obj]:Disconnect()
        ESPConnections[obj] = nil
    end

    local function UpdateESP()
        local currentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
        local thisRoom = tonumber(obj:GetAttribute("ParentRoom"))
        if thisRoom == currentRoom then
            ESPLibrary:AddESP({ Object = obj, Text = text, Color = color })
            if not table.find(EspObjects, obj) then
                table.insert(EspObjects, obj)
            end
        else
            ESPLibrary:RemoveESP(obj)
            for i = #EspObjects, 1, -1 do
                if EspObjects[i] == obj then
                    table.remove(EspObjects, i)
                end
            end
        end
    end

    UpdateESP()

    local Conn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(UpdateESP)
    ESPConnections[obj] = Conn

    obj.Destroying:Once(function()
        if ESPConnections[obj] then
            ESPConnections[obj]:Disconnect()
            ESPConnections[obj] = nil
        end
        ESPLibrary:RemoveESP(obj)
        for i = #EspObjects, 1, -1 do
            if EspObjects[i] == obj then
                table.remove(EspObjects, i)
            end
        end
    end)
end

local function RemoveRoomESP(obj)
    if ESPConnections[obj] then
        ESPConnections[obj]:Disconnect()
        ESPConnections[obj] = nil
    end
    RemoveESP(obj)
end

local function CreateDoorHighlight(Object)
    if Object:FindFirstChild("HighlightModel") then
        return Object.HighlightModel
    end
    if Object:FindFirstChild("HighlightPart") then
        return Object.HighlightPart
    end

    local DoorParts = {}
    for _, Child in Object:GetChildren() do
        if Child.Name == "Door" and Child:IsA("BasePart") then
            table.insert(DoorParts, Child)
        end
    end

    if #DoorParts == 2 then
        local HighlightModel = Instance.new("Model", Object)
        HighlightModel.Name = "HighlightModel"
        local hum = Instance.new("Humanoid", HighlightModel)
        hum.Name = "HighlightHumanoid"

        for _, DoorPart in DoorParts do
            local HP = Instance.new("Part", HighlightModel)
            HP.Transparency = 0.999
            HP.Size = DoorPart.Size
            HP.CanCollide = false
            HP.CFrame = DoorPart.CFrame
            HP.Name = "HighlightPart"
            HP.Material = Enum.Material.Plastic
            local W = Instance.new("WeldConstraint", HP)
            W.Part0 = HP
            W.Part1 = DoorPart
            W.Enabled = true
        end
        return HighlightModel
    else
        local Root = Object:FindFirstChild("Door")
        if not Root then return nil end
        local HP = Instance.new("Part", Object)
        HP.Transparency = 0.999
        HP.Size = Root.Size
        HP.CanCollide = false
        HP.CFrame = Root.CFrame
        HP.Name = "HighlightPart"
        HP.Material = Enum.Material.Plastic
        local W = Instance.new("WeldConstraint", HP)
        W.Part0 = HP
        W.Part1 = Root
        W.Enabled = true
        local hum = Instance.new("Humanoid", Object)
        hum.Name = "HighlightHumanoid"
        return HP
    end
end

local LiveNotifications = 0
local NotificationID = 0

local function AbysallNotify(TitleText, Desc, Delay)
    task.spawn(function()
        local parent = game:GetService("CoreGui")
        if gethui then
            local ok, result = pcall(gethui)
            if ok and result then parent = result end
        end
        local Container = parent:FindFirstChild("DoorsNotifyContainer")
        if not Container then
            Container = Instance.new("ScreenGui")
            Container.Name = "DoorsNotifyContainer"
            Container.Parent = parent
            Container.DisplayOrder = 32767
            Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Container.ResetOnSpawn = false
        end

        local Notification = Instance.new("Frame")
        local Line = Instance.new("Frame")
        local Warning = Instance.new("ImageLabel")
        local UICorner = Instance.new("UICorner")
        local UICorner2 = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local Description = Instance.new("TextLabel")

        Notification.Name = "Notification"
        Notification.Parent = Container
        Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Notification.BackgroundTransparency = 0.4
        Notification.BorderSizePixel = 0
        Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * LiveNotifications))
        Notification.Size = UDim2.new(0, 420, 0, 50)

        NotificationID = NotificationID + 1
        Notification:SetAttribute("ID", NotificationID)
        Notification:SetAttribute("CurrentPosition", Notification.Position)

        Line.Name = "Line"
        Line.Parent = Notification
        Line.BackgroundColor3 = Color3.fromRGB(120, 100, 255)
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0, 0, 1, -3)
        Line.Size = UDim2.new(0, 0, 0, 3)

        Warning.Name = "Warning"
        Warning.Parent = Notification
        Warning.BackgroundTransparency = 1
        Warning.Position = UDim2.new(0, 10, 0, 5)
        Warning.Size = UDim2.new(0, 40, 0, 40)
        Warning.Image = "rbxassetid://3944668821"
        Warning.ImageColor3 = Color3.fromRGB(120, 100, 255)
        Warning.ScaleType = Enum.ScaleType.Fit

        UICorner.CornerRadius = UDim.new(0, 20)
        UICorner.Parent = Warning

        UICorner2.CornerRadius = UDim.new(0, 4)
        UICorner2.Parent = Notification

        Title.Name = "Title"
        Title.Parent = Notification
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 60, 0.155, 0)
        Title.Size = UDim2.new(0, 205, 0, 15)
        Title.Text = TitleText or "..."
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 10
        Title.TextStrokeTransparency = 0.75
        Title.TextXAlignment = Enum.TextXAlignment.Left

        Description.Name = "Description"
        Description.Parent = Notification
        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Description.BackgroundTransparency = 1
        Description.Position = UDim2.new(0, 60, 0.483, 0)
        Description.Size = UDim2.new(0, 205, 0, 18)
        Description.Text = Desc or "..."
        Description.TextColor3 = Color3.fromRGB(255, 255, 255)
   -- 第3段代码
local CommonItems = {
    ["Flashlight"] = "手电筒",
    ["Lighter"] = "打火机",
    ["Candle"] = "蜡烛",
    ["RiftCandle"] = "月光蜡烛",
    ["Vitamins"] = "维生素",
    ["Bandage"] = "绷带",
    ["BandagePack"] = "绷带包",
    ["Crucifix"] = "十字架",
    ["CrucifixWall"] = "墙上十字架",
    ["Shears"] = "剪刀",
    ["LaserPointer"] = "激光笔",
    ["Smoothie"] = "冰沙",
    ["RiftSmoothie"] = "月光冰沙",
    ["AlarmClock"] = "闹钟",
    ["TipJar"] = "小费罐",
    ["Donut"] = "甜甜圈",
    ["Battery"] = "电池",
    ["BatteryPack"] = "电池包",
    ["Candy"] = "糖果",
    ["Cheese"] = "奶酪",
    ["Bread"] = "面包",
    ["GweenSoda"] = "汽水",
    ["Straplight"] = "肩带灯",
    ["Bulklight"] = "探照灯",
    ["Shakelight"] = "手摇灯",
    ["Glowsticks"] = "荧光棒",
    ["Lantern"] = "手提灯",
    ["ShieldMini"] = "小型护盾",
    ["ShieldBig"] = "大型护盾",
    ["HolyGrenade"] = "圣光手雷",
    ["Multitool"] = "多功能工具",
    ["GlitchCub"] = "故障方块",
    ["RiftJar"] = "裂缝罐",
    ["StarJug"] = "水瓶",
    ["StarVial"] = "星光瓶",
    ["StarBottle"] = "星光桶",
    ["Scanner"] = "平板电脑",
    ["Bomb"] = "炸弹",
    ["Knockbomb"] = "敲击炸弹",
    ["BigBomb"] = "大炸弹",
    ["StopSign"] = "停车标志",
    ["SnakeBox"] = "躲藏箱",
    ["Compass"] = "指南针",
    ["Lotus"] = "莲花",
    ["LotusPetalPickup"] = "花瓣",
    ["AloeVera"] = "芦荟",
    ["Nanner"] = "香蕉",
    ["BoxingGloves"] = "拳击手套",
    ["MouseHole"] = "老鼠洞",
    ["FihFlakes"] = "鱼片",
    ["Pizza"] = "披萨",
    ["GoldGun"] = "黄金手枪",
}

local Chest = {
    ["ChestBoxLocked"] = "上锁宝箱",
    ["ChestBox"] = "宝箱",
    ["Chest_Vine"] = "藤蔓宝箱",
    ["Toolshed_Small"] = "工具棚",
    ["Toolbox"] = "工具箱",
    ["Toolbox_Locked"] = "上锁工具箱",
    ["MouseHole"] = "老鼠洞",
}

local function BuildNotifyItemsList()
    local list = {}
    for _, name in pairs(CommonItems) do
        table.insert(list, name)
    end
    return list
end
local NotifyItemsList = BuildNotifyItemsList()
-- 第4段代码
local TaskItems = {
    ["KeyObtain"] = function(obj)
        repeat task.wait() until obj.PrimaryPart
        return "钥匙"
    end,
    ["FuseObtain"] = "保险丝",
    ["LiveBreakerPolePickup"] = "断路器",
    ["LiveHintBook"] = "书本",
    ["LibraryHintPaper"] = "提示纸",
    ["ElectricalKeyObtain"] = "电气间钥匙",
}

local TaskPlaces = {
    ["MinesAnchor"] = function(obj) return "锚点 " .. obj:WaitForChild("Sign").TextLabel.Text end,
    ["LeverForGate"] = "拉杆",
    ["MinesGenerator"] = "发电机",
    ["MinesGateButton"] = "门按钮",
    ["WaterPump"] = "水泵",
    ["VineGuillotine"] = "藤蔓闸刀",
    ["TimerLever"] = "时间拉杆",
}

local HidingPlaces = {
    ["Wardrobe"] = "衣柜",
    ["Rooms_Locker"] = "储物柜",
    ["Rooms_Locker_Fridge"] = "冰箱",
    ["Locker_Large"] = "储物柜",
    ["Backdoor_Wardrobe"] = "衣柜",
    ["Bed"] = "床",
    ["Double_Bed"]  = "双人床",
    ["Toolshed"] = "工具棚",
    ["RetroWardrobe"] = "衣柜",
    ["CircularVent"] = "通风口",
}

local Entity = {
    ["RushMoving"]        = { Label = "Rush",          Global = true,  Notify = true },
    ["AmbushMoving"]      = { Label = "Ambush",        Global = true,  Notify = true },
    ["Eyes"]              = { Label = "Eyes",          Global = true,  Notify = true },
    ["Screech"]           = { Label = "Screech",       Global = true,  Notify = true },
    ["A60"]               = { Label = "A-60",          Global = true,  Notify = true },
    ["A120"]              = { Label = "A-120",         Global = true,  Notify = true },
    ["Snare"]             = { Label = "Snare",         Global = false, Notify = false },
    ["FigureRig"]         = { Label = "Figure",        Global = false, Notify = false },
    ["FigureRagdoll"]     = { Label = "Figure",        Global = false, Notify = false },
    ["DoorFake"]          = { Label = "Dupe",          Global = false, Notify = false },
    ["GlitchRush"]        = { Label = "Glitch Rush",   Global = true,  Notify = true },
    ["GlitchAmbush"]      = { Label = "Glitch Ambush", Global = true,  Notify = true },
    ["JeffTheKiller"]     = { Label = "Jeff",          Global = false, Notify = true },
    ["SallyMoving"]       = { Label = "Sally",         Global = true,  Notify = true },
    ["BackdoorRush"]      = { Label = "Blitz",         Global = true,  Notify = true },
    ["BackdoorLookman"]   = { Label = "Lookman",       Global = true,  Notify = true },
    ["Groundskeeper"]     = { Label = "Ground Keeper", Global = false, Notify = true },
    ["GrumbleRig"]        = { Label = "Grumble",       Global = false, Notify = false },
    ["MandrakeLive"]      = { Label = "Man Drake",     Global = false, Notify = false },
    ["LiveEntityBramble"] = { Label = "Bramble",       Global = false, Notify = false },
    ["MonumentEntity"]    = { Label = "Monument",      Global = false, Notify = true },
    ["CustomEntity"]      = { Label = "Custom Entity", Global = true,  Notify = true },
    ["FrozenAmbush"]      = { Label = "Frozen Ambush", Global = true,  Notify = true },
    ["GiggleCeiling"]     = { Label = "Giggle",        Global = false, Notify = true },
}

local function BuildNotifyEntitiesList()
    local list = {}
    for _, data in pairs(Entity) do
        if data.Notify and not table.find(list, data.Label) then
            table.insert(list, data.Label)
        end
    end
    return list
end

local function BuildESpEntitiesList()
    local list = {}
    for _, data in pairs(Entity) do
        if not table.find(list, data.Label) then
            table.insert(list, data.Label)
        end
    end
    return list
end

local function AddEntityESP(part, text, color)
    if part:IsA("Model") then
        local waited = 0
        while not part.PrimaryPart and waited < 1 do
            waited += task.wait()
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("BasePart") then
                    part.PrimaryPart = child
                    break
                end
            end
        end
        if not part.PrimaryPart then return end

        part.PrimaryPart.Transparency = 0.99
        if not part:FindFirstChildOfClass("Humanoid") then
            Instance.new("Humanoid", part)
        end
    end
    if part.Name == "FigureRig" or part.Name == "FigureRagdoll" then
        local rootPart = part:FindFirstChild("Root")
        if rootPart then rootPart.Size = Vector3.new(0.001, 0.001, 0.001) end
    end
    ESPLibrary:AddESP({
        Object = part,
        Text = text,
        Color = color,
    })
    if not table.find(EspObjects, part) then
        table.insert(EspObjects, part)
    end
end
-- 第5段代码
local Window = Library:CreateWindow({
	Title = "脚本名称",
	Footer = "底部文字",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab("主界面", "user"),
    Visual = Window:AddTab("视觉", "eye"),
	Settings = Window:AddTab("界面设置", "settings"),
}

local RoomAmbient = {}
local OldLightingAmbient = Lighting.Ambient
local OldLightingGlobalShadows = Lighting.GlobalShadows

if workspace.CurrentRooms then
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        local amb = room:GetAttribute("Ambient")
        if amb ~= nil then
            RoomAmbient[room] = amb
        end
    end
end

local CameraBox = Tabs.Visual:AddLeftGroupbox("相机设置")

CameraBox:AddSlider("FOV", {
    Text = "视野角度",
    Default = 70,
    Min = 10,
    Max = 120,
    Rounding = 1,
    Compact = false,
    Callback = function(Value) end,
    Tooltip = "调整游戏视野大小",
})

local FullBrightToggle = CameraBox:AddToggle("FullBright", {
    Text = "全亮",
    Default = false,
    Tooltip = "消除房间黑暗，推荐搭配浅色系",
    Callback = function(Value)
        if not Value then
            Lighting.Ambient = OldLightingAmbient
            Lighting.GlobalShadows = OldLightingGlobalShadows
            for room, oldAmb in pairs(RoomAmbient) do
                if room and room.Parent then
                    room:SetAttribute("Ambient", oldAmb)
                end
            end
        end
    end,
})
FullBrightToggle:AddColorPicker("全亮颜色", {
    Default = Color3.new(1, 1, 1),
    Title = "全亮灯光颜色",
})

CameraBox:AddDivider()

CameraBox:AddToggle("RemoveCameraShake", {
    Text = "移除相机抖动",
    Default = false,
    Tooltip = "防止相机抖动",
})

CameraBox:AddToggle("RemoveCameraBobbing", {
    Text = "移除相机摇晃",
    Default = false,
    Tooltip = "防止移动时相机摇晃",
})

CameraBox:AddToggle("NoFog", {
    Text = "消除雾气",
    Default = false,
    Tooltip = "去除地图雾效，矿井地图效果明显",
    Callback = function(Value)
        if not Value then
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("Atmosphere") then
                    obj.Density = 0.94
                end
            end
        end
        if Value then
            OldFogEnd = Lighting.FogEnd
        else
            if OldFogEnd then
                Lighting.FogEnd = OldFogEnd
                OldFogEnd = nil
            end
        end
    end,
})

CameraBox:AddDivider()

CameraBox:AddToggle("DisableHideVignette", {
    Text = "禁用躲藏暗影",
    Default = false,
    Tooltip = "禁用躲藏时的屏幕效果",
    Callback = function(Value)
        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then return end
        local MainUI = PlayerGui:FindFirstChild("MainUI")
        if not MainUI then return end
        local Vignette = MainUI:FindFirstChild("HideVignette") or (MainUI:FindFirstChild("MainFrame") and MainUI.MainFrame:FindFirstChild("HideVignette"))
        if Vignette then
            Vignette.Image = Value and "Disabled" or "rbxassetid://6100076320"
        end
    end,
})

local firedampOriginal = {}
CameraBox:AddToggle("DisableFiredampEffect", {
    Text = "禁用毒气效果",
    Default = false,
    Tooltip = "禁用毒气屏幕效果",
    Callback = function(Value)
        if not workspace.CurrentRooms then return end
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if Value then
                if firedampOriginal[room] == nil then
                    firedampOriginal[room] = room:GetAttribute("Firedamp")
                end
                room:SetAttribute("Firedamp", false)
            else
                if firedampOriginal[room] ~= nil then
                    room:SetAttribute("Firedamp", firedampOriginal[room])
                end
            end
        end
    end,
})
-- 第6段代码
local ESPTabbox = Tabs.Visual:AddRightTabbox("透视与设置")
local ESPTab = ESPTabbox:AddTab("透视")
local SettingsTab = ESPTabbox:AddTab("设置")

ESPTab:AddToggle('Door', {
    Text = "房门透视",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoomNum = LocalPlayer:GetAttribute("CurrentRoom")
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end
            local currentDoor = currentRoom:FindFirstChild("Door")
            if currentDoor then
                local Highlight = CreateDoorHighlight(currentDoor)
                if Highlight then
                    AddESP(Highlight, "门 " .. currentDoor:GetAttribute("RoomID"), DoorColor)
                end
            end
            local nextRoom = workspace.CurrentRooms and workspace.CurrentRooms[currentRoomNum + 1]
            if nextRoom then
                local nextDoor = nextRoom:FindFirstChild("Door")
                if nextDoor then
                    local Highlight = CreateDoorHighlight(nextDoor)
                    if Highlight then
                        AddESP(Highlight, "门 " .. nextDoor:GetAttribute("RoomID"), DoorColor)
                    end
                end
            end
        else
            for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
                local door = room:FindFirstChild("Door")
                if door then
                    if door:FindFirstChild("HighlightModel") then
                        RemoveESP(door.HighlightModel)
                    end
                    if door:FindFirstChild("HighlightPart") then
                        RemoveESP(door.HighlightPart)
                    end
                end
            end
        end
    end
}):AddColorPicker("房门颜色", {
		Default = DoorColor,
		Title = "房门透视颜色",
		Callback = function(Value)
        DoorColor = Value
        RefreshToggle("Door")
		end,
	})

ESPTab:AddToggle('Currency',{
Text = "货币透视",
Default = false,
Callback = function(Value)
if Value then
    local currentRoom = GetCurrentRoom()
    if not currentRoom then return end
    for _, child in pairs(currentRoom:GetDescendants()) do
        if child.Name == "GoldPile" then
            AddESP(child, "金币 " .. child:GetAttribute("GoldValue"), GoldColor)
        elseif child.Name == "StardustPickup" and child:IsA("Model") then
            AddESP(child, "星尘", GoldColor)
        end
    end
else
    for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
        if child.Name == "GoldPile" or child.Name == "StardustPickup" then
            RemoveESP(child)
        end
    end
end
end
}):AddColorPicker("货币颜色", {
		Default = GoldColor,
		Title = "货币透视颜色",
		Callback = function(Value)
GoldColor = Value
RefreshToggle("Currency")
		end,
	})
-- 第7段代码
local notifyItemsDefault = NotifyItemsList
SettingsTab:AddDropdown("ItemsNotifyDropdown", {
    Values = NotifyItemsList,
    Default = notifyItemsDefault,
    Multi = true,
    Text = "选择要通知的物品",
})
Options.ItemsNotifyDropdown:OnChanged(function(Value)
    NotifyItems = {}
    for displayName, _ in pairs(Value) do
        for itemName, itemDisplay in pairs(CommonItems) do
            if itemDisplay == displayName then
                NotifyItems[itemName] = true
                break
            end
        end
    end
end)
Options.ItemsNotifyDropdown:SetValue(notifyItemsDefault)

SettingsTab:AddToggle("ItemsNotifyToggle", {
    Text = "开启物品通知",
    Default = false,
    Callback = function(Value)
        NotifyItemsEnabled = Value
        if Value then
            for _, child in ipairs(workspace:GetDescendants()) do
                if child:IsA("Model")
                    and CommonItems[child.Name]
                    and NotifyItems[child.Name]
                    and (child:FindFirstChild("Handle") or child:FindFirstChild("Main"))
                    and not IsHeldByAnyPlayer(child)
                    and child.Parent and child.Parent.Name ~= "Drops"
                then
                    Notify(CommonItems[child.Name] .. " 已出现", 3)
                end
            end
        end
    end,
})

local notifySoundDefault = "mshax 音效"
SettingsTab:AddDropdown("SoundNotifyDropdown", {
    Values = {"mshax 音效", "Supreme 音效"},
    Default = notifySoundDefault,
    Multi = false,
    Text = "选择通知音效",
})
Options.SoundNotifyDropdown:OnChanged(function(Value)
    if Value == "mshax 音效" then
        NotifySoundId = 4590657391
    elseif Value == "Supreme 音效" then
        NotifySoundId = 101511361468852
    end
end)
Options.SoundNotifyDropdown:SetValue(notifySoundDefault)

SettingsTab:AddDropdown("NotifyStyleDropdown", {
    Values = {"Library", "Abysall"},
    Default = "Library",
    Multi = false,
    Text = "通知样式",
})
Options.NotifyStyleDropdown:OnChanged(function(Value)
    NotifyStyle = Value
end)
Options.NotifyStyleDropdown:SetValue("Library")

SettingsTab:AddToggle("SoundNotifyToggle", {
    Text = "通知音效开关",
    Default = true,
    Callback = function(Value)
        NotifySoundEnabled = Value
    end,
})

SettingsTab:AddButton("测试通知", function()
    Notify("🎵 这是一个测试通知 🎵", 3)
end)
SettingsTab:AddDivider()
SettingsTab:AddLabel("怪物通知设置", true)

local notifyEntitiesList = BuildNotifyEntitiesList()
SettingsTab:AddDropdown("EntitiesNotifyDropdown", {
    Values = notifyEntitiesList,
    Default = notifyEntitiesList,
    Multi = true,
    Text = "选择要通知的实体",
})
Options.EntitiesNotifyDropdown:SetValue(notifyEntitiesList)
-- 第8段代码
SettingsTab:AddToggle("EntitiesNotifyToggle", {
    Text = "开启实体通知",
    Default = false,
    Callback = function(Value)
        if not Value then return end
        for objName, data in pairs(Entity) do
            if not data.Notify then continue end
            if not Options.EntitiesNotifyDropdown.Value[data.Label] then continue end
            if workspace:FindFirstChild(objName) then
                Notify(data.Label .. " 已出现", 5)
            end
        end
    end,
})

ESPTab:AddToggle('Ladder', {
    Text = "梯子透视",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end
            for _, child in pairs(currentRoom:GetDescendants()) do
                if child.Name == "Ladder" then
                    AddESP(child, "梯子", LadderColor)
                end
            end
        else
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if child.Name == "Ladder" then
                    RemoveESP(child)
                end
            end
        end
    end
}):AddColorPicker("梯子颜色", {
    Default = LadderColor,
    Title = "梯子透视颜色",
    Callback = function(Value)
        LadderColor = Value
        RefreshToggle("Ladder")
    end,
})

ESPTab:AddToggle('Chest', {
    Text = "箱子透视",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end
            for _, child in pairs(currentRoom:GetDescendants()) do
                if Chest[child.Name] then
                    local target = child
                    if child:IsA("BasePart") and child.Parent and child.Parent:IsA("Model") then
                        target = child.Parent
                    end
                    if target and Chest[target.Name] then
                        AddESP(target, Chest[target.Name], ChestColor)
                    end
                end
            end
        else
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if Chest[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end
}):AddColorPicker("箱子颜色", {
    Default = ChestColor,
    Title = "箱子透视颜色",
    Callback = function(Value)
        ChestColor = Value
        RefreshToggle("Chest")
    end,
})
-- 第9段代码
ESPTab:AddToggle('TaskPoint',{
    Text = "任务点",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end
            for _, child in pairs(currentRoom:GetDescendants()) do
                local entry = TaskPlaces[child.Name]
                if entry then
                    local text = type(entry) == "function" and entry(child) or entry
                    AddTaskESP(child, text, TaskPointColor)
                end
            end
        else
            for _, child in pairs(workspace:GetDescendants()) do
                if TaskPlaces[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end
}):AddColorPicker("任务点颜色", {
    Default = TaskPointColor,
    Title = "任务点ESP颜色",
    Callback = function(Value)
        TaskPointColor = Value
        RefreshToggle("TaskPoint")
    end,
})

ESPTab:AddToggle('Common', {
    Text = "普通道具透视",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if CommonItems[child.Name]
                    and child:IsA("Model")
                    and (child:FindFirstChild("Handle") or child:FindFirstChild("Main"))
                    and not IsHeldByAnyPlayer(child)
                then
                    AddRoomESP(child, CommonItems[child.Name], ItemsColor)
                end
            end

            local dropsFolder = workspace:FindFirstChild("Drops")
            if dropsFolder then
                for _, child in pairs(dropsFolder:GetChildren()) do
                    if CommonItems[child.Name]
                        and child:IsA("Model")
                        and (child:FindFirstChild("Handle") or child:FindFirstChild("Main"))
                        and not IsHeldByAnyPlayer(child)
                    then
                        AddESP(child, CommonItems[child.Name], ItemsColor)
                    end
                end
            end
        else
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if CommonItems[child.Name] then
                    RemoveRoomESP(child)
                end
            end
            local dropsFolder = workspace:FindFirstChild("Drops")
            if dropsFolder then
                for _, child in pairs(dropsFolder:GetChildren()) do
                    if CommonItems[child.Name] then
                        RemoveRoomESP(child)
                    end
                end
            end
        end
    end
}):AddColorPicker("普通道具颜色", {
    Default = ItemsColor,
    Title = "普通道具透视颜色",
    Callback = function(Value)
        ItemsColor = Value
        RefreshToggle("Common")
    end,
})
-- 第10段代码
ESPTab:AddToggle('Objective',{
    Text = "特殊物品透视",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end
            for _, child in pairs(currentRoom:GetDescendants()) do
                local special = TaskItems[child.Name]
                if special then
                    if not IsHeldByAnyPlayer(child) then
                        local text = type(special) == "function" and special(child) or special
                        AddTaskESP(child, text, ObjectiveColor)
                    end
                end
            end
        else
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if TaskItems[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end
}):AddColorPicker("特殊物品颜色", {
    Default = ObjectiveColor,
    Title = "特殊物品透视颜色",
    Callback = function(Value)
        ObjectiveColor = Value
        RefreshToggle("Objective")
    end,
})
ESPTab:AddToggle('HidingPlace',{
Text = "躲藏点透视",
Default = false,
Callback = function(Value)
if Value then
    local currentRoom = GetCurrentRoom()
    if not currentRoom then return end
    for _, child in pairs(currentRoom:GetDescendants()) do
        local hidingLabel = HidingPlaces[child.Name]
        if hidingLabel then
            local targetPart = child
            if child:IsA("Model") and child.Name == "CircularVent" then
                targetPart = child:FindFirstChild("Grate")
            end
            if targetPart then
                AddESP(targetPart, hidingLabel, HidingPlaceColor)
            end
        end
    end
else
    for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
        local hidingLabel = HidingPlaces[child.Name]
        if hidingLabel then
            if child:IsA("Model") and child.Name == "CircularVent" then
                local grate = child:FindFirstChild("Grate")
                if grate then RemoveESP(grate) end
            else
                RemoveESP(child)
            end
        end
    end
end
end
}):AddColorPicker("躲藏点颜色", {
		Default = HidingPlaceColor,
		Title = "躲藏点透视颜色",
		Callback = function(Value)
HidingPlaceColor = Value
RefreshToggle("HidingPlace")
		end,
	})
-- 第11段代码
ESPTab:AddToggle('Player', {
    Text = "玩家透视",
    Default = false,
    Callback = function(Value)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                RemoveESP(player.Character)
                if Value then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        AddESP(player.Character, player.Name .. " [" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%]", PlayerColor)
                    end
                end
            end
        end
    end
}):AddColorPicker("玩家颜色", {
    Default = PlayerColor,
    Title = "玩家透视颜色",
    Callback = function(Value)
        PlayerColor = Value
        RefreshToggle("Player")
    end,
})

local espEntitiesList = BuildESpEntitiesList()
ESPTab:AddDropdown("EntityESPList", {
    Values = espEntitiesList,
    Default = espEntitiesList,
    Multi = true,
    Text = "选择要透视的实体",
})

ESPTab:AddToggle('Entity', {
    Text = "实体透视",
    Default = false,
    Callback = function(Value)
        if Value then
            local currentRoom = GetCurrentRoom()
            if not currentRoom then return end

            for _, child in pairs(currentRoom:GetDescendants()) do
                local data = Entity[child.Name]
                if data and not data.Global and child.Name ~= "GiggleCeiling" and Options.EntityESPList.Value[data.Label] then
                    if child.Name == "Snare" then
                        if child:FindFirstChild("Hitbox") then
                            AddEntityESP(child, data.Label, EntityColor)
                        end
                    elseif child.Name == "DoorFake" then
                        if child.Parent and child.Parent.Name == "SideroomDupe" then
                            AddEntityESP(child, data.Label, EntityColor)
                        end
                    else
                        AddEntityESP(child, data.Label, EntityColor)
                    end
                end
                if child.Name == "GiggleCeiling" and Options.EntityESPList.Value["Giggle"] then
                    task.spawn(function()
                        local t = 0
                        repeat task.wait(0.1) t = t + 0.1 until t > 2 or child:FindFirstChild("Hitbox")
                        if child:FindFirstChild("Hitbox") then
                            AddEntityESP(child, "Giggle", EntityColor)
                        end
                    end)
                end
            end

            for _, child in pairs(workspace:GetChildren()) do
                local data = Entity[child.Name]
                if data and data.Global and Options.EntityESPList.Value[data.Label] then
                    AddEntityESP(child, data.Label, EntityColor)
                end
            end
        else
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if Entity[child.Name] or child.Name == "GiggleCeiling" or child.Name == "DoorFake" then
                    RemoveESP(child)
                end
            end
            for _, child in pairs(workspace:GetChildren()) do
                if Entity[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end
}):AddColorPicker("实体颜色", {
    Default = EntityColor,
    Title = "实体透视颜色",
    Callback = function(Value)
        EntityColor = Value
        RefreshToggle("Entity")
    end,
})
-- 第12段代码
local MenuGroup = Tabs.Settings:AddRightGroupbox("菜单设置")
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "显示快捷键设置面板",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

local notificationSideDefault = "Right"
MenuGroup:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = notificationSideDefault,
    Text = "通知弹出方向",
})
Options.NotificationSide:OnChanged(function(Value)
    Library:SetNotifySide(Value)
end)
Options.NotificationSide:SetValue(notificationSideDefault)

local dpiDefault = "100%"
MenuGroup:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
    Default = dpiDefault,
    Text = "界面缩放比例",
})
Options.DPIDropdown:OnChanged(function(Value)
    Value = Value:gsub("%%", "")
    local DPI = tonumber(Value)
    Library:SetDPIScale(DPI)
end)
Options.DPIDropdown:SetValue(dpiDefault)

MenuGroup:AddSlider("UICornerSlider", {
	Text = "界面圆角大小",
	Default = 4,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单快捷键")
	:AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "呼出/隐藏菜单按键"})

MenuGroup:AddButton("卸载脚本", function()
	for _, connection in ipairs(Connections) do
		pcall(function() connection:Disconnect() end)
	end
	table.clear(Connections)

	for obj, conn in pairs(ESPConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(ESPConnections)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		pcall(function() ESPLibrary:RemoveESP(obj) end)
	end
	table.clear(EspObjects)

	pcall(function()
		if ESPLibrary.Unload then
			ESPLibrary:Unload()
		end
	end)

	task.wait(0.1)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		pcall(function() ESPLibrary:RemoveESP(obj) end)
	end

	for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
		pcall(function()
			local name = obj.Name:lower()
			if name:find("esp") or name:find("highlight") then
				obj:Destroy()
			end
		end)
	end

	if NotifyContainer then
		pcall(function() NotifyContainer:Destroy() end)
	end

	if Main_Game then
		pcall(function()
			Main_Game.fovtarget = 70
			Main_Game.csgo = CFrame.new()
			Main_Game.spring.Speed = 8
		end)
	end

	local camera = workspace.CurrentCamera
	if camera then
		pcall(function() camera.FieldOfView = 70 end)
	end

	pcall(function()
		Lighting.Ambient = OldLightingAmbient
		Lighting.GlobalShadows = OldLightingGlobalShadows
		for room, oldAmb in pairs(RoomAmbient) do
			if room and room.Parent and oldAmb then
				room:SetAttribute("Ambient", oldAmb)
			end
		end
	end)

	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
Library:Notify("脚本加载完成，透视功能已就绪", 4)
SaveManager:LoadAutoloadConfig()
-- 第13段代码
table.insert(Connections, workspace.DescendantAdded:Connect(function(child)
    if Toggles.Currency.Value and (child.Name == "GoldPile" or (child.Name == "StardustPickup" and child:IsA("Model"))) then
        local currentRoom = GetCurrentRoom()
        if currentRoom and child:IsDescendantOf(currentRoom) then
            if child.Name == "GoldPile" then
                AddESP(child, "金币 " .. child:GetAttribute("GoldValue"), GoldColor)
            else
                AddESP(child, "星尘", GoldColor)
            end
        end
    end

    if Toggles.Ladder.Value and child.Name == "Ladder" then
        local currentRoom = GetCurrentRoom()
        if currentRoom and child:IsDescendantOf(currentRoom) then
            AddESP(child, "梯子", LadderColor)
        end
    end

    if Toggles.Chest.Value and Chest[child.Name] then
        local currentRoom = GetCurrentRoom()
        if currentRoom and child:IsDescendantOf(currentRoom) then
            local target = child
            if child:IsA("BasePart") and child.Parent and child.Parent:IsA("Model") then
                target = child.Parent
            end
            if target and Chest[target.Name] then
                AddESP(target, Chest[target.Name], ChestColor)
            end
        end
    end

    if Toggles.TaskPoint.Value then
        local currentRoom = GetCurrentRoom()
        if currentRoom and child:IsDescendantOf(currentRoom) then
            local entry = TaskPlaces[child.Name]
            if entry then
                AddTaskESP(child, type(entry) == "function" and entry(child) or entry, TaskPointColor)
            end
        end
    end

    if Toggles.Common.Value
        and CommonItems[child.Name]
        and child:IsA("Model")
        and (child:FindFirstChild("Handle") or child:FindFirstChild("Main"))
        and not IsHeldByAnyPlayer(child)
    then
        AddRoomESP(child, CommonItems[child.Name], ItemsColor)
    end
end))
-- 第14段代码
table.insert(Connections, workspace.DescendantAdded:Connect(function(child)
    if Toggles.Objective.Value then
        local special = TaskItems[child.Name]
        if special then
            if not IsHeldByAnyPlayer(child) then
                local text = type(special) == "function" and special(child) or special
                AddTaskESP(child, text, ObjectiveColor)
            end
        end
    end

    if Toggles.Entity.Value then
        local currentRoom = GetCurrentRoom()
        local data = Entity[child.Name]

        if data and not data.Global and child.Name ~= "GiggleCeiling" and Options.EntityESPList.Value[data.Label] then
            if currentRoom and child:IsDescendantOf(currentRoom) then
                if (child.Name == "FigureRig" or child.Name == "FigureRagdoll") and not child:IsDescendantOf(currentRoom) then
                else
                    if child.Name == "Snare" then
                        if child:FindFirstChild("Hitbox") then
                            AddEntityESP(child, data.Label, EntityColor)
                        end
                    elseif child.Name == "DoorFake" then
                        if child.Parent and child.Parent.Name == "SideroomDupe" then
                            AddEntityESP(child, data.Label, EntityColor)
                        end
                    else
                        AddEntityESP(child, data.Label, EntityColor)
                    end
                end
            end
        end

        if child.Name == "GiggleCeiling" and Options.EntityESPList.Value["Giggle"]
            and currentRoom and child:IsDescendantOf(currentRoom)
        then
            task.spawn(function()
                local t = 0
                repeat task.wait(0.1) t = t + 0.1 until t > 2 or child:FindFirstChild("Hitbox")
                if child:FindFirstChild("Hitbox") then
                    AddEntityESP(child, "Giggle", EntityColor)
                end
            end)
        end
    end

    if child.Name == "GiggleCeiling" and Toggles.EntitiesNotifyToggle.Value
        and Options.EntitiesNotifyDropdown.Value["Giggle"]
    then
        local currentRoom = GetCurrentRoom()
        if currentRoom and child:IsDescendantOf(currentRoom) then
            task.spawn(function()
                local t = 0
                repeat task.wait(0.1) t = t + 0.1 until t > 2 or child:FindFirstChild("Hitbox")
                if child:FindFirstChild("Hitbox") then
                    Notify("Giggle 已出现", 5, "怪物出现")
                end
            end)
        end
    end

    if Toggles.HidingPlace.Value then
        local currentRoom = GetCurrentRoom()
        local hidingLabel = HidingPlaces[child.Name]
        if hidingLabel and currentRoom and child:IsDescendantOf(currentRoom) then
            local targetPart = child
            if child:IsA("Model") and child.Name == "CircularVent" then
                targetPart = child:FindFirstChild("Grate")
            end
            if targetPart then
                AddESP(targetPart, hidingLabel, HidingPlaceColor)
            end
        end
    end

    if NotifyItemsEnabled
        and CommonItems[child.Name]
        and NotifyItems[child.Name]
        and child:IsA("Model")
        and (child:FindFirstChild("Handle") or child:FindFirstChild("Main"))
        and not IsHeldByAnyPlayer(child)
        and child.Parent and child.Parent.Name ~= "Drops"
    then
        local char = LocalPlayer.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("CollisionPart"))
        if root then
            local dist = math.floor((root.Position - child:GetPivot().Position).Magnitude)
            Notify(CommonItems[child.Name] .. " 已出现", 3, "距离你 " .. dist .. " 格")
        end
    end
end))

table.insert(Connections, workspace.ChildAdded:Connect(function(EntityObj)
    if not EntityObj:IsA("Model") then return end

    if Toggles.Entity.Value then
        local data = Entity[EntityObj.Name]
        if data and data.Global and Options.EntityESPList.Value[data.Label] then
            AddEntityESP(EntityObj, data.Label, EntityColor)
        end
    end

    if not Toggles.EntitiesNotifyToggle.Value then return end

    local data = Entity[EntityObj.Name]
    if not data or not data.Notify then return end
    if not Options.EntitiesNotifyDropdown.Value[data.Label] then return end

    local waited = 0
    while not EntityObj.PrimaryPart and waited < 2 do
        waited += task.wait()
        for _, Child in pairs(EntityObj:GetChildren()) do
            if Child:IsA("BasePart") then
                EntityObj.PrimaryPart = Child
                break
            end
        end
    end
    if not EntityObj.PrimaryPart then return end
    if LocalPlayer:DistanceFromCharacter(EntityObj.PrimaryPart.Position) >= 10000 then return end

    local dist = math.floor(LocalPlayer:DistanceFromCharacter(EntityObj.PrimaryPart.Position))
    Notify(data.Label .. " 已出现", 5, "距离你 " .. dist .. " 格")
end))
-- 第15段代码
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    local currentRoomNum = LocalPlayer:GetAttribute("CurrentRoom")
    local currentRoom = GetCurrentRoom()
    if not currentRoom then return end

    if Toggles.Door.Value then
        if workspace.CurrentRooms then
            for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
                local door = room:FindFirstChild("Door")
                if door then
                    if door:FindFirstChild("HighlightModel") then
                        RemoveESP(door.HighlightModel)
                    end
                    if door:FindFirstChild("HighlightPart") then
                        RemoveESP(door.HighlightPart)
                    end
                end
            end
        end
        local currentDoor = currentRoom:FindFirstChild("Door")
        if currentDoor then
            local Highlight = CreateDoorHighlight(currentDoor)
            if Highlight then
                AddESP(Highlight, "门 " .. currentDoor:GetAttribute("RoomID"), DoorColor)
            end
        end
        local nextRoom = workspace.CurrentRooms and workspace.CurrentRooms[currentRoomNum + 1]
        if nextRoom then
            local nextDoor = nextRoom:FindFirstChild("Door")
            if nextDoor then
                local Highlight = CreateDoorHighlight(nextDoor)
                if Highlight then
                    AddESP(Highlight, "门 " .. nextDoor:GetAttribute("RoomID"), DoorColor)
                end
            end
        end
    end

    if Toggles.Currency.Value then
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if child.Name == "GoldPile" or child.Name == "StardustPickup" then
                    RemoveESP(child)
                end
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            if child.Name == "GoldPile" then
                AddESP(child, "金币 " .. child:GetAttribute("GoldValue"), GoldColor)
            elseif child.Name == "StardustPickup" and child:IsA("Model") then
                AddESP(child, "星尘", GoldColor)
            end
        end
    else
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if child.Name == "GoldPile" or child.Name == "StardustPickup" then
                    RemoveESP(child)
                end
            end
        end
    end

    if Toggles.Ladder.Value then
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if child.Name == "Ladder" then
                    RemoveESP(child)
                end
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            if child.Name == "Ladder" then
                AddESP(child, "梯子", LadderColor)
            end
        end
    else
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if child.Name == "Ladder" then
                    RemoveESP(child)
                end
            end
        end
    end

    if Toggles.Chest.Value then
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if Chest[child.Name] then
                    RemoveESP(child)
                end
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            if Chest[child.Name] then
                local target = child
                if child:IsA("BasePart") and child.Parent and child.Parent:IsA("Model") then
                    target = child.Parent
                end
                if target and Chest[target.Name] then
                    AddESP(target, Chest[target.Name], ChestColor)
                end
            end
        end
    else
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if Chest[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end

    if Toggles.TaskPoint.Value then
        for _, child in pairs(workspace:GetDescendants()) do
            if TaskPlaces[child.Name] then
                RemoveESP(child)
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            local entry = TaskPlaces[child.Name]
            if entry then
                local text = type(entry) == "function" and entry(child) or entry
                AddTaskESP(child, text, TaskPointColor)
            end
        end
    else
        for _, child in pairs(workspace:GetDescendants()) do
            if TaskPlaces[child.Name] then
                RemoveESP(child)
            end
        end
    end
-- 第16段代码
    if Toggles.Objective.Value then
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if TaskItems[child.Name] then
                    RemoveESP(child)
                end
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            local special = TaskItems[child.Name]
            if special then
                if not IsHeldByAnyPlayer(child) then
                    local text = type(special) == "function" and special(child) or special
                    AddTaskESP(child, text, ObjectiveColor)
                end
            end
        end
    else
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                if TaskItems[child.Name] then
                    RemoveESP(child)
                end
            end
        end
    end

    if Toggles.Entity.Value then
        for _, child in pairs(workspace:GetDescendants()) do
            if Entity[child.Name] or child.Name == "DoorFake" or child.Name == "Snare" or child.Name == "GiggleCeiling" then
                RemoveESP(child)
                if child.Name == "Snare" then
                    local hitbox = child:FindFirstChild("Hitbox")
                    if hitbox then RemoveESP(hitbox) end
                end
            end
        end
        for _, child in pairs(workspace:GetChildren()) do
            if Entity[child.Name] then
                RemoveESP(child)
            end
        end

        if workspace.CurrentRooms then
            for _, child in pairs(currentRoom:GetDescendants()) do
                local data = Entity[child.Name]

                if child.Name == "Snare" and child:FindFirstChild("Hitbox") then
                    if child:IsDescendantOf(currentRoom) and Options.EntityESPList.Value["Snare"] then
                        AddEntityESP(child, "Snare", EntityColor)
                    end
                end
                if child.Name == "DoorFake" and child.Parent and child.Parent.Name == "SideroomDupe" then
                    if child:IsDescendantOf(currentRoom) and Options.EntityESPList.Value["Dupe"] then
                        AddEntityESP(child, "Dupe", EntityColor)
                    end
                end
                if data and not data.Global and child.Name ~= "Snare" and child.Name ~= "DoorFake" and child.Name ~= "GiggleCeiling" then
                    if child:IsDescendantOf(currentRoom) and Options.EntityESPList.Value[data.Label] then
                        AddEntityESP(child, data.Label, EntityColor)
                    end
                end
            end
        end

        for _, child in pairs(workspace:GetChildren()) do
            local data = Entity[child.Name]
            if data and data.Global and Options.EntityESPList.Value[data.Label] then
                AddEntityESP(child, data.Label, EntityColor)
            end
        end
    else
        for _, child in pairs(workspace:GetDescendants()) do
            if Entity[child.Name] or child.Name == "DoorFake" or child.Name == "Snare" or child.Name == "GiggleCeiling" then
                RemoveESP(child)
                if child.Name == "Snare" then
                    local hitbox = child:FindFirstChild("Hitbox")
                    if hitbox then RemoveESP(hitbox) end
                end
            end
        end
        for _, child in pairs(workspace:GetChildren()) do
            if Entity[child.Name] then
                RemoveESP(child)
            end
        end
    end

    if Toggles.HidingPlace.Value then
        if workspace.CurrentRooms then
            for _, child in pairs(workspace.CurrentRooms:GetDescendants()) do
                local hidingLabel = HidingPlaces[child.Name]
                if hidingLabel then
                    if child:IsA("Model") and child.Name == "CircularVent" then
                        local grate = child:FindFirstChild("Grate")
                        if grate then RemoveESP(grate) end
                    else
                        RemoveESP(child)
                    end
                end
            end
        end
        for _, child in pairs(currentRoom:GetDescendants()) do
            local hidingLabel = HidingPlaces[child.Name]
            if hidingLabel then
                local targetPart = child
                if child:IsA("Model") and child.Name == "CircularVent" then
                    targetPart = child:FindFirstChild("Grate")
                end
                if targetPart then
                    AddESP(targetPart, hidingLabel, HidingPlaceColor)
                end
            end
        end
    end
end))
-- 第17段代码
local LastHidingSpot = nil

table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    local Camera = workspace.CurrentCamera

    if not Main_Game_Loaded then
        Main_Game_Loaded = true
        task.spawn(function()
            while not LocalPlayer.PlayerGui:FindFirstChild("MainUI") do
                task.wait()
            end
            local ok, result = pcall(function()
                return require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
            end)
            if ok then
                Main_Game = result
            end
        end)
    end

    if Main_Game then
        Main_Game.fovtarget = Options.FOV.Value

        if Toggles.RemoveCameraShake.Value then
            Main_Game.csgo = CFrame.new()
        end

        if Toggles.RemoveCameraBobbing.Value then
            Main_Game.spring.Speed = 9e9
        else
            Main_Game.spring.Speed = 8
        end
    else
        Camera.FieldOfView = Options.FOV.Value
    end

    PlayerESP = PlayerESP + 1
    if Toggles.Player.Value and PlayerESP > 1 then
        PlayerESP = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                RemoveESP(player.Character)
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    AddESP(player.Character, player.Name .. " [" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%]", PlayerColor)
                end
            end
        end
    end

    if Toggles.FullBright.Value then
        Lighting.Ambient = Options["全亮颜色"].Value
        Lighting.GlobalShadows = false
        local currentRoomIdx = LocalPlayer:GetAttribute("CurrentRoom")
        local currentRoom = workspace.CurrentRooms[currentRoomIdx]
        if currentRoom and currentRoom:GetAttribute("Ambient") then
            if RoomAmbient[currentRoom] == nil then
                RoomAmbient[currentRoom] = currentRoom:GetAttribute("Ambient")
            end
            currentRoom:SetAttribute("Ambient", Options["全亮颜色"].Value)
        end
        local nextRoomIdx = currentRoomIdx + 1
        local nextRoom = workspace.CurrentRooms[nextRoomIdx]
        if nextRoom and nextRoom:GetAttribute("Ambient") then
            if RoomAmbient[nextRoom] == nil then
                RoomAmbient[nextRoom] = nextRoom:GetAttribute("Ambient")
            end
            nextRoom:SetAttribute("Ambient", Options["全亮颜色"].Value)
        end
    end

    if Toggles.NoFog.Value then
        Lighting.FogEnd = 100000
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then
                obj.Density = 0
            end
        end
    end

    local character = LocalPlayer.Character
    if character and workspace.CurrentRooms then
        local isHiding = character:GetAttribute("Hiding") == true
        local currentSpot = nil

        if isHiding then
            local currentRoom = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
            if currentRoom then
                for _, obj in pairs(currentRoom:GetDescendants()) do
                    if obj:IsA("ObjectValue") and obj.Name == "HiddenPlayer" and obj.Value == character then
                        currentSpot = obj.Parent
                        break
                    end
                end
            end
        end

        if currentSpot ~= LastHidingSpot then
            if LastHidingSpot then
                local label = HidingPlaces[LastHidingSpot.Name]
                if label and Toggles.HidingPlace.Value then
                    local targetPart = LastHidingSpot
                    if LastHidingSpot:IsA("Model") and LastHidingSpot.Name == "CircularVent" then
                        targetPart = LastHidingSpot:FindFirstChild("Grate")
                    end
                    if targetPart then
                        AddESP(targetPart, label, HidingPlaceColor)
                    end
                end
            end

            if currentSpot then
                local targetPart = currentSpot
                if currentSpot:IsA("Model") and currentSpot.Name == "CircularVent" then
                    targetPart = currentSpot:FindFirstChild("Grate")
                end
                if targetPart then
                    RemoveESP(targetPart)
                end
            end

            LastHidingSpot = currentSpot
        end
    end
end))
 