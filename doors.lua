--1
local repo = "https://raw.githubusercontent.com/q2674791739/Library/main/Obsidian/"
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
local STX = loadstring(game:HttpGet("https://raw.githubusercontent.com/q2674791739/Library/main/Abysall/STX.luau"))()

local Environment = {
    fireproximityprompt = fireproximityprompt, hookmetamethod = hookmetamethod,
    getnamecallmethod = getnamecallmethod, newcclosure = newcclosure,
    getconnections = getconnections, isnetworkowner = isnetworkowner,
    firetouchinterest = firetouchinterest, replicatesignal = replicatesignal,
    gethui = gethui or function() return game:GetService("CoreGui") end,
    require = require, cloneref = cloneref,
}
local function CheckCompat(names)
    for _, n in ipairs(names) do if not Environment[n] then return false end end
    return true
end
local function CloneReference(o) if Environment.cloneref then return Environment.cloneref(o) end return o end
local Services = setmetatable({}, { __index = function(_, n) return CloneReference(game:GetService(n)) end })

local RunService = Services.RunService
local Lighting = Services.Lighting
local LocalPlayer = Services.Players.LocalPlayer
local Players = Services.Players
local Workspace = Services.Workspace
local SoundService = Services.SoundService
local Debris = Services.Debris
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local PathfindingService = Services.PathfindingService
local Connections, Globals, Functions = {}, {}, {}
local PartProperties, CustomPhysics, ESPBlacklist, EspObjects, ESPConnections, FakePrompts = {}, nil, {}, {}, {}, {}
local Character, Humanoid, RootPart, Camera
local Collision, CollisionClone, CollisionPart, CollisionPartClone
local Main_Game, Main_Game_Loaded = nil, false
local OldJump, OldSlide
local OldLightingAmbient, OldLightingGlobalShadows = Lighting.Ambient, Lighting.GlobalShadows
local RoomAmbient, firedampOriginal = {}, {}
local LastHidingSpot, LastCrouchFire = nil, 0
local FlyBody, ManipulateBody
local Modules = {}

local Objects = {
    Prompts = {}, Objectives = {}, Doors = {}, HidingSpots = {}, Entities = {},
    SeekObstructions = {}, Items = {}, Chests = {}, Currency = {}, Ladders = {},
    Obstructions = {}, EventTriggers = {}, JumpscareModules = {}, SeekHighlights = {},
    EyestalkHighlights = {}, SeekNodes = {}, SeekDuckBoards = {}, SeekBridges = {},
    PathLights = {}, WaterParts = {},
}

Globals.IncompatibleMessage = "你的执行器不支持此功能。"
Globals.IsTyping = false
Globals.AnticheatDisabled = false
Globals.SpoofOffset = 0
Globals.SelfKilled = false
Globals.RoomsAutoWalkActive = false
Globals.LastAutoInteractFire = 0
Globals.LastAutoAnchor = 0
Globals.LastAutoHide = 0
Globals.KnobFarmActive = false
Globals.KnobFarmStarted = false
Globals.LibraryCodeFound = false
Globals.UsedRandomCodes = {}
Globals.OriginalGetMoveVector = nil
Globals.WaterNotifiedRooms = {}
local NotifyStyle = "Library"
local NotifySoundEnabled = true
local LiveNotifications, NotificationID = 0, 0

local function AbysallNotify(TitleText, Desc, Delay)
    task.spawn(function()
        local parent = Environment.gethui()
        local Container = parent:FindFirstChild("DoorsNotifyContainer")
        if not Container then
            Container = Instance.new("ScreenGui")
            Container.Name = "DoorsNotifyContainer"; Container.Parent = parent
            Container.DisplayOrder = 32767; Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Container.ResetOnSpawn = false
        end
        local N = Instance.new("Frame"); local L = Instance.new("Frame"); local W = Instance.new("ImageLabel")
        local U1, U2 = Instance.new("UICorner"), Instance.new("UICorner")
        local T, D = Instance.new("TextLabel"), Instance.new("TextLabel")
        N.Name = "Notification"; N.Parent = Container
        N.BackgroundColor3 = Color3.fromRGB(25,25,30); N.BackgroundTransparency = 0.4
        N.BorderSizePixel = 0
        N.Position = UDim2.new(1, 5, 0, 60 + 60 * LiveNotifications); N.Size = UDim2.new(0, 420, 0, 50)
        NotificationID = NotificationID + 1
        N:SetAttribute("ID", NotificationID); N:SetAttribute("CurrentPosition", N.Position)
        L.Name = "Line"; L.Parent = N; L.BackgroundColor3 = Color3.fromRGB(120,100,255)
        L.BorderSizePixel = 0; L.Position = UDim2.new(0,0,1,-3); L.Size = UDim2.new(0,0,0,3)
        W.Name = "Warning"; W.Parent = N; W.BackgroundTransparency = 1
        W.Position = UDim2.new(0,10,0,5); W.Size = UDim2.new(0,40,0,40)
        W.Image = "rbxassetid://3944668821"; W.ImageColor3 = Color3.fromRGB(120,100,255); W.ScaleType = Enum.ScaleType.Fit
        U1.CornerRadius = UDim.new(0,20); U1.Parent = W
        U2.CornerRadius = UDim.new(0,4); U2.Parent = N
        T.Name = "Title"; T.Parent = N; T.BackgroundTransparency = 1
        T.Position = UDim2.new(0,60,0.155,0); T.Size = UDim2.new(0,205,0,15)
        T.Text = TitleText or "..."; T.TextColor3 = Color3.fromRGB(255,255,255)
        T.TextSize = 10; T.TextStrokeTransparency = 0.75; T.TextXAlignment = Enum.TextXAlignment.Left
        D.Name = "Description"; D.Parent = N; D.BackgroundTransparency = 1
        D.Position = UDim2.new(0,60,0.483,0); D.Size = UDim2.new(0,205,0,18)
        D.Text = Desc or "..."; D.TextColor3 = Color3.fromRGB(255,255,255); D.TextTransparency = 0.1
        D.TextSize = 10; D.TextStrokeTransparency = 0.75; D.TextXAlignment = Enum.TextXAlignment.Left
        LiveNotifications += 1
        TweenService:Create(N, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Position = UDim2.new(1,-370,0,N.Position.Y.Offset) }):Play()
        task.wait(0.25)
        if typeof(Delay) == "Instance" then Delay.Destroying:Wait()
        else
            local rest = math.max(Delay - 0.25, 0.05)
            TweenService:Create(L, TweenInfo.new(rest, Enum.EasingStyle.Linear), { Size = UDim2.new(0,400,0,3) }):Play()
            task.wait(rest)
        end
        N:SetAttribute("Destroying", true)
        TweenService:Create(N, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
            { Position = UDim2.new(1,5,0,N.Position.Y.Offset) }):Play()
        LiveNotifications -= 1
        local myId = N:GetAttribute("ID")
        for _, obj in Container:GetChildren() do
            if obj.Name == "Notification" and obj:GetAttribute("ID") and obj:GetAttribute("ID") > myId
                and obj:GetAttribute("Destroying") ~= true and obj.Position.Y.Offset ~= 60 then
                local ny = obj:GetAttribute("CurrentPosition").Y.Offset - 60
                obj:SetAttribute("CurrentPosition", UDim2.new(1,-450,0,ny))
                TweenService:Create(obj, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(1,-370,0,ny) }):Play()
            end
        end
        task.wait(0.75); N:Destroy()
    end)
end

local function DoorsNotify(Opts)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local uic = pg:FindFirstChild("GlobalUI") or pg:FindFirstChild("MainUI")
    if not uic then return end
    local ah = uic:FindFirstChild("AchievementsHolder")
    if not ah or not ah:FindFirstChild("Achievement") then return end
    local A = ah.Achievement:Clone()
    A.Size = UDim2.new(0,0,0,0); A.Frame.Position = UDim2.new(1.1,0,0,0)
    A.Name = "LiveAchievement"; A.Visible = true
    A.Frame.TextLabel.Text = Opts.Style or "通知"
    A.Frame.Details.Title.Text = Opts.Title or "无标题"
    A.Frame.Details.Desc.Text = Opts.Description or "无描述"
    A.Frame.Details.Reason.Text = Opts.Reason or ""
    A.Frame.ImageLabel.Image = (Opts.Image and Opts.Image ~= "") and Opts.Image or "rbxassetid://6023426923"
    local c = Opts.Color or Color3.new(1,1,1)
    A.Frame.TextLabel.TextColor3 = c; A.Frame.Glow.ImageColor3 = c
    A.Parent = ah
    local s = Instance.new("Sound", ah); s.SoundId = "rbxassetid://10469938989"; s.Volume = 1
    task.spawn(function() task.wait(0.1); s:Play(); s.Ended:Wait(); s:Destroy() end)
    task.spawn(function()
        A:TweenSize(UDim2.new(1,0,0.2,0), "In", "Quad", 0.8, true); task.wait(0.8)
        A.Frame:TweenPosition(UDim2.new(0,0,0,0), "Out", "Quad", 0.5, true)
        TweenService:Create(A.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
        task.wait(Opts.Time or 5)
        A.Frame:TweenPosition(UDim2.new(1.1,0,0,0), "In", "Quad", 0.5, true); task.wait(0.5)
        A:TweenSize(UDim2.new(1,0,-0.1,0), "InOut", "Quad", 0.5, true); task.wait(0.5); A:Destroy()
    end)
end
local function Notify(a, b, c, d)
    local S
    if type(a) == "table" then S = a else S = { Title=a, Time=b, Body=c, Image=d } end
    S.Time = math.max(S.Time or 3, 0.5)
    if S.Body == "" then S.Body = nil end
    local sid = "rbxassetid://4590662766"
    if NotifyStyle == "Abysall" then sid = "rbxassetid://8784885431"; AbysallNotify(S.Title, S.Body or S.Title, S.Time)
    elseif NotifyStyle == "Doors" then sid = "rbxassetid://10469938989"
        DoorsNotify({ Title="Doors", Description=S.Title, Reason=S.Body or "", Style=S.IsEntity and "警告" or "通知",
            Color=S.IsEntity and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,222,189), Image=S.Image, Time=S.Time })
    elseif NotifyStyle == "STX" then sid = "rbxassetid://4590657391"
        STX:Notify({ Title="Doors", Description=S.Title .. (S.Body and ("\n"..S.Body) or "") },
            { OutlineColor=Color3.fromRGB(120,100,255), Time=S.Time, Type="default" })
    else Library:Notify(S.Title .. (S.Body and (" - "..S.Body) or ""), S.Time) end
    if NotifySoundEnabled then
        local s = Instance.new("Sound", SoundService); s.SoundId = sid
        s.Volume = (Options.NotifySoundVolume and Options.NotifySoundVolume.Value) or 3
        s:Play(); Debris:AddItem(s, 3)
    end
end
Functions.Notify = function(Settings)
    if not Settings.Body then Settings.Body = "..." end
    Notify({ Title=Settings.Title, Body=Settings.Body, Image=Settings.Image,
        Time=Settings.Time or 5, IsEntity=Settings.IsEntity })
end

local Entities = {
    ["RushMoving"]       = { Alias="Rush", NotifyMessage={ Title="Rush 已生成", Body="找个躲藏点" } },
    ["AmbushMoving"]     = { Alias="Ambush", NotifyMessage={ Title="Ambush 已生成", Body="找个躲藏点" } },
    ["Eyes"]             = { Alias="Eyes", NotifyMessage={ Title="Eyes 已生成", Body="不要看它" } },
    ["Lookman"]          = { Alias="Eyes", NotifyMessage={ Title="Eyes 已生成", Body="不要看它" } },
    ["BackdoorRush"]     = { Alias="Blitz", NotifyMessage={ Title="Blitz 已生成", Body="找个躲藏点" } },
    ["BackdoorLookman"]  = { Alias="Lookman", NotifyMessage={ Title="Lookman 已生成", Body="不要看它的眼睛" } },
    ["Groundskeeper"]    = { Alias="Groundskeeper", NotifyMessage={ Title="Groundskeeper 已生成", Body="不要踩到草地" } },
    ["A60"]              = { Alias="A-60", NotifyMessage={ Title="A-60 已生成", Body="找个躲藏点" } },
    ["A120"]             = { Alias="A-120", NotifyMessage={ Title="A-120 已生成", Body="找个躲藏点" } },
    ["GloombatSwarm"]    = { Alias="Gloombat Swarm", NotifyMessage={ Title="Gloombat Swarm 已生成", Body="关闭所有光源" } },
    ["GlitchRush"]       = { Alias="RNIUSHCG==", NotifyMessage={ Title="RNIUSHCG== 已生成", Body="找个躲藏点" } },
    ["GlitchAmbush"]     = { Alias="AR0xMBUSH", NotifyMessage={ Title="AR0xMBUSH 已生成", Body="找个躲藏点" } },
    ["MonumentEntity"]   = { Alias="Monument", NotifyMessage={ Title="Monument 已生成", Body="看着它时它无法移动" } },
    ["JeffTheKiller"]    = { Alias="Jeff the Killer", NotifyMessage={ Title="Jeff 已生成", Body="不要碰他" } },
    ["CustomEntity"]     = { Alias="Custom Entity", NotifyMessage={ Title="Custom Entity 已生成", Body="找个躲藏点" } },
    ["FrozenAmbush"]     = { Alias="Frozen Ambush", NotifyMessage={ Title="Frozen Ambush 已生成", Body="找个躲藏点" } },
    ["SallyMoving"]      = { Alias="Sally", NotifyMessage={ Title="Sally 已生成", Body="给她丢个物品" } },
}

local EntityIcons = {
    ["RushMoving"]="rbxassetid://10716032262", ["AmbushMoving"]="rbxassetid://10110576663",
    ["A60"]="rbxassetid://12571092295", ["A120"]="rbxassetid://12711591665",
    ["BackdoorRush"]="rbxassetid://16602023490", ["Eyes"]="rbxassetid://10183704772",
    ["Lookman"]="rbxassetid://10183704772", ["BackdoorLookman"]="rbxassetid://16764872677",
    ["GloombatSwarm"]="rbxassetid://79221203116470", ["Halt"]="rbxassetid://11331795398",
    ["JeffTheKiller"]="rbxassetid://94479432156278", ["GlitchRush"]="rbxassetid://73859273102919",
    ["GlitchAmbush"]="rbxassetid://88369678433359", ["SallyMoving"]="rbxassetid://10840888070",
    ["MonumentEntity"]="rbxassetid://88933556873017", ["Groundskeeper"]="rbxassetid://114991380115557",
    ["GiggleCeiling"]="rbxassetid://6023426923",
}

local EntityDistances = {
    ["RushMoving"]=85, ["AmbushMoving"]=150, ["A60"]=125, ["A120"]=85,
    ["GlitchRush"]=90, ["GlitchAmbush"]=175, ["BackdoorRush"]=85, ["CustomEntity"]=85,
}

local ItemNames = {
    ["Lighter"]="打火机",["Flashlight"]="手电筒",["Lockpick"]="开锁器",["Vitamins"]="维生素",
    ["Bandage"]="绷带",["StarVial"]="小星光瓶",["StarBottle"]="星光瓶",["StarJug"]="星光桶",
    ["Shakelight"]="手摇灯",["Straplight"]="绑带灯",["Bulklight"]="聚光灯",["Battery"]="电池",
    ["Candle"]="蜡烛",["Crucifix"]="十字架",["CrucifixWall"]="[十字架]",["Glowsticks"]="荧光棒",
    ["SkeletonKey"]="骷髅钥匙",["Candy"]="糖果",["ShieldMini"]="迷你护盾",["ShieldBig"]="大护盾",
    ["BandagePack"]="绷带包",["BatteryPack"]="电池包",["RiftCandle"]="月光蜡烛",["Pizza"]="披萨",
    ["LaserPointer"]="激光笔",["HolyGrenade"]="圣手榴弹",["Shears"]="剪刀",["Smoothie"]="冰沙",
    ["Cheese"]="奶酪",["Bread"]="面包",["AlarmClock"]="闹钟",["RiftSmoothie"]="月光冰沙",
    ["GweenSoda"]="绿汽水",["GlitchCube"]="故障碎片",["Scanner"]="平板",["Bomb"]="炸弹",
    ["Knockbomb"]="击退炸弹",["Nanner"]="香蕉",["BigBomb"]="大炸弹",["SnakeBox"]="躲藏箱",
    ["GoldGun"]="黄金左轮",["StopSign"]="停止标志",["TipJar"]="小费罐",["Lantern"]="灯笼",
    ["IronKey"]="铁钥匙",["LotusPetal"]="莲花瓣",["Compass"]="指南针",["LotusPetalPickup"]="莲花瓣",
    ["LanternLitItem"]="灯笼",["KeyIron"]="铁钥匙",["IronKeyForCrypt"]="铁钥匙",["LotusHolder"]="莲花瓣",
    ["Multitool"]="多功能工具",["RiftJar"]="裂隙罐",["AloeVera"]="芦荟",["Donut"]="甜甜圈",
    ["Lotus"]="莲花",["BoxingGloves"]="拳击手套",["PaperPlane"]="纸飞机",["FihFlakes"]="鱼片",
    ["SallyToyObtain"]="小黑马",["SecretCD"]="光盘",["Leftovers"]="小餐盒",["Green_Herb"]="绿色草药",
}
local HidingSpotLabels = {
    Wardrobe="衣柜",["Backdoor_Wardrobe"]="衣柜",Toolshed="衣柜",RetroWardrobe="衣柜",
    ["Wardrobe-FOOLS26"]="衣柜",Locker_Large="储物柜",Rooms_Locker="储物柜",
    Rooms_Locker_Fridge="储物柜",Bed="床",Double_Bed="双人床",CircularVent="通风口",Dumpster="垃圾箱",
}
local ChestLabels = {
    ChestBox=true,ChestBoxLocked=true,Toolbox=true,Toolbox_Locked=true,
    Chest_Vine="藤蔓箱子",Toolshed_Small="工具棚",Locker_Small_Locked="上锁物品柜",MouseHole="老鼠洞",
}
local EntityESPLabels = {
    JeffTheKiller="Jeff the Killer",GiggleCeiling="Giggle",Snare="Snare",GrumbleRig="Grumble",
    Drakobloxxer="Drakobloxxer",Hole="Mandrake Hole",Groundskeeper="Groundskeeper",
    LiveEntityBramble="Bramble",Figure="Figure",FigureRig="Figure",FigureRagdoll="Figure",
    FakeDoor="Dupe",DoorFake="Dupe",
}
local NodeEntities = {
    Rush=true,Ambush=true,Eyes=true,Blitz=true,Lookman=true,["A-60"]=true,["A-120"]=true,
    Sally=true,["Jeff The Killer"]=true,Monument=true,["AR0xMBUSH"]=true,["RNIUSHCG=="]=true,
}
local ObjectiveLabels = {
    ["KeyObtain"]="钥匙",["ElectricalKeyObtain"]="电气间钥匙",["MinesGenerator"]="发电机",
    ["FuseObtain"]="保险丝",["LiveHintBook"]="提示纸",["LiveBreakerPolePickup"]="断路器",
    ["LibraryHintPaper"]="提示纸",["PickupItem"]="提示纸",["CringlePresent"]="礼物",
    ["LeverForGate"]="拉杆",["MinesGateButton"]="门按钮",["GardenGateButton"]="门按钮",
    ["ArchivesPackageDeposit"]="箱子存放处",["SalvageChute"]="垃圾回收处",
}

local CutsceneNames = { "Figure","FigureEnd","FigureHotelEnd","FigureHotelFire","SeekIntroFools",
    "SeekIntroHotel","SeekIntroMines","SeekIntroMines2","SerewSeekDrain","SewerSeekLower",
    "GrumbleNestEnd","EyestalkIntro" }

Functions.CheckCompatability = CheckCompat
Functions.GetHiddenContainer = function() return Environment.gethui() end

Functions.GetCurrentSpeed = function()
    if not Character then return 15 end
    local s = 15
    s += Character:GetAttribute("SpeedBoost") or 0
    s += Character:GetAttribute("SpeedBoostBehind") or 0
    s += Character:GetAttribute("SpeedBoostExtra") or 0
    s += (LiveModifiers and LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
    s += (LiveModifiers and LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
    s += (LiveModifiers and LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
    s -= (LiveModifiers and LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
    if Character:GetAttribute("Crouching") then s -= 5 end
    return s
end

Functions.IsCrouching = function()
    if Floor == "Fools" or Floor == "OldHotel" then return Character:GetAttribute("Crouching") end
    return CollisionPart and CollisionPart.CollisionGroup == "PlayerCrouching"
end

Functions.GetFlyVelocity = function()
    if Humanoid.MoveDirection == Vector3.zero then return Humanoid.MoveDirection end
    local Cam = Workspace.CurrentCamera
    local lf = Vector3.new(Cam.CFrame.LookVector.X, 0, Cam.CFrame.LookVector.Z)
    local ff = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lf)
    local v = (Cam.CFrame * CFrame.new(ff:VectorToObjectSpace(Humanoid.MoveDirection))).Position - Cam.CFrame.Position
    if v == Vector3.zero then return v end
    return v.Unit
end

Functions.HasItem = function(Name, OnlyChar)
    if not OnlyChar and LocalPlayer.Backpack:FindFirstChild(Name) then return LocalPlayer.Backpack:FindFirstChild(Name) end
    if Character and Character:FindFirstChild(Name) then return Character:FindFirstChild(Name) end
end

Functions.GetMousePosition = function()
    if Library.IsMobile then return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
    local m = Services.UserInputService:GetMouseLocation()
    return Vector2.new(m.X, m.Y)
end

Functions.IsHidePersistent = function()
    return Floor == "Mines" or Floor == "Ripple" or Floor == "Party"
        or (LiveModifiers and LiveModifiers:FindFirstChild("HideLevel2") ~= nil)
end

Functions.GetPlayerFromMouse = function(TargetPart, MaxDistance)
    local Closest, ClosestDistance = nil, math.huge
    for _, Player in Services.Players:GetPlayers() do
        local Char = Player.Character
        if Char then
            local Target = Char:FindFirstChild(TargetPart)
            if Target then
                local Result = Camera:WorldToViewportPoint(Target.Position)
                local ScreenPos = Vector2.new(Result.X, Result.Y)
                local Distance = (Functions.GetMousePosition() - ScreenPos).Magnitude
                if Player.Name ~= LocalPlayer.Name and Distance < ClosestDistance and Distance < MaxDistance then
                    Closest = Target
                    ClosestDistance = Distance
                end
            end
        end
    end
    return Closest
end

Functions.FirePrompt = Environment.fireproximityprompt
Functions.ForceFirePrompt = Environment.fireproximityprompt
if not Functions.FirePrompt then
    local PromptsToFire, PromptCooldown = {}, {}
    Functions.FirePrompt = function(P)
        if not P or not P:IsA("ProximityPrompt") then return end
        if PromptCooldown[P] or table.find(PromptsToFire, P) then return end
        table.insert(PromptsToFire, P)
    end
    Functions.ForceFirePrompt = Functions.FirePrompt
    task.spawn(function()
        while task.wait() do
            local P = table.remove(PromptsToFire, 1)
            if not P then continue end
            PromptCooldown[P] = true
            local oD, oE, oP, oH, oL = P.MaxActivationDistance, P.Enabled, P.Parent, P.HoldDuration, P.RequiresLineOfSight
            P.MaxActivationDistance = 99999; P.Enabled = true; P.HoldDuration = 0; P.RequiresLineOfSight = false
            local tmp = Instance.new("Part")
            tmp.Anchored = true; tmp.CanCollide = false; tmp.CanQuery = false; tmp.CanTouch = false
            tmp.Size = Vector3.new(0.001,0.001,0.001); tmp.Transparency = 1; tmp.Parent = Workspace
            tmp.Position = Camera.CFrame:ToWorldSpace(CFrame.new(0,0,-0.1)).Position
            pcall(function() P.Parent = tmp end)
            local shown, fired = false, false
            local c1 = Services.ProximityPromptService.PromptShown:Connect(function(x) if x == P then shown = true end end)
            local c2 = P.Triggered:Connect(function() fired = true end)
            local t = 0; while not shown and t < 5 do t += 1 task.wait() end
            t = 0; while not fired and t < 5 do P:InputHoldBegin(); P:InputHoldEnd(); t += 1 task.wait() end
            P.MaxActivationDistance = oD; P.Enabled = oE; P.HoldDuration = oH; P.RequiresLineOfSight = oL
            pcall(function() P.Parent = oP end); task.wait()
            PromptCooldown[P] = nil; tmp:Destroy(); c1:Disconnect(); c2:Disconnect()
        end
    end)
end

local RemotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")
local LiveModifiers = ReplicatedStorage:FindFirstChild("LiveModifiers")
local FloorReplicated = ReplicatedStorage:FindFirstChild("FloorReplicated")
local CurrentRooms = Workspace:FindFirstChild("CurrentRooms")
local Drops = Workspace:FindFirstChild("Drops")
local GameData = ReplicatedStorage:WaitForChild("GameData")
local Floor = GameData:WaitForChild("Floor").Value
local LatestRoom = GameData:WaitForChild("LatestRoom")

if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then
    Functions.Notify({ Title = "等待游戏加载..." })
    while not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") do task.wait() end
    task.wait(3)
end
Camera = Workspace.CurrentCamera
if not RemotesFolder then
    RemotesFolder = ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks")
end
if Floor == "Hotel" and RemotesFolder and RemotesFolder.Name == "Bricks" then Floor = "OldHotel" end
if not LiveModifiers then LiveModifiers = Instance.new("Folder") end
if not FloorReplicated then FloorReplicated = Instance.new("Folder") end

local FakeEvents = {
    Screech = Instance.new("RemoteEvent"), Shade = Instance.new("RemoteEvent"),
    A90 = Instance.new("RemoteEvent"), Surge = Instance.new("RemoteEvent"),
}
FakeEvents.Screech.Name = "Screech"; FakeEvents.Shade.Name = "ShadeResult"
FakeEvents.A90.Name = "A90"; FakeEvents.Surge.Name = "SurgeRemote"
FakeEvents.Screech_Real = RemotesFolder and RemotesFolder:WaitForChild("Screech")
FakeEvents.Shade_Real = RemotesFolder and RemotesFolder:WaitForChild("ShadeResult")
FakeEvents.A90_Real = RemotesFolder and RemotesFolder:FindFirstChild("A90")
FakeEvents.Surge_Real = RemotesFolder and RemotesFolder:FindFirstChild("SurgeRemote")

Globals.SeekNodesFolder = Instance.new("Folder", Workspace)
Globals.SeekNodesFolder.Name = "SeekNodes_" .. tostring(math.random(1,1e9))
Globals.RoomsNodesFolder = Instance.new("Folder", Workspace)
Globals.RoomsNodesFolder.Name = "RoomsNodes_" .. tostring(math.random(1,1e9))

Globals.FogInstances = {}
Globals.OldFog = Lighting.FogEnd
for _, o in Lighting:GetChildren() do
    if o:IsA("Atmosphere") then
        o:SetAttribute("Density_Old", o.Density)
        local c = o:GetPropertyChangedSignal("Density"):Connect(function()
            if o.Density ~= 0 then o:SetAttribute("Density_Old", o.Density) end
            if Toggles.RemoveCameraFog and Toggles.RemoveCameraFog.Value then o.Density = 0 end
        end)
        table.insert(Connections, c); table.insert(Globals.FogInstances, o)
    end
end

Globals.PromptContainer = Instance.new("Folder")
Globals.PromptContainer.Name = "PromptContainer"
Globals.PromptContainer.Parent = Environment.gethui()
Functions.GetNearestEntity = function(CheckDisabled, List, UseRay)
    local N = { Distance = math.huge, Object = nil }
    for _, e in Objects.Entities do
        if e and EntityDistances[e.Name] and e.PrimaryPart then
            local data = Entities[e.Name]
            if not (List and data and List[data.Alias]) then
                local d = LocalPlayer:DistanceFromCharacter(e.PrimaryPart.Position)
                if d < EntityDistances[e.Name] and d < N.Distance then
                    if not CheckDisabled or e:GetAttribute("Inactive") ~= true then
                        N.Distance = d; N.Object = e
                    end
                end
            end
        end
    end
    return N.Object
end

Functions.GetNearestFigure = function()
    local N = { Distance = math.huge, Object = nil }
    for _, o in Objects.Entities do
        if o:IsA("Model") and o.PrimaryPart and (o.Name=="FigureRig" or o.Name=="Figure" or o.Name=="FigureRagdoll") then
            local d = LocalPlayer:DistanceFromCharacter(o.PrimaryPart.Position)
            if d < 25 and d < N.Distance then N.Distance = d; N.Object = o end
        end
    end
    return N.Object
end

Functions.GetNearestHidingSpot = function()
    local N = { Distance = math.huge, Object = nil }
    local Last = Character and Character:FindFirstChild("LastHideSpot")
    for _, o in Objects.HidingSpots do
        if o.PrimaryPart and o:FindFirstChild("HidePrompt") then
            local d = LocalPlayer:DistanceFromCharacter(o.PrimaryPart.Position)
            if d < o.HidePrompt.MaxActivationDistance and d < N.Distance then
                local Persistent = Functions.IsHidePersistent()
                if not Persistent or (Last and Last.Value ~= o) or not Last then
                    N.Distance = d; N.Object = o
                end
            end
        end
    end
    return N.Object
end

Functions.GetCurrentAnchor = function()
    local Hint = LocalPlayer.PlayerGui.MainUI and LocalPlayer.PlayerGui.MainUI:FindFirstChild("AnchorHintFrame")
    if not Hint then return end
    local code = Hint.AnchorCode.Text
    for _, o in Objects.Objectives do
        if o.Name == "MinesAnchor" and o:FindFirstChild("Sign") and o.Sign.TextLabel.Text == code then return o end
    end
end

Functions.GetMinecart = function() return Camera and Camera:FindFirstChild("MinecartRig") ~= nil end

Functions.GetNearestTurnNode = function()
    local N = { Distance = math.huge, Object = nil }
    for _, n in Objects.SeekNodes do
        local d = LocalPlayer:DistanceFromCharacter(n.Position)
        if d < (Options.AutoSteerMinecartTurnDistance and Options.AutoSteerMinecartTurnDistance.Value or 30)
            and d < N.Distance then N.Distance = d; N.Object = n end
    end
    return N.Object
end

Functions.GetNearestDuckBoard = function()
    local N = { Distance = math.huge, Object = nil }
    for _, b in Objects.SeekDuckBoards do
        if b.PrimaryPart then
            local d = LocalPlayer:DistanceFromCharacter(b.PrimaryPart.Position)
            if d < (Options.AutoSteerMinecartDuckDistance and Options.AutoSteerMinecartDuckDistance.Value or 30)
                and d < N.Distance then N.Distance = d; N.Object = b end
        end
    end
    return N.Object
end

Functions.GetLibraryCode = function()
    local p = Character:FindFirstChild("LibraryHintPaper") or Character:FindFirstChild("LibraryHintPaperHard")
        or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper") or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")
    if p and p:FindFirstChild("UI") then
        local code = {}; local len = (Floor == "Fools") and 10 or 5
        for i = 1, len do code[i] = "_" end
        for _, h in LocalPlayer.PlayerGui.PermUI.Hints:GetChildren() do
            for _, u in p.UI:GetChildren() do
                if h:IsA("ImageLabel") and u:IsA("ImageLabel")
                    and h.ImageRectOffset == u.ImageRectOffset and code[tonumber(u.Name)] then
                    code[tonumber(u.Name)] = h.TextLabel.Text
                end
            end
        end
        return table.concat(code)
    end
    return (Floor == "Fools") and "__________" or "_____"
end

Functions.GetRandomCode = function()
    local tpl = Functions.GetLibraryCode()
    if not tpl then return nil end
    local nc, tries = nil, 0
    repeat nc = tpl:gsub("_", function() return tostring(math.random(0,9)) end); tries += 1
    until not Globals.UsedRandomCodes[nc] or tries >= 10
    Globals.UsedRandomCodes[nc] = true
    return nc
end

Functions.GetDoorNumber = function(o)
    local n = tonumber(o.Parent and o.Parent.Name) or tonumber(o.Parent and o.Parent.Parent and o.Parent.Parent.Name)
    if n then n += 1 end
    if Floor == "Mines" then n += 100 end
    if Floor == "Backdoor" then n -= 50 end
    return tostring(n)
end

Functions.GetInjuriesSpeed = function() return 0.075 * (Humanoid.MaxHealth - Humanoid.Health) end

Functions.AddESP = function(Opts, RoomBased)
    local o = Opts.Object
    if table.find(ESPBlacklist, o) then return end
    if RoomBased then
        local function TryAdd()
            local cr = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
            local orr = tonumber(o:GetAttribute("ParentRoom"))
            if orr == cr or (table.find(Objects.Doors, o) and orr == cr + 1) then
                ESPLibrary:AddESP(Opts)
                if not table.find(EspObjects, o) then table.insert(EspObjects, o) end
            else
                ESPLibrary:RemoveESP(o)
                for i = #EspObjects, 1, -1 do if EspObjects[i] == o then table.remove(EspObjects, i) end end
            end
        end
        TryAdd()
        local c = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(TryAdd)
        table.insert(Connections, c); ESPConnections[o] = c
        o.Destroying:Once(function()
            c:Disconnect(); ESPLibrary:RemoveESP(o)
            local p = table.find(Connections, c); if p then table.remove(Connections, p) end
        end)
    else
        ESPLibrary:AddESP(Opts)
        if not table.find(EspObjects, o) then table.insert(EspObjects, o) end
    end
end

Functions.RemoveESP = function(o)
    local c = ESPConnections[o]
    if c then c:Disconnect(); ESPConnections[o] = nil
        local p = table.find(Connections, c); if p then table.remove(Connections, p) end end
    ESPLibrary:RemoveESP(o)
    for i = #EspObjects, 1, -1 do if EspObjects[i] == o then table.remove(EspObjects, i) end end
end

Functions.BlacklistESP = function(o)
    table.insert(ESPBlacklist, o)
    Functions.RemoveESP(o)
end
local Window = Library:CreateWindow({
    Title = "KL-Doors-TK", Footer = "2674791739制作",
    NotifySide = "Right", ShowCustomCursor = true,
})
local Tabs = {
    
    General  = Window:AddTab("通用", "user"),
    Exploits = Window:AddTab("作弊", "shield"),
    Visual   = Window:AddTab("视觉", "eye"),
    Floors   = Window:AddTab("楼层", "map"),
    Settings = Window:AddTab("界面设置", "settings"),
}

local CharacterBox = Tabs.General:AddLeftGroupbox("角色")
CharacterBox:AddSlider("SpeedBoostSlider", { Text="速度提升", Min=0, Max=100, Default=0, Rounding=0, Compact=true })
CharacterBox:AddToggle("SpeedBoostToggle", { Text="启用速度提升", Default=false,
    Callback=function(v) if Humanoid then Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + (v and Options.SpeedBoostSlider.Value or 0) end end })
CharacterBox:AddDivider()
CharacterBox:AddToggle("FlyToggle", { Text="飞行", Default=false, Callback=function(v)
    if not FlyBody then return end
    if v then FlyBody.Parent = RootPart else FlyBody.Parent = nil end
end })
Toggles.FlyToggle:AddKeyPicker("FlyKeybind", { Text="飞行", Default="F", Mode="Toggle", SyncToggleState=true })
CharacterBox:AddSlider("FlySpeed", { Text="飞行速度", Min=0, Max=115, Default=20, Rounding=0, Compact=true })
CharacterBox:AddDivider()
CharacterBox:AddToggle("NoclipToggle", { Text="穿墙", Default=false })
Toggles.NoclipToggle:AddKeyPicker("NoclipKeybind", { Text="穿墙", Default="N", Mode="Toggle", SyncToggleState=true })
CharacterBox:AddToggle("RemoveClosetDelay", { Text="移除衣柜后摇", Default=false })
CharacterBox:AddToggle("RemoveAcceleration", { Text="移除移动后摇", Default=false, Callback=function(v)
    if not CustomPhysics then return end
    for idx, old in pairs(PartProperties) do
        if idx and idx.Parent then idx.CustomPhysicalProperties = v and CustomPhysics or old end
    end
end })
CharacterBox:AddDivider()
CharacterBox:AddToggle("EnableCharacterJump", { Text="启用跳跃", Default=false, Callback=function(v)
    if Character then Character:SetAttribute("CanJump", v and true or (OldJump or false)) end
end })
CharacterBox:AddToggle("EnableCharacterSlide", { Text="启用滑铲", Default=false, Callback=function(v)
    if Character then Character:SetAttribute("CanSlide", v and true or (OldSlide or false)) end
end })
CharacterBox:AddToggle("InfiniteJumps", { Text="无限跳跃", Default=false })

local SelfBox = Tabs.General:AddLeftGroupbox("自身")
SelfBox:AddToggle("DoorReachToggle", { Text="门交互距离", Default=false, Tooltip="从更远处开门" })
SelfBox:AddToggle("DisableIdleKick", { Text="禁用挂机踢出", Default=false, Callback=function(v)
    if CheckCompat({"getconnections"}) then
        for _, c in Environment.getconnections(LocalPlayer.Idled) do
            if v then c:Disable() else c:Enable() end
        end
    end
end })
SelfBox:AddDivider()
SelfBox:AddSlider("PromptReachSlider", { Text="交互距离", Min=1, Max=2, Default=1, Rounding=1, Compact=true,
    Callback=function(v)
        for _, p in Objects.Prompts do
            p.MaxActivationDistance = (p:GetAttribute("MaxActivationDistance_Old") or 10) * v
        end
    end })
SelfBox:AddToggle("InstantPrompts", { Text="瞬间交互", Default=false, Callback=function(v)
    for _, p in Objects.Prompts do
        p.HoldDuration = v and 0 or (p:GetAttribute("HoldDuration_Old") or 0)
    end
end })
SelfBox:AddToggle("PromptClip", { Text="穿墙交互", Default=false, Callback=function(v)
    for _, p in Objects.Prompts do
        p.RequiresLineOfSight = v and false or (p:GetAttribute("RequiresLineOfSight_Old") or true)
    end
end })
local AutoBox = Tabs.General:AddRightGroupbox("自动化")
AutoBox:AddToggle("AutoBreakerBox", { Text="自动解决电箱谜题", Default=false, Callback=function(v)
    if v and CurrentRooms:FindFirstChild("ElevatorBreaker", true) then
        if not Globals.BreakerBoxInteracted and not Globals.BreakerBoxNotified then
            Functions.Notify({ Title="现在与断路器交互", Body="它将自动解决" })
            Globals.BreakerBoxInteracted = true
        else
            if RemotesFolder and RemotesFolder:FindFirstChild("EBF") then RemotesFolder.EBF:FireServer() end
        end
    end
end })
AutoBox:AddToggle("AutoSolveAnchors", { Text="自动解决锚点", Default=false })
AutoBox:AddToggle("AutoHeartbeatMinigame", { Text="自动心跳小游戏", Default=false,
    Disabled = not CheckCompat({"hookmetamethod","newcclosure","getnamecallmethod"}),
    DisabledTooltip = Globals.IncompatibleMessage })
AutoBox:AddDivider()
AutoBox:AddToggle("AutoUnlockPadlockToggle", { Text="自动解锁挂锁", Default=false })
AutoBox:AddSlider("AutoUnlockPadlockSlider", { Text="解锁距离", Min=1, Max=50, Default=10, Rounding=0, Compact=true })
AutoBox:AddToggle("AutoLibraryGuessCode", { Text="猜测图书馆密码", Default=false })
AutoBox:AddDivider()
AutoBox:AddToggle("AutoInteractToggle", { Text="自动交互", Default=false })
Toggles.AutoInteractToggle:AddKeyPicker("AutoInteractKeybind", { Text="自动交互", Default="R", Mode="Toggle", SyncToggleState=true })
AutoBox:AddDropdown("AutoInteractIgnoreList", {
    Text="忽略列表",
    Values={"故障碎片","Jeff 物品","掉落物品","矿车","锁","货币"},
    Default={"故障碎片","Jeff 物品","掉落物品","矿车"}, Multi=true, AllowNull=true })
AutoBox:AddDivider()
AutoBox:AddToggle("AutoClosetToggle", { Text="自动躲藏", Default=false })
Toggles.AutoClosetToggle:AddKeyPicker("AutoClosetKeybind", { Text="自动躲藏", Default="Q", Mode="Toggle", SyncToggleState=true })
AutoBox:AddDropdown("AutoClosetEntityList", {
    Text="忽略列表", Values={"Rush","Ambush","Blitz","A-60","A-120","AR0xMBUSH","RNIUSHCG=="}, Multi=true, AllowNull=true })
AutoBox:AddToggle("SpectateEntityToggle", { Text="旁观实体", Default=false })
AutoBox:AddDropdown("SpecateEntityMode", { Values={"玩家到实体","实体到玩家"}, Default=1, AllowNull=true })

local MiscBox = Tabs.General:AddRightGroupbox("杂项")
MiscBox:AddButton({ Text="再玩一局", Tooltip="加入新的一局", DoubleClick=true,
    Func=function() if RemotesFolder and RemotesFolder:FindFirstChild("PlayAgain") then RemotesFolder.PlayAgain:FireServer() end end })
MiscBox:AddButton({ Text="返回大厅", DoubleClick=true,
    Func=function() if RemotesFolder and RemotesFolder:FindFirstChild("Lobby") then RemotesFolder.Lobby:FireServer() end end })
MiscBox:AddButton({ Text="复活", DoubleClick=true,
    Func=function() if RemotesFolder and RemotesFolder:FindFirstChild("Revive") then RemotesFolder.Revive:FireServer() end end })
MiscBox:AddButton({ Text="重置角色", DoubleClick=true, Func=function()
    Globals.SelfKilled = true
    if CheckCompat({"replicatesignal"}) then Environment.replicatesignal(LocalPlayer.Kill)
    elseif RemotesFolder and RemotesFolder:FindFirstChild("Underwater") then RemotesFolder.Underwater:FireServer(true)
    elseif Humanoid then Humanoid.Health = 0 end
end })
local BypassBox = Tabs.Exploits:AddLeftGroupbox("绕过")
local BypassToggles = {
    BypassGiggle="绕过 Giggle", BypassDupe="绕过 Dupe", BypassEyes="绕过 Eyes",
    BypassLookman="绕过 Lookman", BypassGloombatEggs="绕过 Gloombat 蛋",
    BypassSeekObstructions="绕过 Seek 障碍", BypassVacuum="绕过真空",
    BypassKillbricks="绕过致命砖块", BypassSeekingWall="绕过追踪墙",
    BypassSnare="绕过 Snare", BypassBanana="绕过香蕉", BypassJeff="绕过 Jeff",
}
for k, v in pairs(BypassToggles) do BypassBox:AddToggle(k, { Text=v, Default=false }) end

Toggles.BypassGiggle:OnChanged(function(v)
    for _, o in Objects.Entities do
        if o.Name == "GiggleCeiling" and o:FindFirstChild("Hitbox") then o.Hitbox.CanTouch = not v end
    end
end)
Toggles.BypassDupe:OnChanged(function(v)
    for _, o in Objects.Entities do
        if o.Name == "DoorFake" or o.Name == "FakeDoor" then
            local h = o:FindFirstChild("Hidden"); if h then h.CanTouch = not v end
            local l = o:FindFirstChild("Lock")
            if l and l:FindFirstChild("UnlockPrompt") then l.UnlockPrompt.Enabled = not v end
        end
    end
end)
Toggles.BypassEyes:OnChanged(function(v)
    if v and Globals.IsEyes and RemotesFolder and RemotesFolder:FindFirstChild("MotorReplication") then
        if Floor == "Fools" or Floor == "OldHotel" then
            RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
        else RemotesFolder.MotorReplication:FireServer(-650) end
    end
end)
Toggles.BypassLookman:OnChanged(function(v)
    if v and Globals.IsLookman and RemotesFolder and RemotesFolder:FindFirstChild("MotorReplication") then
        if Floor == "Fools" or Floor == "OldHotel" then
            RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
        else RemotesFolder.MotorReplication:FireServer(-650) end
    end
end)
Toggles.BypassGloombatEggs:OnChanged(function(v)
    for _, o in Objects.Entities do
        for _, p in o:GetDescendants() do if p:IsA("BasePart") then p.CanTouch = not v end end
    end
end)
Toggles.BypassSeekObstructions:OnChanged(function(v)
    for _, o in Objects.SeekObstructions do
        o.CanTouch = not v; if o.Name == "SeekFloodline" then o.CanCollide = v end
    end
    for _, b in Objects.SeekBridges do b.CanCollide = v; b.Transparency = v and 0 or 1 end
end)
Toggles.BypassVacuum:OnChanged(function(v)
    for _, o in Objects.Entities do
        if o.Name == "SideroomSpace" and o:FindFirstChild("Collision") then
            o.Collision.CanCollide = v; o.Collision.CanTouch = not v
        end
    end
end)
Toggles.BypassKillbricks:OnChanged(function(v)
    for _, o in Objects.Obstructions do if o.Name == "Lava" then o.CanTouch = not v end end
end)
Toggles.BypassSeekingWall:OnChanged(function(v)
    for _, o in Objects.Obstructions do
        if o.Name == "ScaryWall" then
            for _, p in o:GetDescendants() do
                if p:IsA("BasePart") then p.CanTouch = not v; p.CanCollide = not v end
            end
        end
    end
end)
Toggles.BypassSnare:OnChanged(function(v)
    for _, o in Objects.Entities do
        if o.Name == "Snare" then
            for _, p in o:GetDescendants() do if p:IsA("BasePart") then p.CanTouch = not v end end
        end
    end
end)
Toggles.BypassBanana:OnChanged(function(v)
    for _, o in Objects.Entities do if o.Name == "BananaPeel" then o.CanTouch = not v end end
end)
Toggles.BypassJeff:OnChanged(function(v)
    for _, o in Objects.Entities do
        if o.Name == "JeffTheKiller" then
            for _, p in o:GetDescendants() do
                if p:IsA("BasePart") then p.CanCollide = not v; p.CanTouch = not v end
            end
            if o:FindFirstChild("Humanoid") then o.Humanoid.Health = 0 end
        end
    end
end)

local BypassRight = Tabs.Exploits:AddRightGroupbox("绕过 (进阶)")
BypassRight:AddToggle("DisableAnticheat", { Text="反作弊绕过", Default=false, Callback=function(v)
    if Globals.AnticheatDisabled == true and not v then
        if RemotesFolder and RemotesFolder:FindFirstChild("ClimbLadder") then RemotesFolder.ClimbLadder:FireServer() end
        Globals.AnticheatDisabled = false
    end
end })
BypassRight:AddToggle("VelocityManipulationToggle", { Text="速度操控", Default=false })
Toggles.VelocityManipulationToggle:AddKeyPicker("VelocityManipulationKeybind", { Text="速度操控", Default="V", Mode="Toggle", SyncToggleState=true })
BypassRight:AddDropdown("VelocityManipulationMode", { Values={"速度","转向"}, Default=1, Text="操控方式" })
BypassRight:AddDivider()
BypassRight:AddToggle("InfiniteItemsToggle", { Text="无限物品", Default=false,
    Disabled = not CheckCompat({"fireproximityprompt"}),
    DisabledTooltip = Globals.IncompatibleMessage })
BypassRight:AddDropdown("InfiniteItemsList", { Text="物品列表",
    Values={"开锁器","骷髅钥匙","剪刀","多功能工具"}, Multi=true, AllowNull=true,
    Disabled = not CheckCompat({"fireproximityprompt"}) })
BypassRight:AddDivider()
BypassRight:AddToggle("PositionSpoof", { Text="位置欺骗-无敌", Default=false, Callback=function(v)
    if Floor ~= "Fools" and Floor ~= "OldHotel" and RootPart then
        if v then
            RootPart.CFrame = RootPart.CFrame * CFrame.new(0,-2.346,0); Humanoid.HipHeight = 0.05
            if RemotesFolder and RemotesFolder:FindFirstChild("Crouch") then RemotesFolder.Crouch:FireServer(true,true) end
        else
            RootPart.CFrame = RootPart.CFrame * CFrame.new(0,2.346,0); Humanoid.HipHeight = 2.396
        end
    end
end })
Toggles.PositionSpoof:AddKeyPicker("PositionSpoofKeybind", { Text="位置欺骗", Default="B", Mode="Toggle", SyncToggleState=true })
BypassRight:AddToggle("CrouchSpoof", { Text="蹲下欺骗", Default=false, Callback=function(v)
    if RemotesFolder and RemotesFolder:FindFirstChild("Crouch") then
        RemotesFolder.Crouch:FireServer(v and true or Functions.IsCrouching(), true)
    end
end })

local RemoveBox = Tabs.Exploits:AddRightGroupbox("移除")
local RemoveToggles = { RemoveScreech="移除 Screech", RemoveHalt="移除 Halt",
    RemoveA90="移除 A-90", RemoveDread="移除 Dread", RemoveSurge="移除 Surge" }
for k, v in pairs(RemoveToggles) do RemoveBox:AddToggle(k, { Text=v, Default=false }) end
RemoveBox:AddDivider()
local NoDmgToggles = { NoScreechDamage="无 Screech 伤害", NoHaltDamage="无 Halt 伤害",
    NoA90Damage="无 A-90 伤害", NoSurgeDamage="无 Surge 伤害" }
for k, v in pairs(NoDmgToggles) do RemoveBox:AddToggle(k, { Text=v, Default=false }) end

Toggles.NoScreechDamage:OnChanged(function(v)
    if FakeEvents.Screech_Real then
        if v then FakeEvents.Screech.Parent = RemotesFolder; FakeEvents.Screech_Real.Parent = nil
        else FakeEvents.Screech_Real.Parent = RemotesFolder; FakeEvents.Screech.Parent = nil end
    end
end)
Toggles.NoHaltDamage:OnChanged(function(v)
    if FakeEvents.Shade_Real then
        if v then FakeEvents.Shade.Parent = RemotesFolder; FakeEvents.Shade_Real.Parent = nil
        else FakeEvents.Shade_Real.Parent = RemotesFolder; FakeEvents.Shade.Parent = nil end
    end
end)
Toggles.NoA90Damage:OnChanged(function(v)
    if FakeEvents.A90_Real then
        if v then FakeEvents.A90.Parent = RemotesFolder; FakeEvents.A90_Real.Parent = nil
        else FakeEvents.A90_Real.Parent = RemotesFolder; FakeEvents.A90.Parent = nil end
    end
end)
Toggles.NoSurgeDamage:OnChanged(function(v)
    if FakeEvents.Surge_Real then
        if v then FakeEvents.Surge.Parent = RemotesFolder; FakeEvents.Surge_Real.Parent = nil
        else FakeEvents.Surge_Real.Parent = RemotesFolder; FakeEvents.Surge.Parent = nil end
    end
end)
Toggles.RemoveScreech:OnChanged(function(v)
    if Modules.Screech then Modules.Screech.Name = v and "Screech_Disabled" or "Screech" end
    if Modules.GlitchScreech then Modules.GlitchScreech.Name = v and "GlitchScreech_Disabled" or "GlitchScreech" end
end)
Toggles.RemoveHalt:OnChanged(function(v)
    if Modules.Shade then Modules.Shade.Name = v and "Shade_Disabled" or "Shade" end
end)
Toggles.RemoveA90:OnChanged(function(v)
    if Modules.A90 then Modules.A90.Name = v and "A90_Disabled" or "A90" end
end)
Toggles.RemoveDread:OnChanged(function(v)
    if Modules.Dread then Modules.Dread.Name = v and "Dread_Disabled" or "Dread" end
end)
Toggles.RemoveSurge:OnChanged(function(v)
    if Globals.SurgeFrame then Globals.SurgeFrame.Name = v and "SurgeVignette_Disabled" or "SurgeVignette" end
end)

local AudioBox = Tabs.Exploits:AddLeftGroupbox("音频")
AudioBox:AddToggle("RemoveFootstepSounds", { Text="移除脚步音效", Default=false })
AudioBox:AddToggle("RemoveJamminMusic", { Text="移除 Jammin 音乐", Default=false, Callback=function(v)
    local jam = LocalPlayer.PlayerGui.MainUI and LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
    if jam then jam.Volume = v and 0 or 0.45 end
end })
AudioBox:AddToggle("RemoveInteractingSounds", { Text="移除交互音效", Default=false })
AudioBox:AddToggle("RemoveRainSound", { Text="移除窗外风雨音效", Default=false })
AudioBox:AddToggle("RemoveDoorSound", { Text="移除开/关门音效", Default=false })
AudioBox:AddToggle("RemoveDrawerSound", { Text="移除抽屉音效", Default=false })
AudioBox:AddToggle("RemoveMonsterSound", { Text="移除怪物音效", Default=false })

local SoundFilterConfig = {
    RemoveRainSound = { Ids = { "rbxassetid://358496539","rbxassetid://9145201982","rbxassetid://9449995657" } },
    RemoveDoorSound = { Ids = { "rbxassetid://11447013731","rbxassetid://11447163904","rbxassetid://7758469482",
        "rbxassetid://17750116436","rbxassetid://17717855685","rbxassetid://92153304013679" } },
    RemoveDrawerSound = { Ids = { "rbxassetid://7178552067","rbxassetid://7178552117" } },
    RemoveMonsterSound = { Ids = { "rbxassetid://9145200783","rbxassetid://6305809364","rbxassetid://9126213993",
        "rbxassetid://1168009240","rbxassetid://1643780712","rbxassetid://9126209752","rbxassetid://9145202614",
        "rbxassetid://12122196180","rbxassetid://2118376406" } },
}
local ActiveMuteIds = {}
local function UpdateActiveMuteIds()
    local t = {}
    for tn, cfg in pairs(SoundFilterConfig) do
        if Toggles[tn] and Toggles[tn].Value then
            for _, id in ipairs(cfg.Ids) do t[id] = true end
        end
    end
    ActiveMuteIds = t
end
local function ApplySoundState(s)
    if ActiveMuteIds[s.SoundId] then
        if s.Volume > 0 then s:SetAttribute("OriginalVolume", s.Volume); s.Volume = 0 end
    else
        local o = s:GetAttribute("OriginalVolume")
        if o then s.Volume = o; s:SetAttribute("OriginalVolume", nil) end
    end
end
local function RefreshAllSounds()
    for _, o in Workspace:GetDescendants() do if o:IsA("Sound") then ApplySoundState(o) end end
end
for tn in pairs(SoundFilterConfig) do
    if Toggles[tn] then Toggles[tn]:OnChanged(function() UpdateActiveMuteIds(); RefreshAllSounds() end) end
end
table.insert(Connections, Workspace.DescendantAdded:Connect(function(o)
    if o:IsA("Sound") then task.wait(); ApplySoundState(o) end
end))
task.spawn(function() UpdateActiveMuteIds(); RefreshAllSounds() end)
local VisualLeftTab = Tabs.Visual:AddLeftTabbox("相机 / 效果")
local CamTab = VisualLeftTab:AddTab("相机")
CamTab:AddToggle("AmbientToggle", { Text="环境光", Default=false })
Toggles.AmbientToggle:AddColorPicker("AmbientColor", { Text="环境光颜色", Default=Color3.fromRGB(255,255,255), Transparency=0 })
CamTab:AddSlider("FieldOfView", { Text="视野", Min=1, Max=120, Default=70, Rounding=0 })
CamTab:AddDivider()
CamTab:AddToggle("RemoveCameraShake", { Text="移除相机抖动", Default=false })
CamTab:AddToggle("RemoveCameraBobbing", { Text="移除相机晃动", Default=false, Callback=function(v)
    if Main_Game then Main_Game.spring.Speed = v and 9e9 or 8 end
end })
CamTab:AddToggle("RemoveCutscenes", { Text="移除过场动画", Default=false, Callback=function(v)
    local Cutscenes = LocalPlayer.PlayerGui.MainUI and LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
    if Cutscenes then
        for _, o in Cutscenes:GetChildren() do
            if table.find(CutsceneNames, o.Name) and o:IsA("ModuleScript") then
                o.Name = v and (o.Name .. "_Disabled") or (o:GetAttribute("OriginalName") or o.Name)
            end
        end
    end
    for _, o in FloorReplicated:GetChildren() do
        if table.find(CutsceneNames, o.Name) and o:IsA("ModuleScript") then
            o.Name = v and (o.Name .. "_Disabled") or (o:GetAttribute("OriginalName") or o.Name)
        end
    end
end })
CamTab:AddToggle("RemoveCameraFog", { Text="移除雾气", Default=false, Callback=function(v)
    Lighting.FogEnd = v and 1e7 or Globals.OldFog
    for _, o in Globals.FogInstances do
        o.Density = v and 0 or (o:GetAttribute("Density_Old") or 0)
    end
end })
CamTab:AddDivider()
CamTab:AddToggle("ThirdPersonToggle", { Text="第三人称", Default=false })
Toggles.ThirdPersonToggle:AddKeyPicker("ThirdPersonKeybind", { Text="第三人称", Default="T", Mode="Toggle", SyncToggleState=true })
CamTab:AddSlider("ThirdPersonOffsetX", { Text="X 偏移", Min=-10, Max=10, Default=1.5, Rounding=1, Compact=true })
CamTab:AddSlider("ThirdPersonOffsetY", { Text="Y 偏移", Min=-10, Max=10, Default=1, Rounding=1, Compact=true })
CamTab:AddSlider("ThirdPersonOffsetZ", { Text="Z 偏移", Min=-10, Max=10, Default=5, Rounding=1, Compact=true })
CamTab:AddToggle("ThirdPersonWallCheck", { Text="墙体检测", Default=false })
local EffectsTab = VisualLeftTab:AddTab("效果")
EffectsTab:AddToggle("TransparentHidingSpotsToggle", { Text="透明躲藏点", Default=false })
EffectsTab:AddSlider("TransparentHidingSpotsSlider", { Text="透明度", Min=0, Max=1, Default=0.5, Rounding=2, Compact=true })
EffectsTab:AddDivider()
EffectsTab:AddToggle("DisableGlitchJumpscare", { Text="禁用 Glitch 跳杀", Default=false, Callback=function(v)
    if Modules.Glitch then Modules.Glitch.Name = v and "Glitch_Disabled" or "Glitch" end
end })
EffectsTab:AddToggle("DisableTimothyJumpscare", { Text="禁用 Timothy 跳杀", Default=false, Callback=function(v)
    if Modules.SpiderJumpscare then Modules.SpiderJumpscare.Name = v and "SpiderJumpscare_Disabled" or "SpiderJumpscare" end
end })
EffectsTab:AddToggle("DisableVoidJumpscare", { Text="禁用 Void 跳杀", Default=false, Callback=function(v)
    if Modules.Void then Modules.Void.Name = v and "Void_Disabled" or "Void" end
end })
EffectsTab:AddDivider()
EffectsTab:AddToggle("DisableHideVignette", { Text="禁用躲藏暗角", Default=false, Callback=function(v)
    local mui = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
    if not mui then return end
    local vg = mui:FindFirstChild("HideVignette") or (mui.MainFrame and mui.MainFrame:FindFirstChild("HideVignette"))
    if vg then vg.Image = v and "Disabled" or "rbxassetid://6100076320" end
end })
EffectsTab:AddToggle("DisableFiredampEffect", { Text="禁用瓦斯效果", Default=false, Callback=function(v)
    if not CurrentRooms then return end
    for _, r in CurrentRooms:GetChildren() do
        if v then
            if firedampOriginal[r] == nil then firedampOriginal[r] = r:GetAttribute("Firedamp") end
            r:SetAttribute("Firedamp", false)
        else
            if firedampOriginal[r] ~= nil then r:SetAttribute("Firedamp", firedampOriginal[r]) end
        end
    end
end })
EffectsTab:AddToggle("DisableEntityJumpscares", { Text="禁用实体跳杀", Default=false, Callback=function(v)
    local js = LocalPlayer.PlayerGui.MainUI and LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
    if js then
        js.Name = v and "Jumpscares_Disabled" or "Jumpscares"
        for _, o in Objects.JumpscareModules do
            o.Name = v and (o:GetAttribute("OriginalName") .. "_Disabled") or o:GetAttribute("OriginalName")
        end
    end
end })
local VisualRightTab = Tabs.Visual:AddRightTabbox("实体 / 设置")
local EntityTab = VisualRightTab:AddTab("实体")

EntityTab:AddDropdown("EntityList", {
    Text="实体列表",
    Values={"Rush","Ambush","Eyes","Halt","Blitz","Lookman","Gloombat Swarm","A-60","A-120","Sally",
        "Jeff the Killer","Groundskeeper","Monument","AR0xMBUSH","RNIUSHCG=="},
    Multi=true, AllowNull=true })
EntityTab:AddToggle("NotifyEntities", { Text="通知实体", Default=false })
EntityTab:AddDivider()
local ItemsToNotify = {}
for _, n in pairs(ItemNames) do if not table.find(ItemsToNotify, n) then table.insert(ItemsToNotify, n) end end
EntityTab:AddDropdown("NotifyItemList", { Text="物品列表", Values=ItemsToNotify, Multi=true, AllowNull=true })
EntityTab:AddToggle("NotifyItemsToggle", { Text="通知物品", Default=false })
EntityTab:AddToggle("NotifyItemsShowDistance", { Text="显示距离", Default=false })
EntityTab:AddDivider()
EntityTab:AddToggle("NotifyLibraryCode", { Text="通知图书馆密码", Default=false })
EntityTab:AddToggle("NotifyOxygen", { Text="通知氧气量", Default=false })
EntityTab:AddToggle("NotifyHasteTime", { Text="通知 Haste 时间", Default=false })
EntityTab:AddDivider()
EntityTab:AddToggle("EntityChatToggle", { Text="通知聊天", Default=false })
EntityTab:AddInput("EntityChatMessage", { Text="消息", Default="已生成！", Placeholder="消息" })
EntityTab:AddDropdown("NotifyStyleDropdown", { Text="通知样式", Values={"Abysall","Doors","STX","Library"}, Default=1 })
Options.NotifyStyleDropdown:OnChanged(function(v) NotifyStyle = v end)
Options.NotifyStyleDropdown:SetValue("Library")
EntityTab:AddSlider("NotifySoundVolume", { Text="音量", Min=0, Max=10, Default=3, Rounding=1 })
EntityTab:AddToggle("NotifyPlaySound", { Text="播放声音", Default=true, Callback=function(v) NotifySoundEnabled = v end })
EntityTab:AddToggle("NotifyKeepNotifications", { Text="保持通知", Default=false })
EntityTab:AddButton({ Text="测试通知", DoubleClick=false, Func=function() Functions.Notify({ Title="这是一条测试通知" }) end })
local ESPRightTab = Tabs.Visual:AddRightTabbox("ESP / ESP 设置")
local ESPTab = ESPRightTab:AddTab("ESP")
local ESPSettingsTab = ESPRightTab:AddTab("ESP 设置")

ESPTab:AddToggle("ObjectiveESPToggle", { Text="目标", Default=false })
Toggles.ObjectiveESPToggle:AddColorPicker("ObjectiveESPColor", { Text="目标", Default=Color3.fromRGB(0,255,0), Transparency=0 })
Toggles.ObjectiveESPToggle:OnChanged(function(v)
    for _, o in Objects.Objectives do
        if v then
            local lbl = ObjectiveLabels[o.Name]
            if o.Name == "TimerLever" then lbl = "时间拉杆 [+" .. (o:GetAttribute("AddTime") or 30) .. "秒]"
            elseif o.Name == "MinesAnchor" and o:FindFirstChild("Sign") then lbl = "锚点 [" .. o.Sign.TextLabel.Text .. "]"
            elseif o.Name == "WaterPump" then Functions.AddESP({ Object=o.Wheel, Text="水泵", Color=Options.ObjectiveESPColor.Value }, true)
            elseif o.Name == "VineGuillotine" then Functions.AddESP({ Object=o.Lever, Text="藤蔓拉杆", Color=Options.ObjectiveESPColor.Value }, true) end
            if lbl then Functions.AddESP({ Object=o, Text=lbl, Color=Options.ObjectiveESPColor.Value }, true) end
        else Functions.RemoveESP(o) end
    end
end)
Options.ObjectiveESPColor:OnChanged(function(v) for _, o in Objects.Objectives do ESPLibrary:UpdateObjectColor(o, v) end end)

ESPTab:AddToggle("DoorESPToggle", { Text="门", Default=false })
Toggles.DoorESPToggle:AddColorPicker("DoorESPColor", { Text="门", Default=Color3.fromRGB(0,200,255), Transparency=0 })
Toggles.DoorESPToggle:OnChanged(function(v)
    for _, o in Objects.Doors do
        if v then Functions.AddESP({ Object=o, Text="门 " .. Functions.GetDoorNumber(o), Color=Options.DoorESPColor.Value }, true)
        else Functions.RemoveESP(o) end
    end
end)

ESPTab:AddToggle("HidingSpotESPToggle", { Text="躲藏点", Default=false })
Toggles.HidingSpotESPToggle:AddColorPicker("HidingSpotESPColor", { Text="躲藏点", Default=Color3.fromRGB(255,170,0), Transparency=0 })
Toggles.HidingSpotESPToggle:OnChanged(function(v)
    for _, o in Objects.HidingSpots do
        local lbl = HidingSpotLabels[o.Name]
        if v and lbl then Functions.AddESP({ Object=o, Text=lbl, Color=Options.HidingSpotESPColor.Value }, true)
        elseif not v then Functions.RemoveESP(o) end
    end
end)

ESPTab:AddToggle("PlayerESPToggle", { Text="玩家", Default=false })
Toggles.PlayerESPToggle:AddColorPicker("PlayerESPColor", { Text="玩家", Default=Color3.fromRGB(255,255,255), Transparency=0 })
Toggles.PlayerESPToggle:OnChanged(function(v)
    for _, pl in Players:GetPlayers() do
        if pl.Character and pl ~= LocalPlayer then
            if v and pl:GetAttribute("Alive") == true then
                Functions.AddESP({ Object=pl.Character, Text=pl.Name, Color=Options.PlayerESPColor.Value })
            else Functions.RemoveESP(pl.Character) end
        end
    end
end)

ESPTab:AddToggle("ChestESPToggle", { Text="箱子", Default=false })
Toggles.ChestESPToggle:AddColorPicker("ChestESPColor", { Text="箱子", Default=Color3.fromRGB(255,255,0), Transparency=0 })
Toggles.ChestESPToggle:OnChanged(function(v)
    for _, o in Objects.Chests do
        if v then
            local lbl
            if o.Name == "ChestBox" or o.Name == "ChestBoxLocked" then lbl = o:GetAttribute("Locked") and "上锁箱子" or "箱子"
            elseif o.Name == "Toolbox" or o.Name == "Toolbox_Locked" then lbl = o:GetAttribute("Locked") and "上锁工具箱" or "工具箱"
            elseif ChestLabels[o.Name] and ChestLabels[o.Name] ~= true then lbl = ChestLabels[o.Name] end
            if lbl then Functions.AddESP({ Object=o, Text=lbl, Color=Options.ChestESPColor.Value }, true) end
        else Functions.RemoveESP(o) end
    end
end)

ESPTab:AddToggle("ItemESPToggle", { Text="物品", Default=false })
Toggles.ItemESPToggle:AddColorPicker("ItemESPColor", { Text="物品", Default=Color3.fromRGB(170,0,255), Transparency=0 })
Toggles.ItemESPToggle:OnChanged(function(v)
    for _, o in Objects.Items do
        if v then
            local lbl = ItemNames[o.Name]
            if lbl then Functions.AddESP({ Object=o, Text=lbl, Color=Options.ItemESPColor.Value }, o:GetAttribute("ParentRoom") ~= nil) end
        else Functions.RemoveESP(o) end
    end
end)

ESPTab:AddToggle("CurrencyESPToggle", { Text="货币", Default=false })
Toggles.CurrencyESPToggle:AddColorPicker("CurrencyESPColor", { Text="货币", Default=Color3.fromRGB(255,255,0), Transparency=0 })
Toggles.CurrencyESPToggle:OnChanged(function(v)
    for _, o in Objects.Currency do
        if v then
            local lbl
            if o.Name == "GoldPile" and o:GetAttribute("GoldValue") then lbl = "金币堆 [" .. o:GetAttribute("GoldValue") .. "]"
            elseif o.Name == "StardustPickup" then lbl = "星尘" end
            if lbl then Functions.AddESP({ Object=o, Text=lbl, Color=Options.CurrencyESPColor.Value }, true) end
        else Functions.RemoveESP(o) end
    end
end)
ESPTab:AddToggle("LadderESPToggle", { Text="梯子", Default=false })
Toggles.LadderESPToggle:AddColorPicker("LadderESPColor", { Text="梯子", Default=Color3.fromRGB(255,255,255), Transparency=0 })
Toggles.LadderESPToggle:OnChanged(function(v)
    for _, o in Objects.Ladders do
        if v then Functions.AddESP({ Object=o, Text="梯子", Color=Options.LadderESPColor.Value }, true)
        else Functions.RemoveESP(o) end
    end
end)

ESPTab:AddDropdown("EntityESPOptions", {
    Text="实体列表",
    Values={"Rush","Ambush","Eyes","Dupe","Figure","Blitz","Lookman","Snare","Giggle","Gloombat Eggs",
        "Grumble","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Mandrake Hole","Monument",
        "Bramble","AR0xMBUSH","RNIUSHCG=="},
    Multi=true, AllowNull=true })
ESPTab:AddToggle("EntityESPToggle", { Text="实体", Default=false })
Toggles.EntityESPToggle:AddColorPicker("EntityESPColor", { Text="实体", Default=Color3.fromRGB(255,0,0), Transparency=0 })
Toggles.EntityESPToggle:OnChanged(function(v)
    for _, o in Objects.Entities do
        if v then
            local lbl = EntityESPLabels[o.Name] or (Entities[o.Name] and Entities[o.Name].Alias)
            if lbl and Options.EntityESPOptions.Value[lbl] then
                Functions.AddESP({ Object=o, Text=lbl, Color=Options.EntityESPColor.Value }, NodeEntities[lbl] ~= true)
            else Functions.RemoveESP(o) end
        else Functions.RemoveESP(o) end
    end
end)
Options.EntityESPOptions:OnChanged(function(v)
    if not Toggles.EntityESPToggle.Value then return end
    for _, o in Objects.Entities do
        local lbl = EntityESPLabels[o.Name] or (Entities[o.Name] and Entities[o.Name].Alias)
        if lbl and v[lbl] then Functions.AddESP({ Object=o, Text=lbl, Color=Options.EntityESPColor.Value }, NodeEntities[lbl] ~= true)
        else Functions.RemoveESP(o) end
    end
end)

ESPSettingsTab:AddToggle("ESPRainbow", { Text="彩虹效果", Default=false, Callback=function(v) ESPLibrary:SetRainbow(v) end })
ESPSettingsTab:AddToggle("ESPShowDistance", { Text="显示距离", Default=true, Callback=function(v) ESPLibrary:SetShowDistance(v) end })
ESPSettingsTab:AddSlider("ESPFillTransparency", { Text="填充透明度", Min=0, Max=1, Default=0.75, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetFillTransparency(v) end })
ESPSettingsTab:AddSlider("ESPOutlineTransparency", { Text="轮廓透明度", Min=0, Max=1, Default=0, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetOutlineTransparency(v) end })
ESPSettingsTab:AddSlider("ESPTextTransparency", { Text="文字透明度", Min=0, Max=1, Default=0, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetTextTransparency(v) end })
ESPSettingsTab:AddSlider("ESPTextOutlineTransparency", { Text="文字轮廓透明度", Min=0, Max=1, Default=0, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetTextOutlineTransparency(v) end })
ESPSettingsTab:AddSlider("ESPTextSize", { Text="文字大小", Min=12, Max=24, Default=20, Rounding=0, Compact=true,
    Callback=function(v) ESPLibrary:SetTextSize(v) end })
ESPSettingsTab:AddSlider("ESPRenderLimit", { Text="渲染上限", Min=30, Max=240, Default=240, Rounding=0, Compact=true,
    Callback=function(v) ESPLibrary:SetRenderLimit(v) end })
ESPSettingsTab:AddSlider("ESPFadeTime", { Text="淡出时间", Min=0, Max=1, Default=0.25, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetFadeTime(v) end })
ESPSettingsTab:AddDropdown("ESPTextFont", {
    Text="文字字体",
    Values={"Legacy","Arial","ArialBold","SourceSans","SourceSansBold","Bodoni","Garamond",
        "Cartoon","Code","Highway","SciFi","Arcade","Fantasy","Antique","Gotham","GothamBold",
        "Bangers","Creepster","IndieFlower","LuckiestGuy","Merriweather","Oswald","PermanentMarker"},
    Default=10,
    Callback=function(v) pcall(function() ESPLibrary:SetFont(Enum.Font[v]) end) end })
ESPSettingsTab:AddDivider()
ESPSettingsTab:AddDropdown("ESPTracersOrigin", {
    Text="Tracer 起点", Values={"底部","中心","顶部","鼠标"}, Default=1,
    Callback=function(v)
        local map = { ["底部"]="Bottom", ["中心"]="Center", ["顶部"]="Top", ["鼠标"]="Mouse" }
        pcall(function() ESPLibrary:SetTracerOrigin(map[v] or "Bottom") end)
    end })
ESPSettingsTab:AddSlider("ESPTracerThickness", { Text="Tracer 粗细", Min=0.5, Max=2, Default=0.75, Rounding=2, Compact=true,
    Callback=function(v) ESPLibrary:SetTracerSize(v) end })
ESPSettingsTab:AddToggle("ESPTracersToggle", { Text="启用 Tracers", Default=false,
    Callback=function(v) ESPLibrary:SetTracers(v) end })
ESPSettingsTab:AddDivider()
ESPSettingsTab:AddSlider("ESPArrowsRadius", { Text="箭头半径", Min=100, Max=500, Default=250, Rounding=0, Compact=true,
    Callback=function(v) ESPLibrary:SetArrowRadius(v) end })
ESPSettingsTab:AddToggle("ESPArrowsToggle", { Text="启用箭头", Default=false,
    Callback=function(v) ESPLibrary:SetArrows(v) end })

pcall(function() ESPLibrary:SetRainbow(false) ESPLibrary:SetShowDistance(true)
    ESPLibrary:SetFillTransparency(0.9) ESPLibrary:SetOutlineTransparency(0)
    ESPLibrary:SetTextTransparency(0) ESPLibrary:SetTextOutlineTransparency(0)
    ESPLibrary:SetRenderLimit(120) ESPLibrary:SetFadeTime(0.2) ESPLibrary:SetTextSize(20)
    ESPLibrary:SetFont(Enum.Font.Highway) ESPLibrary:SetTracers(false)
    ESPLibrary:SetTracerSize(0.75) ESPLibrary:SetTracerOrigin("Bottom")
    ESPLibrary:SetArrows(false) ESPLibrary:SetArrowRadius(250)
end)
local FloorsVisual = Tabs.Floors:AddLeftGroupbox("视觉")
FloorsVisual:AddToggle("ShowSeekPathToggle", { Text="显示 Seek 路径", Default=false, Risky = Floor ~= "Mines" })
Toggles.ShowSeekPathToggle:AddColorPicker("ShowSeekPathColor", { Text="Seek 路径", Default=Color3.fromRGB(0,255,0), Transparency=0 })
FloorsVisual:AddToggle("ShowEyestalkPathToggle", { Text="显示 Eyestalk 路径", Default=false, Risky = Floor ~= "Garden" })
Toggles.ShowEyestalkPathToggle:AddColorPicker("ShowEyestalkPathColor", { Text="Eyestalk 路径", Default=Color3.fromRGB(0,255,0), Transparency=0 })

local function BeamVis(t, v)
    local vis = v and 0 or 1
    local seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, vis), NumberSequenceKeypoint.new(1, vis) })
    for _, b in t do b.Transparency = seq end
end
local function BeamCol(t, v)
    local seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, v), ColorSequenceKeypoint.new(1, v) })
    for _, b in t do b.Color = seq end
end
Toggles.ShowSeekPathToggle:OnChanged(function(v) BeamVis(Objects.SeekHighlights, v) end)
Options.ShowSeekPathColor:OnChanged(function(v) BeamCol(Objects.SeekHighlights, v) end)
Toggles.ShowEyestalkPathToggle:OnChanged(function(v) BeamVis(Objects.EyestalkHighlights, v) end)
Options.ShowEyestalkPathColor:OnChanged(function(v) BeamCol(Objects.EyestalkHighlights, v) end)

local FloorsBypass = Tabs.Floors:AddLeftGroupbox("绕过")
FloorsBypass:AddToggle("RemoveSeekTrigger", { Text="删除 Seek", Default=false,
    Risky = not (Floor=="Fools" or Floor=="OldHotel"),
    Disabled = not CheckCompat({"firetouchinterest"}) })
FloorsBypass:AddToggle("RemoveFigure", { Text="删除 Figure", Default=false,
    Risky = not (Floor=="Fools" or Floor=="OldHotel" or Floor=="Mines"),
    Disabled = not CheckCompat({"isnetworkowner"}) })
FloorsBypass:AddToggle("AutoRevive", { Text="无限复活", Default=false,
    Risky = not (Floor=="Fools" or Floor=="OldHotel") })
FloorsBypass:AddToggle("FigureGodmode", { Text="Figure 无敌", Default=false,
    Risky = not (Floor=="Fools" or Floor=="OldHotel") })
FloorsBypass:AddToggle("BypassWater", { Text="绕过电水", Default=false, Risky = Floor ~= "Archives" })
FloorsBypass:AddDivider()
FloorsBypass:AddToggle("RemoveBasementGate", { Text="移除地下室门", Default=false })
FloorsBypass:AddToggle("RemovePaintingsDoor", { Text="移除画门", Default=false })
FloorsBypass:AddToggle("RemoveSkeletonDoor", { Text="移除骷髅门", Default=false })

local ObstructionNames = { ThingToOpen="RemoveBasementGate", MovingDoor="RemovePaintingsDoor", Wax_Door="RemoveSkeletonDoor" }
for objName, tName in pairs(ObstructionNames) do
    Toggles[tName]:OnChanged(function(v)
        for _, o in Objects.Obstructions do
            if o.Name == objName then
                o:PivotTo(v and CFrame.new(-10000,-10000,-10000) or (o:GetAttribute("OriginalPosition") or o:GetPivot()))
            end
        end
    end)
end

local FloorsFarm = Tabs.Floors:AddLeftGroupbox("刷取")
FloorsFarm:AddToggle("KnobFarm", { Text="knobs 刷取", Default=false })
FloorsFarm:AddButton({ Text="开始 Knob 刷取", DoubleClick=false, Func=function()
    if LatestRoom.Value ~= 0 then Functions.Notify({ Title="必须在 0 号房间才能使用" }); return end
    Globals.KnobFarmStarted = true
    Functions.Notify({ Title="请收集一些金币", Body="准备好后点击开始 Knob 刷取" })
end })
FloorsFarm:AddDivider()
FloorsFarm:AddButton({ Text="开始死亡刷取", DoubleClick=true, Func=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Scripts/DeathFarm.luau"))()
end, Disabled = not CheckCompat({"fireproximityprompt","firesignal"}) })
FloorsFarm:AddButton({ Text="复制死亡刷取链接", DoubleClick=false, Func=function()
    toclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Scripts/DeathFarm.luau"))()]])
    Library:Notify("加载链接已复制到剪贴板。")
end })
Toggles.KnobFarm:OnChanged(function(v) if not v then Globals.KnobFarmStarted = false end end)
local FloorsAuto = Tabs.Floors:AddRightGroupbox("自动化")
FloorsAuto:AddToggle("AutoSteerMinecart", { Text="自动驾驶矿车", Default=false,
    Disabled = not CheckCompat({"require"}), DisabledTooltip = Globals.IncompatibleMessage })
FloorsAuto:AddSlider("AutoSteerMinecartTurnDistance", { Text="矿车转向距离", Min=20, Max=40, Default=30, Rounding=0 })
FloorsAuto:AddSlider("AutoSteerMinecartDuckDistance", { Text="矿车蹲下距离", Min=20, Max=40, Default=30, Rounding=0 })
FloorsAuto:AddDivider()
FloorsAuto:AddToggle("RoomsAutoWalk", { Text="自动 Rooms", Default=false })
FloorsAuto:AddSlider("RoomsAutoWalkPathfindTimeout", { Text="寻路超时", Min=0.5, Max=3, Default=1, Rounding=1 })
FloorsAuto:AddToggle("RoomsAutoWalkIgnoreA60", { Text="忽略 A-60", Default=false })
FloorsAuto:AddToggle("RoomsAutoWalkShowPathToggle", { Text="显示路径", Default=false })
Toggles.RoomsAutoWalkShowPathToggle:AddColorPicker("RoomsAutoWalkShowPathColor", { Text="路径颜色", Default=Color3.fromRGB(0,255,0), Transparency=0 })
FloorsAuto:AddToggle("RoomsAutoWalkSpoofFootsteps", { Text="欺骗脚步", Default=false,
    Disabled = not CheckCompat({"hookmetamethod","newcclosure","getnamecallmethod"}),
    DisabledTooltip = Globals.IncompatibleMessage })

Globals.AutoMinecartDucked = false
Globals.LastDuck = 0
Connections.AutoSteerMinecartDuckHandler = RunService.Heartbeat:Connect(function()
    if not Toggles.AutoSteerMinecart.Value or not Functions.GetMinecart() then return end
    if tick() - Globals.LastDuck < 0.1 then return end
    Globals.NearestTurnNode = Functions.GetNearestTurnNode()
    if not Globals.AutoMinecartDucked and Functions.GetNearestDuckBoard() then
        if Main_Game then pcall(function() Main_Game.crouch(true) end) end
        Globals.AutoMinecartDucked = true
    elseif not Functions.GetNearestDuckBoard() and Globals.AutoMinecartDucked then
        if Main_Game then pcall(function() Main_Game.crouch(false) end) end
        Globals.AutoMinecartDucked = false
    end
    Globals.LastDuck = tick()
end)

Toggles.RoomsAutoWalk:OnChanged(function()
    for _, o in Globals.RoomsNodesFolder:GetChildren() do
        if o.Name == "PathNode" then o:Destroy() end
    end
end)
Toggles.RoomsAutoWalkShowPathToggle:OnChanged(function(v)
    for _, o in Globals.RoomsNodesFolder:GetChildren() do
        if o.Name == "PathNode" then o.Transparency = v and 0.5 or 1 end
    end
end)
Options.RoomsAutoWalkShowPathColor:OnChanged(function(v)
    for _, o in Globals.RoomsNodesFolder:GetChildren() do
        if o.Name == "PathNode" then o.Color = v end
    end
end)

Functions.RoomsAutoWalk = {}
Functions.RoomsAutoWalk.GetNearestHidingSpot = function()
    local N = { Distance = math.huge, Object = nil }
    for _, o in Objects.HidingSpots do
        if o.PrimaryPart and o:FindFirstChild("HidePrompt") then
            local d = LocalPlayer:DistanceFromCharacter(o.PrimaryPart.Position)
            if d < N.Distance and o.PrimaryPart.Position.Y > -10 then
                local hp = o:FindFirstChild("HiddenPlayer", true)
                if hp and not hp.Value then N.Distance = d; N.Object = o end
            end
        end
    end
    return N.Object
end

local RoomsEntityList = { "RushMoving","AmbushMoving","BackdoorRush","A60","A120","CustomEntity","GlitchRush","GlitchAmbush" }
Functions.RoomsAutoWalk.GetPathfindTarget = function()
    for _, o in Workspace:GetChildren() do
        if table.find(RoomsEntityList, o.Name) and o.PrimaryPart then
            local y = o.PrimaryPart.Position.Y
            if y > -10 and y < 150 then
                if (o.Name == "A60" and not Toggles.RoomsAutoWalkIgnoreA60.Value) or o.Name ~= "A60" then
                    return Functions.RoomsAutoWalk.GetNearestHidingSpot() or CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
                end
            end
        end
    end
    return CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
end
Connections.RoomsAutoWalkHandler = RunService.Heartbeat:Connect(function()
    if Floor ~= "Rooms" or not Toggles.RoomsAutoWalk.Value or Globals.RoomsAutoWalkActive or not CollisionPart or LatestRoom.Value >= 1000 then return end
    Globals.RoomsAutoWalkActive = true
    local Path = PathfindingService:CreatePath({
        AgentCanJump = true, AgentCanClimb = false, WaypointSpacing = 4,
        AgentRadius = 1.5, AgentHeight = 1.5, Costs = { StuckPart = 8 }
    })
    if Toggles.RoomsAutoWalkIgnoreA60.Value and not Toggles.PositionSpoof.Value then
        Toggles.PositionSpoof:SetValue(true)
    end
    local target = Functions.RoomsAutoWalk.GetPathfindTarget()
    if not target then Globals.RoomsAutoWalkActive = false return end
    local targetPos
    if target.Name == "RoomExit" then targetPos = target.Position
    elseif target:FindFirstChild("HidePrompt") then
        for _, p in target:GetDescendants() do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        targetPos = target.PrimaryPart.Position
    end
    if CollisionPart.Anchored and not target:FindFirstChild("HidePrompt") then
        Character:SetAttribute("Hiding", true)
        if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then RemotesFolder.CamLock:FireServer() end
        Character:SetAttribute("Hiding", false)
    end
    local cr = CurrentRooms[tostring(LatestRoom.Value)]
    if cr and cr:FindFirstChild("Door") and cr.Door:FindFirstChild("Door") then cr.Door.Door.CanCollide = false end
    if not targetPos or LocalPlayer:DistanceFromCharacter(targetPos) >= 750 then
        Globals.RoomsAutoWalkActive = false; return
    end
    Path:ComputeAsync(CollisionPart.Position, targetPos)
    local wp = Path:GetWaypoints()
    if #wp == 0 then
        local exit = cr and cr:FindFirstChild("RoomExit")
        if exit then Humanoid:MoveTo(exit.Position) end
        Globals.RoomsAutoWalkActive = false; return
    end
    for _, n in Globals.RoomsNodesFolder:GetChildren() do
        if n.Name == "PathNode" then n:Destroy() end
    end
    for _, w in wp do
        local b = Instance.new("Part", Globals.RoomsNodesFolder)
        b.Transparency = Toggles.RoomsAutoWalkShowPathToggle.Value and 0.5 or 1
        b.Size = Vector3.one; b.Position = w.Position; b.Shape = Enum.PartType.Ball
        b.CanCollide = false; b.Anchored = true; b.Name = "PathNode"
        b.Color = Options.RoomsAutoWalkShowPathColor.Value; b.Material = Enum.Material.Neon
    end
    local stuck = false
    for _, w in wp do
        if stuck or not Toggles.RoomsAutoWalk.Value then break end
        local finished, start = false, tick()
        local c = RunService.RenderStepped:Connect(function()
            if stuck or not Toggles.RoomsAutoWalk.Value then finished = true return end
            local nt = Functions.RoomsAutoWalk.GetPathfindTarget()
            if nt and nt:FindFirstChild("HidePrompt") and not target:FindFirstChild("HidePrompt") then finished = true return end
            if target:FindFirstChild("HidePrompt") then
                local hp = target:FindFirstChild("HidePrompt")
                if LocalPlayer:DistanceFromCharacter(targetPos) < hp.MaxActivationDistance and Character:GetAttribute("Hiding") ~= true then
                    Functions.ForceFirePrompt(hp)
                end
            end
            local flat = Vector3.new(w.Position.X, RootPart.Position.Y, w.Position.Z)
            if LocalPlayer:DistanceFromCharacter(flat) < 5 then finished = true end
            Humanoid:MoveTo(w.Position)
        end)
        while not finished do
            if tick() - start > Options.RoomsAutoWalkPathfindTimeout.Value then
                local sb = Instance.new("Part", Globals.RoomsNodesFolder)
                sb.Transparency = 1; sb.Size = Vector3.one; sb.CFrame = Collision.CFrame
                sb.Shape = Enum.PartType.Ball; sb.CanCollide = false; sb.Anchored = true
                sb.Name = "StuckPart"
                local mod = Instance.new("PathfindingModifier", sb)
                mod.Label = "StuckPart"
                stuck = true; break
            end
            task.wait()
        end
        c:Disconnect()
        Humanoid:MoveTo(RootPart.Position)
    end
    Globals.RoomsAutoWalkActive = false
end)
Connections.FloorReplicatedHandler = FloorReplicated.DescendantAdded:Connect(function(Object)
    if Object.Name == "GlitchScreech" then
        Modules.GlitchScreech = Object
        if Toggles.RemoveScreech.Value then Object.Name = "GlitchScreech_Disabled" end
    end
end)
Connections.RoomsHandler = CurrentRooms.ChildAdded:Connect(function(Room)
    for _, o in Globals.RoomsNodesFolder:GetChildren() do
        if o.Name == "StuckPart" then o:Destroy() end
    end
    if Room:GetAttribute("RawName") and string.find(Room:GetAttribute("RawName"), "Eyestalk") then
        local Prev = nil
        local function CreateNode(pos)
            local n = Instance.new("Part", Globals.SeekNodesFolder)
            n.Size = Vector3.one; n.Transparency = 1; n.Anchored = true
            n.Position = pos; n.CanCollide = false; n.Name = "SeekLightNode"
            local pn = Prev or n; Prev = n
            local a0 = Instance.new("Attachment", n); local a1 = Instance.new("Attachment", pn)
            local b = Instance.new("Beam")
            b.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ShowEyestalkPathColor.Value),
                ColorSequenceKeypoint.new(1, Options.ShowEyestalkPathColor.Value) })
            b.FaceCamera = true; b.Width0 = 0.2; b.Width1 = 0.2; b.Brightness = 10
            b.LightInfluence = 0; b.LightEmission = 0; b.Enabled = true
            local vis = Toggles.ShowEyestalkPathToggle.Value and 0 or 1
            b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, vis), NumberSequenceKeypoint.new(1, vis) })
            b.Parent = Globals.SeekNodesFolder
            b.Attachment0 = a0; b.Attachment1 = a1
            table.insert(Objects.EyestalkHighlights, b)
        end
        Room:WaitForChild("RoomEntrance", 9e9); Room:WaitForChild("RoomExit", 9e9)
        while not Room:GetAttribute("PathFound") do
            if Toggles.ShowEyestalkPathToggle.Value then
                local ep = PathfindingService:CreatePath({ AgentCanJump = false, AgentCanClimb = false, WaypointSpacing = 2, AgentRadius = 1, AgentHeight = 1 })
                ep:ComputeAsync(RootPart.Position, Room.RoomExit.Position)
                if ep.Status == Enum.PathStatus.Success then
                    Room:SetAttribute("PathFound", true)
                    for _, w in ep:GetWaypoints() do CreateNode(w.Position); task.wait() end
                    break
                end
            end
            task.wait(0.25)
        end
    end
end)
local FloorsComplete = Tabs.Floors:AddRightGroupbox("自动完成任务")
FloorsComplete:AddButton({ Text="自动完成水泵阀门", DoubleClick=false, Func=function()
    if LatestRoom.Value < 100 or Floor ~= "Mines" then
        Functions.Notify({ Title="你必须在 200 号房间才能使用此功能" }); return
    end
    local isCutscene = false
    local cc = RemotesFolder.Cutscene.OnClientEvent:Connect(function() isCutscene = true; task.wait(7); isCutscene = false end)
    local function GetNextPump()
        local high = { Height = -69420, Object = nil }
        for _, o in Objects.Objectives do
            if o.Name == "WaterPump" and o:GetAttribute("Abysall_Completed") ~= true
                and o.PrimaryPart and o.PrimaryPart.Position.Y > high.Height then
                high.Object = o; high.Height = o.PrimaryPart.Position.Y
            end
        end
        return high.Object
    end
    Functions.Notify({ Title="正在尝试完成阀门", Body="请稍候" })
    task.spawn(function()
        while task.wait(0.1) do
            local p = GetNextPump()
            if not p then break end
            while task.wait(0.1) do
                if isCutscene then continue end
                Character:PivotTo(p:GetPivot())
                local pr = p:FindFirstChild("ValvePrompt", true)
                if pr then Functions.ForceFirePrompt(pr) end
                if p:GetAttribute("Abysall_Completed") then break end
            end
        end
        Functions.Notify({ Title="成功完成所有阀门" })
        cc:Disconnect()
    end)
end })
FloorsComplete:AddButton({ Text="自动完成礼物收集", DoubleClick=false, Func=function()
    local t = CurrentRooms:FindFirstChild("RippleExitDoor", true)
    if t then Character:PivotTo(t:GetPivot()) end
end })

local MenuBox = Tabs.Settings:AddRightGroupbox("菜单")
MenuBox:AddToggle("KeybindMenuOpen", { Default=Library.KeybindFrame.Visible, Text="显示快捷键面板",
    Callback=function(v) Library.KeybindFrame.Visible = v end })
MenuBox:AddDropdown("NotificationSide", { Values={"Left","Right"}, Default="Right", Text="通知弹出方向" })
Options.NotificationSide:OnChanged(function(v) Library:SetNotifySide(v) end)
MenuBox:AddDropdown("DPIDropdown", { Values={"50%","75%","100%","125%","150%","175%","200%"}, Default="100%", Text="界面缩放" })
Options.DPIDropdown:OnChanged(function(v) Library:SetDPIScale(tonumber(v:gsub("%%",""))) end)
MenuBox:AddSlider("UICornerSlider", { Text="界面圆角大小", Default=4, Min=0, Max=20, Rounding=0,
    Callback=function(v) Window:SetCornerRadius(v) end })
MenuBox:AddDivider()
MenuBox:AddLabel("菜单快捷键")
MenuBox:AddKeyPicker("MenuKeybind", { Default="RightShift", NoUI=true, Text="呼出/隐藏菜单" })
MenuBox:AddDivider()
MenuBox:AddButton({ Text="卸载脚本", DoubleClick=false, Func=function()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
    for o, c in pairs(ESPConnections) do pcall(function() c:Disconnect() end) end
    table.clear(ESPConnections)
    for _, o in ipairs(Workspace:GetDescendants()) do pcall(function() ESPLibrary:RemoveESP(o) end) end
    table.clear(EspObjects)
    pcall(function() ESPLibrary:Unload() end)
    for _, o in ipairs(Environment.gethui():GetChildren()) do
        pcall(function()
            local n = o.Name:lower()
            if n:find("esp") or n:find("highlight") or n == "doorsnotifycontainer" then o:Destroy() end
        end)
    end
    if Main_Game then pcall(function() Main_Game.fovtarget = 70; Main_Game.csgo = CFrame.new(); Main_Game.spring.Speed = 8 end) end
    pcall(function() Lighting.Ambient = OldLightingAmbient; Lighting.GlobalShadows = OldLightingGlobalShadows end)
    Library:Unload()
end })

FlyBody = Instance.new("BodyVelocity"); FlyBody.MaxForce = Vector3.new(9e9,9e9,9e9); FlyBody.P = 1250
ManipulateBody = Instance.new("BodyVelocity"); ManipulateBody.MaxForce = Vector3.new(9e9,9e9,9e9)
Globals.ThirdPersonParts = {}

Functions.HandleCharacter = function(NewCharacter)
    for _, k in ipairs({"MainHandler","JumpHandler","SlideHandler","LibraryCodeHandler1","LibraryCodeHandler2",
        "OxygenConnection","AnimationHandler","AutoHideConnection","AutoReviveHandler","SHMFixer",
        "AnticheatDisabler","AnticheatEnableDetector1","AnticheatEnableDetector2",
        "AutoSteerMinecartDuckHandler","AutoSolveAnchorsConnection","InfiniteJumpsConnection1",
        "InfiniteJumpsConnection2","FootstepHandler"}) do
        if Connections[k] then Connections[k]:Disconnect(); Connections[k] = nil end
    end
    while not LocalPlayer.PlayerGui:FindFirstChild("MainUI") do task.wait() end
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid", 9e9)
    RootPart = NewCharacter:FindFirstChild("HumanoidRootPart")
    Camera = Workspace.CurrentCamera
    Globals.MainUI = LocalPlayer.PlayerGui.MainUI
    Collision = NewCharacter:WaitForChild("Collision")
    CollisionPart = NewCharacter:FindFirstChild("CollisionPart") or NewCharacter:FindFirstChild("Collision")
    CollisionClone = Collision:Clone(); CollisionClone.Parent = NewCharacter; CollisionClone.Name = "CollisionClone"; CollisionClone.Massless = true
    CollisionPartClone = CollisionPart:Clone(); CollisionPartClone.Parent = NewCharacter; CollisionPartClone.Name = "CollisionPartClone"
    CollisionPartClone.CanCollide = false; CollisionPartClone.Massless = true
    if CollisionPartClone:FindFirstChild("CollisionCrouch") then CollisionPartClone.CollisionCrouch:Destroy() end
    OldJump = NewCharacter:GetAttribute("CanJump"); OldSlide = NewCharacter:GetAttribute("CanSlide")
    if Toggles.EnableCharacterJump.Value then Character:SetAttribute("CanJump", true) end
    if Toggles.EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end
    if CheckCompat({"require"}) then pcall(function() Main_Game = Environment.require(Globals.MainUI.Initiator.Main_Game) end) end
    if Main_Game and Toggles.RemoveCameraBobbing.Value then Main_Game.spring.Speed = 9e9 end
    if Main_Game and CheckCompat({"require"}) then
        pcall(function()
            local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
            local orig = Controls.GetMoveVector
            Globals.OriginalGetMoveVector = orig
            Controls.GetMoveVector = function(...)
                if Toggles.AutoSteerMinecart.Value and Floor == "Mines" then
                    local n = Globals.NearestTurnNode
                    if n and Functions.GetMinecart() then
                        local turn = n:GetAttribute("Turn")
                        return turn == "Left" and Vector3.new(-1,0,0) or turn == "Right" and Vector3.new(1,0,0) or Vector3.zero
                    end
                end
                return orig(...)
            end
        end)
    end
    CustomPhysics = PhysicalProperties.new(100,
        RootPart.CustomPhysicalProperties.Friction, RootPart.CustomPhysicalProperties.Elasticity,
        RootPart.CustomPhysicalProperties.FrictionWeight, RootPart.CustomPhysicalProperties.ElasticityWeight)
    for _, p in NewCharacter:GetDescendants() do
        if p:IsA("BasePart") then PartProperties[p] = p.CustomPhysicalProperties
            if Toggles.RemoveAcceleration.Value then p.CustomPhysicalProperties = CustomPhysics end end
    end
    Globals.ThirdPersonParts = {}
    for _, o in Character:GetDescendants() do
        if o:IsA("Accessory") and o:FindFirstChild("Handle") then table.insert(Globals.ThirdPersonParts, o.Handle) end
    end
    table.insert(Globals.ThirdPersonParts, Character:WaitForChild("Head"))
    Globals.OriginalC1 = Character.LowerTorso and Character.LowerTorso.Root and Character.LowerTorso.Root.C1
local MFrame = Globals.MainUI:FindFirstChild("MainFrame")
if MFrame and MFrame:FindFirstChild("SurgeVignette") then
    Globals.SurgeFrame = MFrame.SurgeVignette
    if Toggles.RemoveSurge.Value then Globals.SurgeFrame.Name = "SurgeVignette_Disabled" end
end
    local UIModules = Globals.MainUI.Initiator.Main_Game.RemoteListener.Modules
    Modules.A90 = UIModules:FindFirstChild("A90"); Modules.Screech = UIModules:FindFirstChild("Screech")
    Modules.Dread = UIModules:FindFirstChild("Dread"); Modules.SpiderJumpscare = UIModules:FindFirstChild("SpiderJumpscare")
    local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules")
    Modules.Void = ClientModules and ClientModules.EntityModules:FindFirstChild("Void")
Modules.Glitch = ClientModules and ClientModules.EntityModules:FindFirstChild("Glitch")
Modules.Shade  = ClientModules and ClientModules.EntityModules:FindFirstChild("Shade")
    if Toggles.RemoveScreech.Value and Modules.Screech then Modules.Screech.Name = "Screech_Disabled" end
    if Toggles.RemoveA90.Value and Modules.A90 then Modules.A90.Name = "A90_Disabled" end
    if Toggles.RemoveDread.Value and Modules.Dread then Modules.Dread.Name = "Dread_Disabled" end
    if Toggles.DisableTimothyJumpscare.Value and Modules.SpiderJumpscare then Modules.SpiderJumpscare.Name = "SpiderJumpscare_Disabled" end
    if Toggles.DisableHideVignette.Value then
        local v = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
        if v then v.Image = "Disabled" end
    end
    if Toggles.DisableEntityJumpscares.Value then
        local js = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
        if js then js.Name = "Jumpscares_Disabled" end
    end
    Globals.OldOxygen = Character:GetAttribute("Oxygen")
    Connections.OxygenConnection = Character:GetAttributeChangedSignal("Oxygen"):Connect(function()
        local n = Character:GetAttribute("Oxygen")
        if n < Globals.OldOxygen and Toggles.NotifyOxygen.Value then
            local m, s = math.floor(n/60), math.floor(n%60)
            Notify(string.format("氧气: %02d:%02d", m, s), 3)
        end
        Globals.OldOxygen = n
    end)
    Connections.AutoReviveHandler = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
        if LocalPlayer:GetAttribute("Alive") == false and Toggles.AutoRevive.Value and (Floor == "Fools" or Floor == "OldHotel") then
            while LocalPlayer:GetAttribute("Alive") ~= true do
                if RemotesFolder and RemotesFolder:FindFirstChild("Revive") then RemotesFolder.Revive:FireServer() end
                task.wait(0.5)
            end
        end
    end)
    Connections.AnticheatDisabler = Character:GetAttributeChangedSignal("Climbing"):Connect(function()
        if Character:GetAttribute("Climbing") == true and Toggles.DisableAnticheat.Value and not Globals.AnticheatDisabled then
            task.wait(0.25); Character:SetAttribute("Climbing", false)
            Functions.Notify({ Title="成功禁用反作弊", Body="过场动画或 halt 房间后需重新与梯子交互启用" })
            Globals.AnticheatDisabled = true
        end
    end)
    if RemotesFolder then
    local CutsceneRemote = RemotesFolder:FindFirstChild("Cutscene")
    if CutsceneRemote then
        Connections.AnticheatEnableDetector1 = CutsceneRemote.OnClientEvent:Connect(function(name)
            if Globals.AnticheatDisabled and not name:find("SewerSeek") then
                Globals.AnticheatDisabled = false
                Functions.Notify({ Title="反作弊已重新启用", Body="与梯子交互以再次禁用它" })
            end
        end)
    end
    local UseEnemyModuleRemote = RemotesFolder:FindFirstChild("UseEnemyModule")
    if UseEnemyModuleRemote then
        Connections.AnticheatEnableDetector2 = UseEnemyModuleRemote.OnClientEvent:Connect(function(m)
            if (m == "Void" or m == "Glitch") and Globals.AnticheatDisabled then
                Globals.AnticheatDisabled = false
                Functions.Notify({ Title="反作弊已重新启用", Body="与梯子交互以再次禁用它" })
            end
            if m == "Void" or m == "Glitch" then LocalPlayer:SetAttribute("CurrentRoom", LatestRoom.Value) end
        end)
    end
end
    Connections.JumpHandler = Character:GetAttributeChangedSignal("CanJump"):Connect(function()
        local v = Character:GetAttribute("CanJump")
        if (Toggles.EnableCharacterJump.Value and v ~= true) or not Toggles.EnableCharacterJump.Value then OldJump = v end
        if Toggles.EnableCharacterJump.Value then Character:SetAttribute("CanJump", true) end
    end)
    Connections.SlideHandler = Character:GetAttributeChangedSignal("CanSlide"):Connect(function()
        local v = Character:GetAttribute("CanSlide")
        if (Toggles.EnableCharacterSlide.Value and v ~= true) or not Toggles.EnableCharacterSlide.Value then OldSlide = v end
        if Toggles.EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end
    end)
    Connections.InfiniteJumpsConnection1 = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space and Toggles.InfiniteJumps.Value and not Globals.IsTyping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    Connections.FootstepHandler = Character.ChildAdded:Connect(function(o)
    if o:IsA("Sound") and o.Name == "Sound" and Toggles.RemoveFootstepSounds.Value then o.Volume = 0 end
end)

Connections.AnimationHandler = Character.ChildAdded:Connect(function()
    local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    local Tool
    for _, Name in ToolNames do
        Tool = Character:FindFirstChild(Name)
        if Tool then break end
    end
    if not Tool then return end
    local UseAnim = Tool:FindFirstChild("use", true) or Tool:FindFirstChild("promptanim", true)
    if UseAnim then
        UseAnim = Humanoid:LoadAnimation(UseAnim)
        UseAnim.Priority = Enum.AnimationPriority.Action4
        Globals.UseAnimation = UseAnim
    end
    local UseAnimBreak = Tool:FindFirstChild("usefinish", true) or Tool:FindFirstChild("promptanimend", true) or Tool:FindFirstChild("lockpickuse", true)
    if UseAnimBreak then
        UseAnimBreak = Humanoid:LoadAnimation(UseAnimBreak)
        UseAnimBreak.Priority = Enum.AnimationPriority.Action4
        Globals.UseAnimationBreak = UseAnimBreak
    end
end)

Connections.LibraryCodeHandler2 = Character.ChildAdded:Connect(function(c)
        if (c.Name == "LibraryHintPaper" or c.Name == "LibraryHintPaperHard") and Toggles.NotifyLibraryCode.Value then
            local code = Functions.GetLibraryCode()
            if code and not code:find("_") and not Globals.LibraryCodeFound then
                Functions.Notify({ Title="找到挂锁密码！", Body="密码是：'" .. code .. "'", Time=15 })
                Globals.LibraryCodeFound = true
            end
        end
    end)
    Connections.AutoHideConnection = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoClosetToggle.Value or tick() - Globals.LastAutoHide <= 0.1 then return end
        local e = Functions.GetNearestEntity(true, Options.AutoClosetEntityList.Value)
        if e then
            local c = Functions.GetNearestHidingSpot()
            if Character:GetAttribute("Hiding") ~= true and c then Functions.FirePrompt(c.HidePrompt) end
        elseif Character:GetAttribute("Hiding") == true then
            if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then RemotesFolder.CamLock:FireServer() end
        end
        Globals.LastAutoHide = tick()
    end)
    Connections.AutoSolveAnchorsConnection = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoSolveAnchors.Value then return end
        if not Globals.MainUI:FindFirstChild("AnchorHintFrame") then return end
        if tick() - Globals.LastAutoAnchor <= 0.1 then return end
        local a = Functions.GetCurrentAnchor()
        if a and LocalPlayer:DistanceFromCharacter(a.PrimaryPart.Position) < a.ActivateEventPrompt.MaxActivationDistance
            and not a:GetAttribute("Activated") then
            a:WaitForChild("AnchorRemote"):InvokeServer(Globals.MainUI.AnchorHintFrame.Code.Text)
        end
        Globals.LastAutoAnchor = tick()
    end)
local RayParams = RaycastParams.new(); RayParams.FilterType = Enum.RaycastFilterType.Exclude
    Globals.LastAnimationCheck = tick(); Globals.LastCrouchFire = tick()
    Connections.MainHandler = RunService.RenderStepped:Connect(function()
        if Workspace:FindFirstChild("Camera") then Camera = Workspace:FindFirstChild("Camera") end
        if not Character or not Humanoid or not RootPart then return end
        if Toggles.SpeedBoostToggle.Value then Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + Options.SpeedBoostSlider.Value end
        Globals.IsEyes = Workspace:FindFirstChild("Eyes") ~= nil or Workspace:FindFirstChild("Lookman") ~= nil
        Globals.IsLookman = Workspace:FindFirstChild("BackdoorLookman") ~= nil
        if Toggles.AmbientToggle.Value then
            TweenService:Create(Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = Options.AmbientColor.Value }):Play()
        end
        if Main_Game then
            if Toggles.RemoveCameraShake.Value then Main_Game.csgo = CFrame.new() end
            Main_Game.fovtarget = Options.FieldOfView.Value
        else Camera.FieldOfView = Options.FieldOfView.Value end
        if Globals.SelfKilled and Globals.MainUI:FindFirstChild("Statistics") then
            Globals.MainUI.Statistics.Death.Text = "Died to Abysall Hub"
        end
        if (Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value) and RemotesFolder and RemotesFolder:FindFirstChild("Crouch") then
            RemotesFolder.Crouch:FireServer(true, true)
        end
        if Floor ~= "Fools" and Floor ~= "OldHotel" and not Camera:FindFirstChild("MinecartRig") then
            RootPart.CanCollide = false
        end
        for _, p in Character:GetChildren() do if p:IsA("BasePart") then p.CanCollide = false end end
        if Floor == "OldHotel" or Floor == "Fools" then
            local spoofOffset = Toggles.PositionSpoof.Value and Functions.GetNearestEntity() and 200
                or Toggles.FigureGodmode.Value and Functions.GetNearestFigure() and 200 or 0
            Globals.SpoofOffset = spoofOffset
            Collision.Position = RootPart.Position + Vector3.new(0, spoofOffset, 0); Collision.CanCollide = false
            if Floor == "Fools" and Collision:FindFirstChild("CollisionCrouch") then
                Collision.CollisionCrouch.CanCollide = false
                if CollisionClone:FindFirstChild("CollisionCrouch") then CollisionClone.CollisionCrouch.CanCollide = false end
            end
            RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
        else
            Collision.CanCollide = false
            if Collision:FindFirstChild("CollisionCrouch") then Collision.CollisionCrouch.CanCollide = false end
            if CollisionClone:FindFirstChild("CollisionCrouch") then
                local cr = Functions.IsCrouching()
                CollisionClone.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or cr)
                CollisionClone.CollisionCrouch.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or not cr)
            else
                RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
            end
            if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") and Globals.OriginalC1 then
                Character.LowerTorso.Root.C1 = Globals.OriginalC1 * CFrame.new(0, Toggles.PositionSpoof.Value and -2.346 or 0, 0)
            end
            local spoofY = Toggles.PositionSpoof.Value and 2.328 or 0.18
            Collision.Position = RootPart.Position + Vector3.new(0, spoofY, 0)
            CollisionPart.Position = RootPart.Position + Vector3.new(0, spoofY, 0)
        end
        CollisionClone.CollisionGroup = Collision.CollisionGroup
        CollisionClone.Position = RootPart.Position + Vector3.new(0, Toggles.PositionSpoof.Value and 1.75 or 0.18, 0)
        if Toggles.FlyToggle.Value then FlyBody.Parent = RootPart; FlyBody.Velocity = Functions.GetFlyVelocity() * Options.FlySpeed.Value
        else FlyBody.Parent = nil end
        if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "速度" then
            ManipulateBody.Parent = RootPart; ManipulateBody.Velocity = RootPart.CFrame.LookVector * 2.25
        else ManipulateBody.Parent = nil end
        if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "转向"
            and Floor ~= "Fools" and Floor ~= "OldHotel" then
            Character:PivotTo(Camera:GetPivot() * CFrame.new(0, 0, 2560))
        end
        local doEyes = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
        if doEyes and RemotesFolder and RemotesFolder:FindFirstChild("MotorReplication") then
            if Floor == "Fools" or Floor == "OldHotel" then
                RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
            else RemotesFolder.MotorReplication:FireServer(-650) end
        end
        if RemotesFolder and RemotesFolder:FindFirstChild("Crouch") and tick() - Globals.LastCrouchFire > 0.1 then
            local c = Functions.IsCrouching() or Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value
            RemotesFolder.Crouch:FireServer(c, true); Globals.LastCrouchFire = tick()
        end
        if tick() - Globals.LastAnimationCheck > 0.1 then
            local sliding = false
            for _, a in Humanoid:GetPlayingAnimationTracks() do if a.Name == "Slide" then sliding = true break end end
            Globals.Sliding = sliding; Globals.LastAnimationCheck = tick()
        end
        Character:SetAttribute("Sliding", Globals.Sliding or false)
        if Character:GetAttribute("Crouching") ~= Functions.IsCrouching() then
            Character:SetAttribute("Crouching", Functions.IsCrouching())
        end
        if Toggles.ThirdPersonToggle.Value then
            RayParams.FilterDescendantsInstances = { Character }
            local tp = CFrame.new(Options.ThirdPersonOffsetX.Value, Options.ThirdPersonOffsetY.Value, Options.ThirdPersonOffsetZ.Value)
            local dir = (Camera.CFrame * tp).Position - Camera.CFrame.Position
            local wall = Workspace:Spherecast(Camera.CFrame.Position, 0.2, dir, RayParams)
            if Toggles.ThirdPersonWallCheck.Value and wall and wall.Instance.CanCollide then
                local pos = Camera.CFrame.Position + dir.Unit * wall.Distance
                Camera.CFrame = CFrame.new(pos, pos + Camera.CFrame.LookVector)
            else Camera.CFrame = Camera.CFrame * tp end
        end
        for _, p in Globals.ThirdPersonParts do
            if p and p.Parent then
                p.Transparency = Toggles.ThirdPersonToggle.Value and 0 or 1
                p.LocalTransparencyModifier = Toggles.ThirdPersonToggle.Value and 0 or 1
            end
        end
        if Toggles.RemoveClosetDelay.Value and Humanoid.MoveDirection ~= Vector3.zero
            and (CollisionPart.Anchored or RootPart.Anchored)
            and Character:GetAttribute("AnimatingClient") ~= true and Character:GetAttribute("Hiding") == true then
            if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then RemotesFolder.CamLock:FireServer() end
        end
        if Globals.SpectateEntity and Toggles.AutoClosetToggle.Value and Toggles.SpectateEntityToggle.Value
            and Globals.SpectateEntity.PrimaryPart then
            local p = Globals.SpectateEntity
            if Options.SpecateEntityMode.Value == "玩家到实体" then
                Camera.CFrame = CFrame.lookAt(Character.Head.Position, p.PrimaryPart.Position)
            else Camera.CFrame = CFrame.lookAt(p.PrimaryPart.Position, Character.Head.Position) end
        end
    end)
end

-- Hooks
if CheckCompat({"hookmetamethod","newcclosure","getnamecallmethod"}) then
    local MainHook
    MainHook = Environment.hookmetamethod(game, "__namecall", Environment.newcclosure(function(Self, ...)
        local Args = { ... }; local Method = Environment.getnamecallmethod()
        if Self and Self.Name == "Crouch" and Method == "FireServer" then
            if Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value then Args[1] = true end
            Args[2] = true
        end
        if Self and (Self.Name == "ClutchHeartbeat" or Self.Name == "HideMonster")
            and Method == "FireServer" and Toggles.AutoHeartbeatMinigame.Value then return end
        if Self and Self.Name == "MotorReplication" and Method == "FireServer" then
            local bypass = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
            if bypass then
                if Floor == "Fools" or Floor == "OldHotel" then
                    Args[1] = 0; Args[2] = (Globals.SpoofOffset == 200 and 65 or -65); Args[3] = 0; Args[4] = false
                else Args[1] = -650 end
            end
        end
        return MainHook(Self, table.unpack(Args))
    end))
    local OtherHook
    OtherHook = Environment.hookmetamethod(game, "__index", Environment.newcclosure(function(Self, Property)
        local Real = OtherHook(Self, Property)
        if Property == "MoveDirection" and Self == Humanoid and Globals.RoomsAutoWalkActive
            and Toggles.RoomsAutoWalkSpoofFootsteps.Value and Floor == "Rooms" and not Character:GetAttribute("Hiding") then
            return RootPart.CFrame.LookVector
        end
        return Real
    end))
end

-- 对象队列
Globals.ObjectQueue = {}
local AllowedInstances = {}
for _, n in ipairs({"Lava","GoldPile","KeyObtain","FuseObtain","MinesGenerator","JeffTheKiller","Snare","FakeDoor","DoorFake",
    "SideroomSpace","ChestBox","ChestBoxLocked","Chest_Vine","Locker_Small_Locked","Toolbox","Toolbox_Locked","Wardrobe",
    "Wardrobe-FOOLS26","Toolshed","Toolshed_Small","Bed","MinesAnchor","Double_Bed","RetroWardrobe","Backdoor_Wardrobe",
    "Rooms_Locker","Rooms_Locker_Fridge","Locker_Large","FigureRig","FigureRagdoll","TimerLever","Lever","Seek_Arm",
    "ChandelierObstruction","ScaryWall","Ladder","CircularVent","Dumpster","SquareGrate","TriggerEventCollision",
    "GrumbleRig","GiggleCeiling","MinesGateButton","ElectricalKeyObtain","LibraryHintPaper","WaterPump","CringlePresent",
    "Wheel","PickupItem","LiveHintBook","LiveBreakerPolePickup","LeverForGate","GloomPile","SeekFloodline","Door",
    "Green_Herb","Bridge","MouseHole","BananaPeel","PowerupPad","IndustrialGate","CollisionFloor","ElevatorCar",
    "Wax_Door","ThingToOpen","MovingDoor","StardustPickup","Hole","Groundskeeper","MandrakeLive","GardenGateButton",
    "LotusPetalPickup","VineGuillotine","LiveEntityBramble","RiftSpawn","ElevatorBreaker","RunnerNodes","PathLights",
    "DuckBoard","Padlock","EyestalkEndCutscene","MinecartRig","SeekMovingNewClone","ArchivesPackageDeposit",
    "SalvageChute","Water"}) do AllowedInstances[n] = true end

local function QueueObject(o)
    if not AllowedInstances[o.Name] and o.ClassName ~= "ProximityPrompt" and o.Parent ~= CurrentRooms and not ItemNames[o.Name] then return end
    table.insert(Globals.ObjectQueue, o)
end
for _, o in Workspace:GetDescendants() do task.spawn(function() QueueObject(o) end) end
table.insert(Connections, Workspace.DescendantAdded:Connect(QueueObject))
local SafeCall = function(fn, ...) local ok, err = pcall(fn, ...); if not ok and err then warn("[KL]"..tostring(err)) end end
Functions.HandleObject = function(Object)
    if CurrentRooms then
        for _, r in CurrentRooms:GetChildren() do
            if Object:IsDescendantOf(r) then Object:SetAttribute("ParentRoom", tonumber(r.Name)); break end
            task.wait()
        end
    end
    if Object.Parent == CurrentRooms then
        local fd = Object:GetAttribute("Firedamp")
        Object:SetAttribute("Firedamp_Old", fd ~= nil and fd or false)
        if Toggles.DisableFiredampEffect.Value then Object:SetAttribute("Firedamp", false) end
    end
    local Name = Object.Name
    if Object.ClassName == "ProximityPrompt" and not Object:GetAttribute("FakePrompt") then
        if Object:HasTag("DisableWhenEnabledOnClient") then Object:RemoveTag("DisableWhenEnabledOnClient") end
        Object:SetAttribute("HoldDuration_Old", Object.HoldDuration)
        Object:SetAttribute("RequiresLineOfSight_Old", Object.RequiresLineOfSight)
        Object:SetAttribute("MaxActivationDistance_Old", Object.MaxActivationDistance)
        if Toggles.InstantPrompts.Value then Object.HoldDuration = 0 end
        if Toggles.PromptClip.Value then Object.RequiresLineOfSight = false end
        if Options.PromptReachSlider then
        Object.MaxActivationDistance = Object:GetAttribute("MaxActivationDistance_Old") * Options.PromptReachSlider.Value
    end

    local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    if CheckCompat({"fireproximityprompt"}) and Floor ~= "OldHotel" and Floor ~= "Fools" then
        local IsLockPrompt = LockPromptNames[Object.Name]
            or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
            or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")

        if IsLockPrompt then
            local FakePrompt = Object:Clone()
            FakePrompt:SetAttribute("FakePrompt", true)
            task.wait()
            FakePrompt.Parent = Object.Parent

            FakePrompt:SetAttribute("HoldDuration_Old", Object:GetAttribute("HoldDuration_Old"))
            FakePrompt:SetAttribute("RequiresLineOfSight_Old", Object:GetAttribute("RequiresLineOfSight_Old"))
            FakePrompt:SetAttribute("MaxActivationDistance_Old", Object:GetAttribute("MaxActivationDistance_Old"))

            FakePrompt.HoldDuration = Object.HoldDuration
            FakePrompt.RequiresLineOfSight = Object.RequiresLineOfSight
            FakePrompt.MaxActivationDistance = Object.MaxActivationDistance

            if Toggles.InstantPrompts.Value then FakePrompt.HoldDuration = 0 end
            if Toggles.PromptClip.Value then FakePrompt.RequiresLineOfSight = false end
            FakePrompt.MaxActivationDistance = FakePrompt:GetAttribute("MaxActivationDistance_Old") * Options.PromptReachSlider.Value

            FakePrompts[FakePrompt] = Object
            pcall(function() Object.Parent = Globals.PromptContainer end)

            local FPEnabledConn = Object:GetPropertyChangedSignal("Enabled"):Connect(function()
                FakePrompt.Enabled = Object.Enabled
            end)
            Object:GetPropertyChangedSignal("ActionText"):Once(function()
                Object.Parent = FakePrompt.Parent
                FakePrompt:Destroy()
                FPEnabledConn:Disconnect()
            end)
            Object.Destroying:Once(function()
                FakePrompt:Destroy()
                FPEnabledConn:Disconnect()
            end)
            table.insert(Connections, FPEnabledConn)
            table.insert(Objects.Prompts, FakePrompt)

            FakePrompt.Enabled = false
            task.wait()
            FakePrompt.Enabled = Object.Enabled
            return
        end
    end
    table.insert(Objects.Prompts, Object); return
end
local objectiveNames = { "KeyObtain","ElectricalKeyObtain","TimerLever","LiveHintBook","LibraryHintPaper","PickupItem",
    "LiveBreakerPolePickup","MinesAnchor","WaterPump","CringlePresent","LeverForGate","MinesGenerator","FuseObtain",
        "MinesGateButton","GardenGateButton","ArchivesPackageDeposit","SalvageChute","VineGuillotine" }
    for _, on in ipairs(objectiveNames) do
        if Name == on then
            table.insert(Objects.Objectives, Object)
            if Toggles.ObjectiveESPToggle.Value then
                local lbl = ObjectiveLabels[Name] or Name
                if Name == "MinesAnchor" and Object:FindFirstChild("Sign") then lbl = "锚点 [" .. Object.Sign.TextLabel.Text .. "]"
                elseif Name == "WaterPump" and Object:FindFirstChild("Wheel") then Functions.AddESP({ Object=Object.Wheel, Text="水泵", Color=Options.ObjectiveESPColor.Value }, true)
                elseif Name == "VineGuillotine" and Object:FindFirstChild("Lever") then Functions.AddESP({ Object=Object.Lever, Text="藤蔓拉杆", Color=Options.ObjectiveESPColor.Value }, true) end
                Functions.AddESP({ Object=Object, Text=lbl, Color=Options.ObjectiveESPColor.Value }, true)
            end
            break
        end
    end
    if Name == "Door" and Object.Parent and tonumber(Object.Parent.Name) then
        local parts = {}
        for _, c in Object:GetChildren() do if c.Name == "Door" and c:IsA("BasePart") then table.insert(parts, c) end end
        if #parts == 2 then
            local m = Instance.new("Model", Object); m.Name = "HighlightModel"
            Instance.new("Humanoid", m).Name = "HighlightHumanoid"
            m:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
            for _, p in parts do
                local hp = Instance.new("Part", m); hp.Transparency = 0.999; hp.Size = p.Size; hp.CanCollide = false
                hp.CFrame = p.CFrame; hp.Name = "HighlightPart"; hp:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
                local w = Instance.new("WeldConstraint", hp); w.Part0 = hp; w.Part1 = p; w.Enabled = true
            end
            table.insert(Objects.Doors, m)
            if Toggles.DoorESPToggle.Value then
                Functions.AddESP({ Object=m, Text="门 " .. Functions.GetDoorNumber(Object), Color=Options.DoorESPColor.Value }, true)
            end
        else
            local root = Object:FindFirstChild("Door")
            if root then
                local hp = Instance.new("Part", Object); hp.Transparency = 0.999; hp.Size = root.Size; hp.CanCollide = false
                hp.CFrame = root.CFrame; hp.Name = "HighlightPart"; hp:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
                local w = Instance.new("WeldConstraint", hp); w.Part0 = hp; w.Part1 = root; w.Enabled = true
                Instance.new("Humanoid", Object).Name = "HighlightHumanoid"
                table.insert(Objects.Doors, hp)
                if Toggles.DoorESPToggle.Value then
                    Functions.AddESP({ Object=hp, Text="门 " .. Functions.GetDoorNumber(Object), Color=Options.DoorESPColor.Value }, true)
                end
            end
        end
        local last = tick()
        local c = RunService.Heartbeat:Connect(function()
            if Object:FindFirstChild("Door") and Object:FindFirstChild("ClientOpen") then
                if LocalPlayer:DistanceFromCharacter(Object.Door.Position) < 75 and tick() - last > 0.1
                    and (Toggles.DoorReachToggle.Value or Functions.GetMinecart()) then
                    Object.ClientOpen:FireServer(); last = tick()
                end
            end
        end)
        Object:WaitForChild("Door"):WaitForChild("Open").Played:Once(function() c:Disconnect() end)
        table.insert(Connections, c)
    elseif Name == "Ladder" then
        table.insert(Objects.Ladders, Object)
        if Toggles.LadderESPToggle.Value then Functions.AddESP({ Object=Object, Text="梯子", Color=Options.LadderESPColor.Value }, true) end
    elseif HidingSpotLabels[Name] then
        table.insert(Objects.HidingSpots, Object)
        if Toggles.HidingSpotESPToggle.Value then Functions.AddESP({ Object=Object, Text=HidingSpotLabels[Name], Color=Options.HidingSpotESPColor.Value }, true) end
    elseif Name == "ChestBox" or Name == "ChestBoxLocked" or Name == "Toolbox" or Name == "Toolbox_Locked"
        or Name == "Chest_Vine" or Name == "Toolshed_Small" or Name == "Locker_Small_Locked" or Name == "MouseHole" then
        table.insert(Objects.Chests, Object)
        if Toggles.ChestESPToggle.Value then
            local lbl = ChestLabels[Name]
            if lbl == true then
                if Name == "ChestBox" then lbl = "箱子" elseif Name == "ChestBoxLocked" then lbl = "上锁箱子"
                elseif Name == "Toolbox" then lbl = "工具箱" elseif Name == "Toolbox_Locked" then lbl = "上锁工具箱" end
            end
            if lbl then Functions.AddESP({ Object=Object, Text=lbl, Color=Options.ChestESPColor.Value }, true) end
        end
    elseif ItemNames[Name] and Object:FindFirstChild("ModulePrompt") then
        table.insert(Objects.Items, Object)
        if Toggles.ItemESPToggle.Value then
            Functions.AddESP({ Object=Object, Text=ItemNames[Name], Color=Options.ItemESPColor.Value }, Object:GetAttribute("ParentRoom") ~= nil)
        end
        if Toggles.NotifyItemsToggle.Value and Options.NotifyItemList.Value[ItemNames[Name]] and Object.Parent and Object.Parent.Name ~= "Drops" then
            local b = nil
            if Toggles.NotifyItemsShowDistance.Value and Object.PrimaryPart then
                b = "距离你 " .. math.round(LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)) .. " 格"
            end
            Functions.Notify({ Title=ItemNames[Name] .. " 已出现", Body=b })
        end
    elseif Name == "GoldPile" and Object:GetAttribute("GoldValue") then
        table.insert(Objects.Currency, Object)
        if Toggles.CurrencyESPToggle.Value then Functions.AddESP({ Object=Object, Text="金币堆 [" .. Object:GetAttribute("GoldValue") .. "]", Color=Options.CurrencyESPColor.Value }, true) end
    elseif Name == "StardustPickup" then
        table.insert(Objects.Currency, Object)
        if Toggles.CurrencyESPToggle.Value then Functions.AddESP({ Object=Object, Text="星尘", Color=Options.CurrencyESPColor.Value }, true) end
    elseif Name == "Lava" then
        if Toggles.BypassKillbricks.Value then Object.CanTouch = false end
        table.insert(Objects.Obstructions, Object)
    elseif Name == "ScaryWall" then
        for _, p in Object:GetDescendants() do
            if p:IsA("BasePart") then p.CanTouch = not Toggles.BypassSeekingWall.Value; p.CanCollide = not Toggles.BypassSeekingWall.Value end
        end
        table.insert(Objects.Obstructions, Object)
    elseif Name == "Seek_Arm" or Name == "ChandelierObstruction" then
        for _, p in Object:GetDescendants() do
            if p:IsA("BasePart") then p.CanTouch = not Toggles.BypassSeekObstructions.Value; table.insert(Objects.SeekObstructions, p) end
        end
    elseif Name == "SeekFloodline" then
        Object.CanCollide = Toggles.BypassSeekObstructions.Value
        table.insert(Objects.SeekObstructions, Object)
    elseif Name == "Snare" then
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Snare"] then
            Functions.AddESP({ Object=Object, Text="Snare", Color=Options.EntityESPColor.Value }, true)
        end
        for _, p in Object:GetDescendants() do
            if p:IsA("BasePart") then p.CanTouch = not Toggles.BypassSnare.Value end
        end
    elseif Name == "GiggleCeiling" then
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Giggle"] then
            Functions.AddESP({ Object=Object, Text="Giggle", Color=Options.EntityESPColor.Value }, true)
        end
        if Toggles.BypassGiggle.Value and Object:FindFirstChild("Hitbox") then Object.Hitbox.CanTouch = false end
    elseif Name == "GloomPile" then
        table.insert(Objects.Entities, Object)
        if Toggles.BypassGloombatEggs.Value then
            for _, p in Object:GetDescendants() do if p:IsA("BasePart") then p.CanTouch = false end end
        end
    elseif Name == "BananaPeel" then
        table.insert(Objects.Entities, Object)
        if Toggles.BypassBanana.Value then Object.CanTouch = false end
    elseif Name == "JeffTheKiller" then
        table.insert(Objects.Entities, Object)
        if Toggles.BypassJeff.Value then
            for _, p in Object:GetDescendants() do if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false end end
            if Object:FindFirstChild("Humanoid") then Object.Humanoid.Health = 0 end
        end
    elseif Name == "SideroomSpace" then
        table.insert(Objects.Entities, Object)
        if Toggles.BypassVacuum.Value and Object:FindFirstChild("Collision") then
            Object.Collision.CanCollide = true; Object.Collision.CanTouch = false
        end
    elseif Name == "GrumbleRig" then
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Grumble"] then
            Functions.AddESP({ Object=Object, Text="Grumble", Color=Options.EntityESPColor.Value }, true)
        end
    elseif Name == "LiveEntityBramble" then
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Bramble"] then
            Functions.AddESP({ Object=Object, Text="Bramble", Color=Options.EntityESPColor.Value }, true)
        end
    elseif Name == "Groundskeeper" then
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Groundskeeper"] then
            Functions.AddESP({ Object=Object, Text="Groundskeeper", Color=Options.EntityESPColor.Value }, true)
        end
    elseif Name == "Figure" or Name == "FigureRig" or Name == "FigureRagdoll" then
        for _, p in Object:GetDescendants() do if p:IsA("BasePart") then p.CanTouch = false end end
        table.insert(Objects.Entities, Object)
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Figure"] then
            Functions.AddESP({ Object=Object, Text="Figure", Color=Options.EntityESPColor.Value }, true)
        end
        if Toggles.RemoveFigure.Value and CheckCompat({"isnetworkowner"}) then
            if Floor == "Mines" then
                for _, p in Object:GetDescendants() do
                    if p:IsA("BasePart") then task.spawn(function()
                        if Environment.isnetworkowner(p) then p.Position = Vector3.new(-49999,-49999,-49999) end
                    end) end
                end
            elseif Floor == "OldHotel" or Floor == "Fools" then
                for _, p in Object:GetDescendants() do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                        task.spawn(function() while Environment.isnetworkowner(p) do
                            p.Position = Vector3.new(math.random(-29999,29999), math.random(-29999,29999), math.random(-29999,29999)); task.wait()
                        end end)
                    end
                end
            end
        end
    elseif Name == "DoorFake" or Name == "FakeDoor" then
        table.insert(Objects.Entities, Object)
        if Toggles.BypassDupe.Value and Object:FindFirstChild("Hidden") then Object.Hidden.CanTouch = false end
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Dupe"] then
            Functions.AddESP({ Object=Object, Text="Dupe", Color=Options.EntityESPColor.Value }, true)
        end
    elseif Name == "ElevatorBreaker" then
        if Toggles.AutoBreakerBox.Value and not Globals.BreakerBoxNotified then
            Functions.Notify({ Title="与电箱交互", Body="它将自动解决谜题" }); Globals.BreakerBoxNotified = true
        end
        local sg = Object:FindFirstChild("SurfaceGui")
        if sg and sg:FindFirstChild("Frame") and sg.Frame:FindFirstChild("Code") then
            Connections.BreakerConnection = sg.Frame.Code:GetPropertyChangedSignal("Text"):Connect(function()
                if Toggles.AutoBreakerBox.Value and RemotesFolder and RemotesFolder:FindFirstChild("EBF") then RemotesFolder.EBF:FireServer() end
                Globals.BreakerBoxInteracted = true
            end)
        end
    elseif Name == "Padlock" then
        Connections.PadlockConnection = RunService.Heartbeat:Connect(function()
            if Object.PrimaryPart then
                local d = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
                if Toggles.AutoUnlockPadlockToggle.Value then
                    local c = Functions.GetLibraryCode()
                    if c and tonumber(c) and d < Options.AutoUnlockPadlockSlider.Value
                        and RemotesFolder and RemotesFolder:FindFirstChild("PL") then RemotesFolder.PL:FireServer(c) end
                end
                if Toggles.AutoLibraryGuessCode.Value and LatestRoom.Value == 50 and RemotesFolder and RemotesFolder:FindFirstChild("PL") then
                    local c = Functions.GetRandomCode(); if c then RemotesFolder.PL:FireServer(c) end
                end
            end
        end)
        Object.Destroying:Once(function()
            if Connections.PadlockConnection then Connections.PadlockConnection:Disconnect(); Connections.PadlockConnection = nil end
        end)
    elseif Name == "DuckBoard" then table.insert(Objects.SeekDuckBoards, Object)
    elseif Name == "MinecartRig" then Globals.Minecart = Object
    elseif Name == "TriggerEventCollision" and CheckCompat({"firetouchinterest"}) then
        if (Floor == "Fools" or Floor == "OldHotel") and Toggles.RemoveSeekTrigger.Value then
            task.spawn(function()
                while Object:IsDescendantOf(game) do
                    for _, p in Object:GetChildren() do
                        if p:IsA("BasePart") then
                            Environment.firetouchinterest(RootPart, p, 0); task.wait()
                            Environment.firetouchinterest(RootPart, p, 1)
                        end
                    end
                    task.wait()
                end
            end)
        end
        table.insert(Objects.EventTriggers, Object)
    elseif Name == "PathLights" then
        local objs = {}; for _, c in Object:GetChildren() do table.insert(objs, c) end
        local conn = Object.ChildAdded:Connect(function(c) table.insert(objs, c) end)
        table.insert(Connections, conn)
        local prev = nil
        task.spawn(function()
            while task.wait() do
                local lt = table.remove(objs, 1)
                if not lt then continue end
                if lt.Name ~= "SeekGuidingLight" or lt:GetAttribute("Highlighted") then continue end
                lt:SetAttribute("Highlighted", true)
                local n = Instance.new("Part", Globals.SeekNodesFolder)
                n.Size = Vector3.one; n.Transparency = 1; n.Anchored = true; n.CFrame = lt.CFrame
                n.CanCollide = false; n.Name = "SeekLightNode"
                local pn = prev or n; prev = n
                local a0 = Instance.new("Attachment", n); local a1 = Instance.new("Attachment", pn)
                local b = Instance.new("Beam")
                b.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ShowSeekPathColor.Value),
                    ColorSequenceKeypoint.new(1, Options.ShowSeekPathColor.Value) })
                b.FaceCamera = true; b.Width0 = 0.2; b.Width1 = 0.2; b.Brightness = 10
                b.LightInfluence = 0; b.LightEmission = 0; b.Enabled = true
                local vis = Toggles.ShowSeekPathToggle.Value and 0 or 1
                b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, vis), NumberSequenceKeypoint.new(1, vis) })
                b.Parent = Globals.SeekNodesFolder
                b.Attachment0 = a0; b.Attachment1 = a1
                table.insert(Objects.SeekHighlights, b)
            end
        end)
    elseif Name == "Bridge" then
        for _, c in Object:GetChildren() do
            if c.Name == "PlayerBarrier" and c.Size.Y == 2.75 and (c.Rotation.X == 0 or c.Rotation.X == 180) then
                local nb = c:Clone(); nb.CFrame = nb.CFrame * CFrame.new(0,0,-5)
                nb.Name = "SeekBridge_" .. tostring(math.random(1,1e9))
                nb.Size = Vector3.new(nb.Size.X, nb.Size.Y, 11); nb.Parent = Object
                nb.CanCollide = Toggles.BypassSeekObstructions.Value
                nb.Color = Color3.fromRGB(0,255,255)
                nb.Transparency = Toggles.BypassSeekObstructions.Value and 0 or 1
                nb.Material = Enum.Material.ForceField
                table.insert(Objects.SeekBridges, nb)
            end
            task.wait()
        end
    end
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local o = table.remove(Globals.ObjectQueue, 1)
    if o then SafeCall(Functions.HandleObject, o) end
end))

-- 提示动画修复器
Connections.PromptAnimationFixer1 = Services.ProximityPromptService.PromptButtonHoldBegan:Connect(function(Object)
    if not Object:GetAttribute("FakePrompt") then return end
    local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    local Tool
    for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

    local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    local IsLockPrompt = LockPromptNames[Object.Name]
        or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
        or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
    if IsLockPrompt then
        if Options.AutoInteractIgnoreList.Value["锁"] then return end
        local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
        local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
        local HasKey = false
        for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
        for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
        if not HasKey then return end
    end

    if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation and Globals.UseAnimationBreak then
        Globals.UseAnimationBreak:Stop()
        Globals.UseAnimation:Stop()
        Globals.UseAnimation:Play()
        if Tool.Name == "Shears" then pcall(function() Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end) end
    end
end)

-- 无限物品核心处理
Connections.InfiniteItemsHandler = Services.ProximityPromptService.PromptTriggered:Connect(function(Object)
    if not Object:GetAttribute("FakePrompt") then return end

    local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    local Tool
    for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

    local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    local IsLockPrompt = LockPromptNames[Object.Name]
        or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
        or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
    if IsLockPrompt then
        if Options.AutoInteractIgnoreList.Value["锁"] then return end
        local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
        local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
        local HasKey = false
        for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
        for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
        if not HasKey then return end
    end

    if Object.Parent and Object.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if Object.Parent and Object.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if Object.Parent and Object.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if Object.Parent and Object.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
    if Object.Parent and Object.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    if Object.Parent and Object.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    if Functions.HasItem("Shears", true) and IsLockPrompt and Object.Parent and Object.Parent.Name ~= "CuttableVines" and Object.Parent.Name ~= "Chest_Vine" and Object.Parent.Name ~= "Cellar" then return end

    if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation and Globals.UseAnimationBreak then
        Globals.UseAnimation:Stop()
        Globals.UseAnimationBreak:Stop()
        Globals.UseAnimationBreak:Play()
        if Tool.Name == "Shears" then pcall(function() Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end) end
    end

    local AnyTool = Character and Character:FindFirstChildOfClass("Tool")
    local ToolData = AnyTool and ItemNames[AnyTool.Name]
    if AnyTool and ToolData and Toggles.InfiniteItemsToggle.Value and Options.InfiniteItemsList.Value[ToolData] and Drops then
        Drops.ChildAdded:Once(function(NewTool)
            local Prompt = NewTool:FindFirstChild("ModulePrompt")
            local RealPrompt = FakePrompts[Object]
            if Prompt then Functions.FirePrompt(Prompt) end
            if RealPrompt then Functions.FirePrompt(RealPrompt) end
        end)
        Character.ChildAdded:Once(function(NewTool)
            if NewTool.Name == "Shears" then pcall(function() NewTool:WaitForChild("Handle"):WaitForChild("sound_promptend"):Play() end) end
        end)
        if RemotesFolder and RemotesFolder:FindFirstChild("DropItem") then
            RemotesFolder.DropItem:FireServer(AnyTool)
        end
    else
        local RealPrompt = FakePrompts[Object]
        if RealPrompt then Functions.FirePrompt(RealPrompt) end
    end
end)

-- 实体事件
local RusherAliases = { Rush=true, Ambush=true, Eyes=true, Lookman=true, Blitz=true,
    ["A-60"]=true, ["A-120"]=true, AR0xMBUSH=true, ["RNIUSHCG=="]=true, ["Custom Entity"]=true }
table.insert(Connections, Workspace.ChildAdded:Connect(function(Entity)
    local data = Entities[Entity.Name]; if not data then return end
    local ws = tick()
    while not Entity.PrimaryPart and tick() - ws < 10 do
        for _, c in Entity:GetChildren() do if c:IsA("BasePart") then Entity.PrimaryPart = c break end end
        task.wait()
    end
    if not Entity.PrimaryPart then return end
    task.wait(0.1)
    if LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position) >= 10000 then return end
    local alias = data.Alias
    if Options.EntityList.Value[alias] and Toggles.NotifyEntities.Value then
        local t = data.NotifyMessage.Title; local b = data.NotifyMessage.Body; local img = EntityIcons[Entity.Name]
        if Entity.Name == "RushMoving" and Entity.PrimaryPart.Name ~= "RushNew" then
            t = t:gsub("Rush", Entity.PrimaryPart.Name)
            if Entity.PrimaryPart:FindFirstChild("Attachment") then img = Entity.PrimaryPart.Attachment.ParticleEmitter.Texture end
            alias = Entity.PrimaryPart.Name
        end
        Functions.Notify({ Title=t, Body=b, Image=img, IsEntity=true,
            Time = Toggles.NotifyKeepNotifications and Toggles.NotifyKeepNotifications.Value and Entity or 5 })
        if Toggles.EntityChatToggle.Value then
            local msg = alias .. " " .. (Options.EntityChatMessage.Value or "已生成！")
            pcall(function()
                if ReplicatedStorage:FindFirstChild("DefaultChatSystemEvents") then
                    ReplicatedStorage.DefaultChatSystemEvents.SayMessageRequest:FireServer(msg, "All")
                end
            end)
        end
    end
    if Entity.Name ~= "GloombatSwarm" then
        if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value[alias] then
            if Entity.Name == "MonumentEntity" and Entity:FindFirstChild("Top") then
                Functions.AddESP({ Object=Entity.Top, Text=alias, Color=Options.EntityESPColor.Value })
            else Functions.AddESP({ Object=Entity, Text=alias, Color=Options.EntityESPColor.Value }) end
        end
        table.insert(Objects.Entities, Entity)
    end
    if RusherAliases[data.Alias] then
        Instance.new("Humanoid", Entity).Name = "HighlightHumanoid"
        if Entity.PrimaryPart then
            Entity.PrimaryPart.Transparency = 0.999
            Entity.PrimaryPart.Material = Enum.Material.Plastic
        end
    end
end))
-- 自动交互
local AIBlacklist = { HidePrompt=true,RiftPrompt=true,StarRiftPrompt=true,InteractPrompt=true,ClimbPrompt=true,
    DonatePrompt=true,DialogPrompt=true,DialoguePrompt=true,RevivePrompt=true,EnterPrompt=true,
    AnimatePrompt=true,ToolEventPrompt=true,Prompt=true,PropPrompt=true }
local TriggerDebounce = false
Functions.TriggerPrompt = function(P)
    if AIBlacklist[P.Name] then return end
    if not P.Parent or TriggerDebounce then return end
    if P.Parent.Name == "SeatPart" or P.Parent.Name == "Collider" or P.Name == "SeatPrompt" then return end
    if P.Parent.Name == "Flap" or P.Name == "TrashcanPrompt" then return end
    if P.Parent.Name == "Vendor_ShakelightVendingMachine" or P.Name == "VendorPrompt" then return end
    if P.Parent.Name == "ArchivesTerminal" then return end
    if P.Parent.Parent and P.Parent.Parent.Name == "ArchivesLargePrinter" then return end
    if P.Parent.Name == "PaperPlanePickup" or P.Parent.Name == "PaperPlane" then return end
    if P.Parent.Name == "StairwellTerminal" then return end
    if P:GetAttribute("_GateDisabled") == true then return end
    local pItem = Functions.HasItem(P.Parent.Name)
    if pItem and pItem:GetAttribute("Durability") and pItem:GetAttribute("DurabilityMax")
        and pItem:GetAttribute("Durability") >= pItem:GetAttribute("DurabilityMax") then return end
    local lockNames = { UnlockPrompt=true,SkullPrompt=true,LockPrompt=true,ThingToEnable=true,FusesPrompt=true }
    local isLock = lockNames[P.Name] or (P.Parent and P.Parent:GetAttribute("Locked") == true)
        or (P.Parent and P.Parent.Parent and P.Parent.Parent.Name == "Locker_Small_Locked" and P.Name == "ActivateEventPrompt")
    if isLock then
        if Options.AutoInteractIgnoreList.Value["锁"] then return end
        local keys = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
        local off = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
        local has = false
        for _, k in keys do if Functions.HasItem(k, true) then has = true break end end
        for _, k in off do if Functions.HasItem(k) then has = true break end end
        if not has then return end
    end
    if P.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if P.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if P.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    if P.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
    if P.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    if P.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    if Functions.HasItem("Shears", true) and isLock and P.Parent.Name ~= "CuttableVines" and P.Parent.Name ~= "Chest_Vine" and P.Parent.Name ~= "Cellar" then return end
    if P.Parent.Name == "GlitchCube" and Options.AutoInteractIgnoreList.Value["故障碎片"] then return end
    if P.Parent.Name == "KeyObtain" and (Functions.HasItem("Key") or Functions.HasItem("KeyBackdoor")) then return end
    if P.Parent.Name == "ElectricalKeyObtain" and Functions.HasItem("KeyElectrical") then return end
    if Drops and P:IsDescendantOf(Drops) and Options.AutoInteractIgnoreList.Value["掉落物品"] then return end
    if P.Parent.Name == "TrackLever" then return end
    if P.Name == "ActivateEventPrompt" and (P.ActionText == "Close" or P.Parent.Name == "ElevatorBreaker"
        or (P.Parent.Parent and P.Parent.Parent.Name == "IndustrialGate")) then return end
    if P.Name == "ActivateEventPrompt" and (P.Parent.Name == "Padlock" or P.Parent.Name == "MinesAnchor") then return end
    if P.Parent.Name == "LeverForGate" and P:GetAttribute("Interactions") then return end
    if P.Parent.Parent and (P.Parent.Parent.Name == "DoorFake" or P.Parent.Parent.Name == "FakeDoor") then return end
    if P.Parent:GetAttribute("JeffShop") and Options.AutoInteractIgnoreList.Value["Jeff 物品"] then return end
    if P.Name == "PushPrompt" and Options.AutoInteractIgnoreList.Value["矿车"] then return end
    if (P.Parent.Name == "GoldPile" or P.Parent.Name == "StardustPickup") and Options.AutoInteractIgnoreList.Value["货币"] then return end
    if P.Parent.Name == "Bandage" then
        local bp = Functions.HasItem("BandagePack")
        if Humanoid.Health >= Humanoid.MaxHealth and not bp then return end
    end
    if P.Parent.Name == "Battery" then
        local tool = Character:FindFirstChildOfClass("Tool"); local bp = Functions.HasItem("BatteryPack")
        if not tool and not bp then return end
    end
    if P.Parent.Name == "LibraryHintPaper" or P.Parent.Name == "PickupItem" then
        if Functions.HasItem("LibraryHintPaper") or Functions.HasItem("LibraryHintPaperHard") then return end
    end
    if P.Parent.Name == "AlarmClock" and Functions.HasItem("AlarmClock") then return end
    if P.Parent.Name == "KeyObtainFake" or P.Parent.Name == "TithingPlate" then return end
    Functions.FirePrompt(P); TriggerDebounce = true
    if Floor == "OldHotel" then task.wait() end
    TriggerDebounce = false
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    local Active = Toggles.AutoInteractToggle.Value or (Options.AutoInteractKeybind and Options.AutoInteractKeybind:GetState())
    if not Active then return end
    if tick() - Globals.LastAutoInteractFire < 1/60 then return end
    for _, p in Objects.Prompts do
        if p:GetAttribute("ParentRoom") and tonumber(p:GetAttribute("ParentRoom")) ~= tonumber(LocalPlayer:GetAttribute("CurrentRoom")) then continue end
        if p.Parent and (p.Parent:IsA("BasePart") or p.Parent:IsA("Model")) then
            local d = p.Parent:IsA("BasePart") and LocalPlayer:DistanceFromCharacter(p.Parent.Position)
                or LocalPlayer:DistanceFromCharacter(p.Parent:GetPivot().Position)
            if d <= p.MaxActivationDistance and (p.Enabled or p.Name == "LongPushPrompt" or p.Name == "BigPropPrompt") then
                task.spawn(Functions.TriggerPrompt, p)
            end
        end
    end
    Globals.LastAutoInteractFire = tick()
end))

-- 隐藏点透明更新
RunService.RenderStepped:Connect(function()
    local ch = LocalPlayer.Character; if not ch or not CurrentRooms then return end
    local hiding = ch:GetAttribute("Hiding") == true; local spot = nil
    if hiding then
        local r = CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
        if r then for _, o in r:GetDescendants() do
            if o:IsA("ObjectValue") and o.Name == "HiddenPlayer" and o.Value == ch then spot = o.Parent break end
        end end
    end
    if spot ~= LastHidingSpot then
        if LastHidingSpot and HidingSpotLabels[LastHidingSpot.Name] and Toggles.HidingSpotESPToggle.Value then
            local t = LastHidingSpot
            if t:IsA("Model") and t.Name == "CircularVent" then t = t:FindFirstChild("Grate") end
            if t then Functions.AddESP({ Object=t, Text=HidingSpotLabels[LastHidingSpot.Name], Color=Options.HidingSpotESPColor.Value }, true) end
        end
        if spot then
            local t = spot
            if t:IsA("Model") and t.Name == "CircularVent" then t = t:FindFirstChild("Grate") end
            if t then Functions.RemoveESP(t) end
        end
        LastHidingSpot = spot
    end
end)


table.insert(Connections, RunService.Heartbeat:Connect(function()
    if Toggles.KnobFarm.Value and Globals.KnobFarmStarted and not Globals.KnobFarmActive then
        Globals.KnobFarmActive = true
        if CheckCompat({"replicatesignal"}) then Environment.replicatesignal(LocalPlayer.Kill)
        elseif RemotesFolder and RemotesFolder:FindFirstChild("Underwater") then RemotesFolder.Underwater:FireServer(true) end
        while task.wait() do if LocalPlayer:GetAttribute("Alive") then break end end
        if RemotesFolder and RemotesFolder:FindFirstChild("Statistics") then RemotesFolder.Statistics:FireServer() end
        task.wait(0.25); Globals.KnobFarmActive = false
    end
    if tick() - (Globals.LastClean or 0) > 0.5 then
        Globals.LastClean = tick()
        for _, arr in pairs(Objects) do
            local i = #arr
            while i >= 1 do
                local o = arr[i]
                if o == nil or not o:IsDescendantOf(Workspace) then
                    table.remove(arr, i)
                    local c = ESPConnections[o]
                    if c then c:Disconnect(); ESPConnections[o] = nil
                        local p = table.find(Connections, c); if p then table.remove(Connections, p) end
                    end
                end
                i -= 1
            end
        end
    end
end))

-- 初始化
if LocalPlayer.Character then task.spawn(function() Functions.HandleCharacter(LocalPlayer.Character) end) end
LocalPlayer.CharacterAdded:Connect(function(ch)
    if Connections.MainHandler then Connections.MainHandler:Disconnect(); Connections.MainHandler = nil end
    task.wait(0.5); Functions.HandleCharacter(ch)
end)

ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("KLDoorsTK"); SaveManager:SetFolder("KLDoorsTK/Settings")
SaveManager:BuildConfigSection(Tabs.Settings); ThemeManager:ApplyToTab(Tabs.Settings)
Library.ToggleKeybind = Options.MenuKeybind
Functions.Notify({ Title = "KL-Doors-TK 完整版已加载", Body = "按 RightShift 切换 UI" })
pcall(function() SaveManager:LoadAutoloadConfig() end)
