-- 第 1 段
if getgenv().GE_Hub_Loaded then
    return
end
getgenv().GE_Hub_Loaded = true

local TARGET_PLACE_ID = 79327754502290
if game.PlaceId ~= TARGET_PLACE_ID then
    return
end

local repo = "https://raw.githubusercontent.com/Q2674791739/UI/main/Obsidian/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

task.wait(1)

local Window = Library:CreateWindow({
    Title = "脚本名称",
    Footer = "底部文字",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("主要", ""),
    Teleport = Window:AddTab("传送", ""),
    Attributes = Window:AddTab("属性", ""),
    Event = Window:AddTab("限定活动", ""),
    Info = Window:AddTab("教程", ""),
    ["UI Settings"] = Window:AddTab("界面设置", ""),
}

-- ===== 物资翻译表 =====
getgenv().GlobalItemTranslations = {
    ["Fuse"] = "保险丝", ["CarBattery"] = "汽车电池", ["Apple"] = "苹果", ["Banana"] = "香蕉", ["Carrot"] = "胡萝卜", ["Tomato"] = "番茄", ["Cheese"] = "奶酪", ["Corn"] = "玉米", ["Egg"] = "鸡蛋", ["Eggplant"] = "茄子", ["Grape"] = "葡萄", ["Meat"] = "肉", ["Onion"] = "洋葱", ["Pie"] = "派", ["Potato"] = "土豆", ["Pumpkin"] = "南瓜", ["Strawberry"] = "草莓", ["PinkPricklyPear"] = "仙人掌果实", ["Bandage"] = "绷带", ["FirstAidKit"] = "急救包", ["ReviveKit"] = "复活包", ["Nail"] = "钉子", ["Nut"] = "坚果", ["WoodChair"] = "木椅", ["WoodStool"] = "木凳", ["WoodenNail"] = "木钉", ["RockingChair"] = "摇椅", ["VintageTV"] = "老式电视", ["MetalScrap"] = "金属废料", ["MetalBarrel"] = "金属桶", ["MetalBucket"] = "金属水桶", ["MetalGear"] = "金属齿轮", ["Gear"] = "齿轮", ["OldCan"] = "旧易拉罐", ["CrushedCan"] = "压扁易拉罐", ["Wheel"] = "轮子", ["Painting"] = "绘画作品", ["WheelBarrow"] = "独轮推车", ["Toaster"] = "烤面包机", ["BrokenLantern"] = "破损提灯", ["Lamp"] = "提灯", ["Lantern"] = "提灯", ["CrackedBell"] = "破裂的钟",

    ["FactoryMedicChest"] = "工厂医疗箱", ["Fridge"] = "冰箱", ["GlassFridge"] = "玻璃冰箱", ["MediumWeaponCrate"] = "中型武器箱", ["UltraWeaponCrate"] = "终极武器箱", ["WeaponCrate"] = "武器箱", ["WoodChest"] = "木制宝箱", ["PricklyCactus"] = "多刺仙人掌", ["ShippingContainer"] = "集装箱",

    ["Blueprint"] = "蓝图", ["ConveyorBelt"] = "传送带", ["CuttingBoard"] = "砧板", ["FryingPan"] = "平底锅", ["IronBarrier"] = "铁制障碍物", ["IronDoor"] = "铁门", ["IronRepairHammer"] = "铁制修理锤", ["IronScrap"] = "铁废料", ["RefinedSteel"] = "精炼钢", ["RepairHammer"] = "修理锤", ["ProWrench"] = "专业扳手", ["Wrench"] = "扳手", ["RustyBarrier"] = "生锈障碍物", ["RustyDoor"] = "生锈门", ["SteelBarrier"] = "钢制障碍物", ["SteelDoor"] = "钢门", ["SteelOfMars"] = "火星之钢", ["StorageShelf"] = "储物架", ["WoodBarrier"] = "木制障碍物", ["WoodBarrierOld"] = "旧木制障碍物", ["WoodBarrier_Wide"] = "宽木制障碍物", ["WoodDoor"] = "木门", ["WoodenSpikes"] = "木刺", ["DiamondBarrier"] = "钻石障碍物", ["FarmPlot"] = "农田", ["Ammo"] = "弹药", ["ScrapMagnet"] = "废料磁铁", ["Skull"] = "头骨", ["Totem"] = "图腾", ["Unicycle"] = "独轮车", ["Upgrader"] = "升级机", ["VaccumBackpack"] = "吸尘背包", ["VaccumBackpack2"] = "吸尘背包2", ["WateringCan"] = "洒水壶", ["ScientistResearchStation"] = "科学家研究站", ["NoBase"] = "无基底", ["default"] = "默认", ["emptyPan"] = "空平底锅", ["flour"] = "面粉", ["fuel"] = "燃料", ["meatPie"] = "肉派", ["monsterBody"] = "怪物身体", ["unbakedPie"] = "未烘烤的派", ["OldBattery"] = "旧电池", ["ExplosiveMeat"] = "爆炸肉", ["GoldFlakes"] = "金箔", ["PieDough"] = "派面团", ["RollingPin"] = "擀面杖", ["Molotov"] = "燃烧瓶", ["Break"] = "破坏", ["Gun"] = "枪",

    ["AdvancedAutoTurret"] = "高级自动炮台", ["AutoTurret"] = "自动炮台", ["AutoMixer"] = "自动搅拌机", ["TurretAmmo"] = "炮台弹药", ["TurretBase"] = "炮台底座", ["TurretHead"] = "炮台头部", ["BarbedWire"] = "铁丝网", ["BeachBall"] = "沙滩球",

    ["Blackberry"] = "黑莓", ["Blueberry"] = "蓝莓", ["CherryBomb"] = "樱桃炸弹", ["Chicken"] = "鸡肉", ["ChiliPepper"] = "辣椒", ["ChocolateMilk"] = "巧克力奶", ["Coconut"] = "椰子", ["CactusMeat"] = "仙人掌肉", ["GoldenApple"] = "金苹果", ["GoldenCarrot"] = "金胡萝卜", ["GreenPea"] = "绿豌豆", ["Mango"] = "芒果", ["Milk"] = "牛奶", ["Mushroom"] = "蘑菇", ["Orange"] = "橙子", ["Peanut"] = "花生", ["Pineapple"] = "菠萝", ["Pickle"] = "酸黄瓜", ["PricklyPear"] = "刺梨", ["RedPricklyPear"] = "红刺梨", ["Tamarind"] = "罗望子", ["Turkey"] = "火鸡", ["Watermelon"] = "西瓜", ["IceCream"] = "冰淇淋", ["Doomberry"] = "厄运莓", ["GhostPepper"] = "鬼椒",

    ["JugChugJuice"] = "大罐畅饮果汁", ["JumpyJuice"] = "跳跳果汁", ["PewPewJuice"] = "砰砰果汁", ["PowPowJuice"] = "啪啪果汁", ["PowXXXJuice"] = "强力XXX果汁", ["SpeedJuice"] = "速度果汁", ["SuperSpeedJuice"] = "超级速度果汁", ["EnragedYeast"] = "狂暴酵母", ["HyperYeast"] = "超级酵母", ["Yeast"] = "酵母", ["GreenJelly"] = "绿果冻", ["OrangeJelly"] = "橙果冻", ["PinkJelly"] = "粉果冻",

    ["EasterEgg"] = "复活节彩蛋", ["Gingerbread"] = "姜饼", ["HalloweenPie"] = "万圣节派", ["Snowball"] = "雪球", ["RadioactiveApple"] = "放射性苹果", ["RadioactiveBanana"] = "放射性香蕉", ["RadioactiveCarrot"] = "放射性胡萝卜", ["RadioactiveCorn"] = "放射性玉米", ["RadioactiveEgg"] = "放射性鸡蛋", ["RadioactiveRatMeat"] = "放射性老鼠肉",

    ["MetalBar"] = "金属条", ["MetalBooth"] = "金属卡座", ["MetalTable"] = "金属桌", ["WoodenBooth"] = "木制卡座", ["WoodenTable"] = "木桌",

    ["Burnt"] = "烤焦的", ["Cooked"] = "煮熟的", ["Raw"] = "生的",

    ["TomatoZombie"] = "番茄丧尸", ["CarrotZombie"] = "胡萝卜丧尸", ["AppleZombie"] = "苹果丧尸", ["BananaZombie"] = "香蕉丧尸", ["BlueberryZombie"] = "蓝莓丧尸", ["CherryBombZombie"] = "樱桃炸弹丧尸", ["GrapeZombie"] = "葡萄丧尸", ["StrawberryZombie"] = "草莓丧尸", ["TamarindZombie"] = "印度芒果僵尸", ["OrangeZombie"] = "橙子丧尸", ["PeanutZombie"] = "花生丧尸", ["EggplantZombie"] = "茄子丧尸", ["GoldenCarrotZombie"] = "金胡萝卜丧尸", ["PickleZombie"] = "酸黄瓜丧尸", ["CornZombie"] = "玉米丧尸", ["CoconutZombie"] = "椰子丧尸", ["MangoZombie"] = "芒果丧尸", ["PineappleZombie"] = "菠萝丧尸", ["PotatoZombie"] = "土豆丧尸", ["WatermelonZombie"] = "西瓜丧尸",

    ["Zombie"] = "丧尸", ["OnionZombie"] = "洋葱丧尸", ["TankZombie"] = "巨型丧尸", ["CrawlerZombie"] = "爬行丧尸", ["MutatedCrawlerZombie"] = "变异爬行丧尸", ["EnragedFastZombie"] = "狂暴快速丧尸", ["FastZombie"] = "快速丧尸", ["MushroomZombie"] = "蘑菇丧尸", ["PeaZombie"] = "豌豆丧尸", ["RadioactiveAppleZombie"] = "放射性苹果丧尸", ["RadioactiveBananaZombie"] = "放射性香蕉丧尸", ["RadioactiveCarrotZombie"] = "放射性胡萝卜丧尸", ["RadioactiveCornZombie"] = "放射性玉米丧尸", ["MinigunDoomberryZombie"] = "机枪厄运莓丧尸", ["PinkJellyZombie"] = "粉红凝胶丧尸", ["GreenJellyZombie"] = "绿色凝胶丧尸", ["OrangeJellyZombie"] = "橙色凝胶丧尸", ["AmputeeZombie"] = "截肢丧尸", ["BabyGobbles"] = "幼年高布尔", ["BankerCivilian"] = "银行家平民", ["Chef"] = "厨师", ["Civilian"] = "平民", ["DoomberryHead"] = "厄运莓头", ["DoomberryZombie"] = "厄运莓丧尸", ["EnragedCactusCreeper"] = "狂暴仙人掌爬行者", ["EnragedCrawlerZombie"] = "狂暴爬行丧尸", ["EnragedZombie"] = "狂暴丧尸", ["EvilChefDoughMan"] = "邪恶厨师面团人", ["EvilChick"] = "邪恶小鸡", ["FireZombie"] = "火焰丧尸", ["GingerbreadMan"] = "姜饼人", ["Gobbles"] = "高布尔", ["GrimcrustSupreme"] = "至尊黑壳", ["LostSpirit"] = "迷失游魂", ["MetalBucketZombie"] = "铁桶丧尸", ["NeoSnowman"] = "新型雪人", ["RatBossKing"] = "鼠王BOSS", ["RippedEvilChef"] = "肌肉邪恶厨师", ["Scarecrow"] = "稻草人", ["Snowman"] = "雪人", ["WoodenNailZombie"] = "木钉丧尸",

    ["RatMeat"] = "老鼠肉", ["SewerRat"] = "下水道老鼠", ["RadioactiveRat"] = "放射性老鼠", ["PepperGhost"] = "辣椒幽灵", ["CactusCreeper"] = "仙人掌爬行者", ["EvilCow"] = "邪恶的牛", ["EvilChicken"] = "邪恶的鸡", ["EvilScientistBoss"] = "格林博士", ["GrimcrustSupremeHead"] = "至尊头"
}

-- ===== 枪械翻译表 =====
getgenv().GlobalWeaponTranslations = {
    ["PumpShotgun"] = "泵动式霰弹枪", ["Revolver"] = "左轮手枪", ["M4"] = "M4A1步枪", ["Exo Rifle"] = "外星步枪", ["SawedOff"] = "短管霰弹枪", ["SMG"] = "冲锋枪", ["DMR"] = "射手步枪", ["Pistol"] = "半自动手枪", ["Raygun"] = "激光枪", ["Minigun"] = "加特林", ["M1Grand"] = "M1狙击枪",

    ["HandCannonLv1"] = "手炮Lv1", ["HandCannonLv2"] = "手炮Lv2", ["HandCannonLv3"] = "手炮Lv3", ["HandCannonLv4"] = "手炮Lv4", ["HandCannonLv5"] = "手炮Lv5",
    ["KaboomCannonLv1"] = "轰天炮Lv1", ["KaboomCannonLv2"] = "轰天炮Lv2", ["KaboomCannonLv3"] = "轰天炮Lv3",
    ["TheWonderBlast"] = "奇迹冲击波",
    ["UndeadStaffLv1"] = "亡灵法杖Lv1", ["UndeadStaffLv2"] = "亡灵法杖Lv2", ["UndeadStaffLv3"] = "亡灵法杖Lv3",
    ["WizardStaffLv1"] = "巫师法杖Lv1", ["WizardStaffLv2"] = "巫师法杖Lv2", ["WizardStaffLv3"] = "巫师法杖Lv3", ["WizardStaffLv4"] = "巫师法杖Lv4", ["WizardStaffLv5"] = "巫师法杖Lv5",

    ["UpgradedDMR"] = "升级版射手步枪", ["UpgradedExoRifle"] = "升级版外骨骼步枪", ["UpgradedM1Grand"] = "升级版M1加兰德", ["UpgradedM4A1"] = "升级版M4A1", ["UpgradedPistol"] = "升级版手枪", ["UpgradedPumpShotgun"] = "升级版泵动式霰弹枪", ["UpgradedRaygun"] = "升级版射线枪", ["UpgradedRevolver"] = "升级版左轮手枪", ["UpgradedSMG"] = "升级版冲锋枪", ["UpgradedSawedOff"] = "升级版截短霰弹枪", ["UpgradedTheWonderBlast"] = "升级版奇迹冲击波", ["UpgradedOven"] = "升级版烤箱",

    ["Blowpipe"] = "吹箭筒", ["BrassKnuckles"] = "指虎", ["ButcherKnife"] = "屠夫刀", ["Chainsaw"] = "电锯", ["Katana"] = "武士刀", ["RustyKatana"] = "生锈武士刀", ["ShotgunShells"] = "霰弹枪子弹", ["GoldenDMR"] = "黄金射手步枪"
}

local function TranslateItemName(name)
    return getgenv().GlobalItemTranslations[name] or name
end

local function TranslateWeaponName(name)
    return getgenv().GlobalWeaponTranslations[name] or name
end

getgenv().AutoCheckEnabled = false

-- 第 2 段
local function UpdateItemDropdowns()
    local baseNames = {}
    local seen = {}
    for rawName, translatedName in pairs(getgenv().GlobalItemTranslations) do
        if not seen[translatedName] then
            seen[translatedName] = true
            table.insert(baseNames, translatedName)
        end
    end
    
    local itemCount = {}
    local interactables = workspace:FindFirstChild("Interactables")
    if interactables then
        for _, obj in ipairs(interactables:GetChildren()) do
            local tName = TranslateItemName(obj.Name)
            itemCount[tName] = (itemCount[tName] or 0) + 1
        end
    end
    
    table.sort(baseNames, function(a, b)
        local countA = itemCount[a] or 0
        local countB = itemCount[b] or 0
        if countA > 0 and countB > 0 then
            if countA == countB then return a < b end
            return countA > countB
        end
        if countA > 0 and countB == 0 then return true end
        if countA == 0 and countB > 0 then return false end
        return a < b
    end)
    
    local displayList = {}
    for _, name in ipairs(baseNames) do
        table.insert(displayList, string.format("%s (x%d)", name, itemCount[name] or 0))
    end
    
    local function RestoreSelections(option, newList)
        if not option then return end
        local oldSelections = option.Value or {}
        local oldBaseSelected = {}
        for k, v in pairs(oldSelections) do
            if v then
                local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
                oldBaseSelected[baseName] = true
            end
        end
        option:SetValues(newList)
        local newSelections = {}
        for _, displayStr in ipairs(newList) do
            local baseName = string.match(displayStr, "^(.-) %(x%d+%)$") or displayStr
            if oldBaseSelected[baseName] then
                newSelections[displayStr] = true
            end
        end
        option:SetValue(newSelections)
    end
    
    RestoreSelections(Options.TargetLootItems, displayList)
    
    if Options.AutoInteractItems then
        if getgenv().AutoCheckEnabled then
            Options.AutoInteractItems:SetValues(displayList)
            local autoSelections = {}
            for _, displayStr in ipairs(displayList) do
                local baseName = string.match(displayStr, "^(.-) %(x%d+%)$") or displayStr
                if (itemCount[baseName] or 0) > 0 then
                    autoSelections[displayStr] = true
                end
            end
            Options.AutoInteractItems:SetValue(autoSelections)
        else
            RestoreSelections(Options.AutoInteractItems, displayList)
        end
    end
end

getgenv().UpdateItemDropdowns = UpdateItemDropdowns

-- 第 3 段
local function UpdateWeaponDropdowns()
    local baseNames = {}
    local seen = {}
    for rawName, translatedName in pairs(getgenv().GlobalWeaponTranslations) do
        if not seen[translatedName] then
            seen[translatedName] = true
            table.insert(baseNames, translatedName)
        end
    end
    
    local itemCount = {}
    local interactables = workspace:FindFirstChild("Interactables")
    if interactables then
        for _, obj in ipairs(interactables:GetChildren()) do
            local tName = TranslateWeaponName(obj.Name)
            itemCount[tName] = (itemCount[tName] or 0) + 1
        end
    end
    
    table.sort(baseNames, function(a, b)
        local countA = itemCount[a] or 0
        local countB = itemCount[b] or 0
        if countA > 0 and countB > 0 then
            if countA == countB then return a < b end
            return countA > countB
        end
        if countA > 0 and countB == 0 then return true end
        if countA == 0 and countB > 0 then return false end
        return a < b
    end)
    
    local displayList = {}
    for _, name in ipairs(baseNames) do
        table.insert(displayList, string.format("%s (x%d)", name, itemCount[name] or 0))
    end
    
    local option = Options.WeaponSelectDropdown
    if not option then return end
    local oldSelections = option.Value or {}
    local oldBaseSelected = {}
    for k, v in pairs(oldSelections) do
        if v then
            local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
            oldBaseSelected[baseName] = true
        end
    end
    option:SetValues(displayList)
    local newSelections = {}
    for _, displayStr in ipairs(displayList) do
        local baseName = string.match(displayStr, "^(.-) %(x%d+%)$") or displayStr
        if oldBaseSelected[baseName] then
            newSelections[displayStr] = true
        end
    end
    option:SetValue(newSelections)
end

getgenv().UpdateWeaponDropdowns = UpdateWeaponDropdowns

-- 第 4 段
local QuickGroup = Tabs.Main:AddLeftGroupbox("一键交互")

QuickGroup:AddButton({
    Text = "一键开箱",
    Func = function()
        task.spawn(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local containers = workspace:FindFirstChild("Containers")

            if not hrp or not containers then
                Library:Notify("找不到角色或箱子文件夹", 3)
                return
            end

            if Toggles.FastInteractToggle and not Toggles.FastInteractToggle.Value then
                Toggles.FastInteractToggle:SetValue(true)
            end

            local wasNoclipOn = Toggles.NoclipToggle and Toggles.NoclipToggle.Value or false
            local wasFlightOn = Toggles.FlightToggle and Toggles.FlightToggle.Value or false

            if not wasNoclipOn and Toggles.NoclipToggle then Toggles.NoclipToggle:SetValue(true) end
            if not wasFlightOn and Toggles.FlightToggle then Toggles.FlightToggle:SetValue(true) end
            task.wait(0.3)

            local savedCFrame = hrp.CFrame

            local chestsToOpen = {}
            for _, chest in ipairs(containers:GetChildren()) do
                local prompt = nil
                for _, d in ipairs(chest:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        prompt = d
                        break
                    end
                end
                if prompt then
                    table.insert(chestsToOpen, { chest = chest, prompt = prompt })
                end
            end

            if #chestsToOpen == 0 then
                Library:Notify("没有找到未开启的箱子", 3)
                if not wasNoclipOn and Toggles.NoclipToggle then Toggles.NoclipToggle:SetValue(false) end
                if not wasFlightOn and Toggles.FlightToggle then Toggles.FlightToggle:SetValue(false) end
                return
            end

            Library:Notify("开始开箱，共 " .. #chestsToOpen .. " 个", 3)

            for i, item in ipairs(chestsToOpen) do
                local targetPos = nil
                if item.prompt.Parent and item.prompt.Parent:IsA("BasePart") then
                    targetPos = item.prompt.Parent.Position
                elseif item.chest:IsA("BasePart") then
                    targetPos = item.chest.Position
                elseif item.chest:IsA("Model") then
                    local prim = item.chest.PrimaryPart or item.chest:FindFirstChildWhichIsA("BasePart")
                    if prim then targetPos = prim.Position end
                end

                if targetPos then
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))

                    task.wait(0.25)

                    local oldLOS = item.prompt.RequiresLineOfSight
                    item.prompt.RequiresLineOfSight = false
                    pcall(function() fireproximityprompt(item.prompt, 1) end)
                    item.prompt.RequiresLineOfSight = oldLOS
                    task.wait(0.15)
                end
            end

            hrp.CFrame = savedCFrame
            task.wait(0.3)

            if not wasNoclipOn and Toggles.NoclipToggle then Toggles.NoclipToggle:SetValue(false) end
            if not wasFlightOn and Toggles.FlightToggle then Toggles.FlightToggle:SetValue(false) end

            Library:Notify("开箱完成！", 3)
        end)
    end,
    DoubleClick = false,
})

local LootGroup = Tabs.Main:AddLeftGroupbox("物资拉取")

LootGroup:AddDropdown("TargetLootItems", {
    Values = {},
    Default = 0,
    Multi = true,
    Text = "物资选择",
})

LootGroup:AddButton({
    Text = "带来物资",
    Func = function()
        if not Options.TargetLootItems.Value then return end
        local selectedBaseNames = {}
        for k, v in pairs(Options.TargetLootItems.Value) do
            if v then
                local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
                selectedBaseNames[baseName] = true
            end
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local interactables = workspace:FindFirstChild("Interactables")
        if hrp and interactables then
            local tpTargetCFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            for _, obj in ipairs(interactables:GetChildren()) do
                local tName = TranslateItemName(obj.Name)
                if selectedBaseNames[tName] then
                    pcall(function()
                        if obj.PrimaryPart then obj:SetPrimaryPartCFrame(tpTargetCFrame)
                        elseif obj:IsA("BasePart") then obj.CFrame = tpTargetCFrame
                        elseif obj:IsA("Model") then obj:PivotTo(tpTargetCFrame) end
                    end)
                end
            end
        end
    end,
    DoubleClick = false,
})

LootGroup:AddDropdown("WeaponSelectDropdown", {
    Values = {},
    Default = 0,
    Multi = true,
    Text = "枪械选择",
})

LootGroup:AddButton({
    Text = "带来枪械",
    Func = function()
        if not Options.WeaponSelectDropdown.Value then 
            Library:Notify("请先选择枪械！", 3)
            return 
        end
        local selectedNames = {}
        for k, v in pairs(Options.WeaponSelectDropdown.Value) do
            if v then
                local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
                selectedNames[baseName] = true
            end
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tpTargetCFrame = hrp.CFrame * CFrame.new(0, 0, -3)
        local found = false
        local interactables = workspace:FindFirstChild("Interactables")
        if interactables then
            for _, obj in ipairs(interactables:GetChildren()) do
                local tName = TranslateWeaponName(obj.Name)
                if selectedNames[tName] then
                    found = true
                    pcall(function()
                        if obj:IsA("Model") then obj:PivotTo(tpTargetCFrame)
                        elseif obj:IsA("BasePart") then obj.CFrame = tpTargetCFrame end
                    end)
                    Library:Notify("已带来枪械: " .. tName, 3)
                    break
                end
            end
        end
        if not found then Library:Notify("未找到该枪械。", 3) end
    end,
    DoubleClick = false,
})

local ClearObstaclesGroup = Tabs.Main:AddLeftGroupbox("清理障碍")
ClearObstaclesGroup:AddButton({
    Text = "清理迷雾",
    Func = function()
        local count = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "FogWall" then v:Destroy() count = count + 1 end
        end
        Library:Notify("已清理 " .. count .. " 个迷雾空气墙", 3)
    end,
    DoubleClick = false,
})
ClearObstaclesGroup:AddButton({
    Text = "清理过场动画",
    Func = function()
        local count = 0
        local cutscenes = workspace:FindFirstChild("Cutscenes")
        if cutscenes then cutscenes:Destroy() count = count + 1 end

        local char = LocalPlayer.Character
        if char then
            local animator = char:FindFirstChildOfClass("Animator")
                or (char:FindFirstChildOfClass("Humanoid") and char.Humanoid:FindFirstChildOfClass("Animator"))
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    pcall(function() track:Stop(0) end)
                    count = count + 1
                end
            end
        end

        local cam = workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and cam then
            local vp = cam.ViewportSize
            for _, obj in ipairs(pg:GetDescendants()) do
                if (obj:IsA("ImageLabel") or obj:IsA("Frame")) and obj.Visible then
                    local size = obj.AbsoluteSize
                    if size.X >= vp.X * 0.9 and size.Y >= vp.Y * 0.9 then
                        local color = obj.BackgroundColor3 or obj.ImageColor3
                        local bright = color.R * 0.3 + color.G * 0.59 + color.B * 0.11
                        if bright < 0.3 then
                            pcall(function() obj:Destroy() end)
                            count = count + 1
                        end
                    end
                end
            end
        end

        Library:Notify("已清理 " .. count .. " 项过场残留", 3)
    end,
    DoubleClick = false,
})

-- 第 5 段
local InfoGroup = Tabs.Main:AddLeftGroupbox("状态监控")
local oldGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("StatusMonitorGui")
if oldGui then oldGui:Destroy() end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusMonitorGui" screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local zombieText = Instance.new("TextLabel")
zombieText.Name = "ZombieText" zombieText.Size = UDim2.new(0, 200, 0, 35)
zombieText.Position = UDim2.new(0, 20, 0, 30) zombieText.BackgroundTransparency = 0.5
zombieText.BackgroundColor3 = Color3.fromRGB(0, 0, 0) zombieText.TextColor3 = Color3.fromRGB(255, 255, 255)
zombieText.TextStrokeTransparency = 0.5 zombieText.Font = Enum.Font.SourceSansBold
zombieText.TextSize = 18 zombieText.Text = "当前怪物状态: 死机"
zombieText.Visible = false zombieText.Parent = screenGui
getgenv().ZombieIsActive = false getgenv().ZombieStatusConn = nil

local function CheckZombieActive()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, desc in ipairs(pg:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) and desc.Text then
            local txt = desc.Text
            if string.find(txt, "Survive the night", 1, true) then return true end
            if string.find(txt, "Night", 1, true) then return true end
            if string.find(txt, "Day", 1, true) then
                if not (string.find(txt, "Day 0", 1, true) or string.find(txt, "Day0", 1, true)) then return true end
            end
        end
    end
    return false
end

local function SetZombieActive()
    getgenv().ZombieIsActive = true
    zombieText.Text = "当前怪物状态: 活跃"
    zombieText.TextColor3 = Color3.fromRGB(0, 255, 0)
end

InfoGroup:AddToggle("ZombieScreenToggle", { Text = "在屏幕上显示怪物状态", Default = false, Tooltip = "显示当前游戏中怪物的状态" }):OnChanged(function(value)
    zombieText.Visible = value
    if value then
        if getgenv().ZombieIsActive then SetZombieActive() return end
        if CheckZombieActive() then SetZombieActive() return end
        if getgenv().ZombieStatusConn then task.cancel(getgenv().ZombieStatusConn) end
        getgenv().ZombieStatusConn = task.spawn(function()
            while value do
                if getgenv().ZombieIsActive then SetZombieActive() break end
                if CheckZombieActive() then SetZombieActive() break end
                task.wait(1)
            end
        end)
    else
        if getgenv().ZombieStatusConn then task.cancel(getgenv().ZombieStatusConn) end
    end
end)

getgenv().MutantBossNotified = {} getgenv().MutantBossConn = nil
InfoGroup:AddToggle("MutantBossNotifyToggle", { Text = "变异Boss刷新通知", Default = false, Tooltip = "检测到变异的鸡Boss或变异的牛boss刷新时通知" }):OnChanged(function(value)
    if value then
        if getgenv().MutantBossConn then task.cancel(getgenv().MutantBossConn) end
        getgenv().MutantBossConn = task.spawn(function()
            while value do
                local monsters = workspace:FindFirstChild("Monsters")
                if monsters then
                    for _, obj in ipairs(monsters:GetChildren()) do
                        if string.find(obj.Name, "EvilChicken") or string.find(obj.Name, "MutantChicken") then
                            if not getgenv().MutantBossNotified["Chicken"] then
                                getgenv().MutantBossNotified["Chicken"] = true
                                Library:Notify("变异的鸡boss已刷新", 5)
                            end
                        end
                        if string.find(obj.Name, "EvilCow") or string.find(obj.Name, "MutantCow") then
                            if not getgenv().MutantBossNotified["Cow"] then
                                getgenv().MutantBossNotified["Cow"] = true
                                Library:Notify("变异的牛boss已刷新", 5)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        if getgenv().MutantBossConn then task.cancel(getgenv().MutantBossConn) end
    end
end)

-- 第 6 段
local EventGroup = Tabs.Event:AddLeftGroupbox("万圣节活动")
EventGroup:AddLabel("万圣节活动")
getgenv().AutoPickCandyCornState = false

local function GetRemainingCandies()
    local candyFolder = workspace:FindFirstChild("CandyCornDrops")
    if not candyFolder then return {} end
    local list = {}
    for _, candy in ipairs(candyFolder:GetChildren()) do
        if candy.Name == "CandyCorn" then
            local cube = candy:FindFirstChild("Cube") or candy:FindFirstChildWhichIsA("BasePart")
            if cube then
                table.insert(list, { candy = candy, cube = cube, pos = cube.Position })
            end
        end
    end
    return list
end

local function FindNearestCandy(candies, fromPos)
    local nearest = nil
    local minDist = math.huge
    for _, item in ipairs(candies) do
        local d = (item.pos - fromPos).Magnitude
        if d < minDist then
            minDist = d
            nearest = item
        end
    end
    return nearest
end

EventGroup:AddToggle("AutoPickCandyCorn", {
    Text = "自动拾取糖果玉米",
    Default = false,
    Tooltip = "自动飞向离你最近且未被拾取的糖果玉米，完成后瞬移回原点"
}):OnChanged(function(value)
    getgenv().AutoPickCandyCornState = value
    if not value then return end
    
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local candyFolder = workspace:FindFirstChild("CandyCornDrops")
        
        if not hrp or not candyFolder then
            Library:Notify("找不到糖果玉米文件夹", 3)
            Toggles.AutoPickCandyCorn:SetValue(false)
            return
        end
        
        local wasNoclipOn = Toggles.NoclipToggle and Toggles.NoclipToggle.Value or false
        local wasFlightOn = Toggles.FlightToggle and Toggles.FlightToggle.Value or false
        local originalFlightSpeed = Options.FlightSpeed and Options.FlightSpeed.Value or 5
        
        if not wasNoclipOn and Toggles.NoclipToggle then Toggles.NoclipToggle:SetValue(true) end
        if not wasFlightOn and Toggles.FlightToggle then Toggles.FlightToggle:SetValue(true) end
        task.wait(0.3)
        
        if getgenv().FlightConn then getgenv().FlightConn:Disconnect() getgenv().FlightConn = nil end
        
        local savedCFrame = hrp.CFrame
        
        local initialCount = #GetRemainingCandies()
        if initialCount == 0 then
            Library:Notify("没有找到可拾取的糖果玉米", 3)
            if Options.FlightSpeed then Options.FlightSpeed:SetValue(originalFlightSpeed) end
            if Toggles.FlightToggle then Toggles.FlightToggle:SetValue(false) end
            if wasFlightOn and Toggles.FlightToggle then Toggles.FlightToggle:SetValue(true) end
            if not wasNoclipOn and Toggles.NoclipToggle then Toggles.NoclipToggle:SetValue(false) end
            Toggles.AutoPickCandyCorn:SetValue(false)
            return
        end
        
        Library:Notify("开始飞向糖果玉米，共 " .. initialCount .. " 个", 3)
        
        local maxLoop = initialCount + 20
        
        for i = 1, maxLoop do
            if not getgenv().AutoPickCandyCornState then break end
            
            if Toggles.FlightToggle and not Toggles.FlightToggle.Value then
                getgenv().AutoPickCandyCornState = false
                Library:Notify("飞行已关闭，自动拾取终止", 3)
                break
            end
            
            local curChar = LocalPlayer.Character
            local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
            if not curHrp then break end
            
            local candies = GetRemainingCandies()
            if #candies == 0 then break end
            
            local target = FindNearestCandy(candies, curHrp.Position)
            if not target then break end
            
            local targetPos = target.pos
            local startTime = tick()
            
            while getgenv().AutoPickCandyCornState and tick() - startTime < 10 do
                if Toggles.FlightToggle and not Toggles.FlightToggle.Value then
                    getgenv().AutoPickCandyCornState = false
                    break
                end
                
                local cc = LocalPlayer.Character
                local ch = cc and cc:FindFirstChild("HumanoidRootPart")
                if not ch then break end
                
                if not target.candy.Parent then break end
                
                local dist = (ch.Position - targetPos).Magnitude
                if dist < 2.5 then break end
                
                local bv = getgenv().FlightBV
                if not bv then
                    getgenv().AutoPickCandyCornState = false
                    break
                end
                
                local dir = (targetPos - ch.Position).Unit
                bv.velocity = dir * 120
                RunService.Heartbeat:Wait()
            end
            
            local bv = getgenv().FlightBV
            if bv then bv.velocity = Vector3.new(0, 0, 0) end
            task.wait(0.5)
        end
        
        local finalChar = LocalPlayer.Character
        local finalHrp = finalChar and finalChar:FindFirstChild("HumanoidRootPart")
        if finalHrp and savedCFrame then finalHrp.CFrame = savedCFrame end
        task.wait(0.3)
        
        if Options.FlightSpeed then Options.FlightSpeed:SetValue(originalFlightSpeed) end
        
        if not wasFlightOn and Toggles.FlightToggle then
            Toggles.FlightToggle:SetValue(false)
        elseif wasFlightOn and Toggles.FlightToggle then
            Toggles.FlightToggle:SetValue(false)
            task.wait(0.1)
            Toggles.FlightToggle:SetValue(true)
        end
        
        if not wasNoclipOn and Toggles.NoclipToggle then
            Toggles.NoclipToggle:SetValue(false)
        end
        
        Library:Notify("糖果玉米拾取完成！", 3)
        Toggles.AutoPickCandyCorn:SetValue(false)
    end)
end)

EventGroup:AddButton({
    Text = "传送至女巫boss点",
    Func = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(-164.68, 94.93, -429.19)
        Library:Notify("已传送至女巫boss点", 2)
    end,
    DoubleClick = false,
})

task.spawn(function()
    task.wait(1)
    UpdateItemDropdowns()
    UpdateWeaponDropdowns()
    local interactables = workspace:WaitForChild("Interactables", 10)
    if interactables then
        interactables.ChildAdded:Connect(UpdateItemDropdowns)
        interactables.ChildRemoved:Connect(UpdateItemDropdowns)
    end
end)
-- 第 7 段
local AutoGroup = Tabs.Main:AddRightGroupbox("自动化")

getgenv().AutoInteractState = false
getgenv().AutoInteractUserWants = false
getgenv().AutoInteractAutoChanging = false

AutoGroup:AddDropdown("AutoInteractItems", {
    Values = {},
    Default = 0,
    Multi = true,
    Text = "自动交互物品选择",
})

AutoGroup:AddToggle("AutoCheck", {
    Text = "自动勾选（有物品时）",
    Default = false,
    Tooltip = "打开后，下拉列表自动勾选地图上有数量的物品；关闭后清空所有勾选"
}):OnChanged(function(value)
    getgenv().AutoCheckEnabled = value
    if not value and Options.AutoInteractItems then
        Options.AutoInteractItems:SetValue({})
    end
    if getgenv().UpdateItemDropdowns then
        getgenv().UpdateItemDropdowns()
    end
end)

AutoGroup:AddToggle("AutoInteract", {
    Text = "远程自动拾取物品",
    Default = false,
    Tooltip = "开启后自动获取下拉列表选中物品（手持武器时自动关闭）"
}):OnChanged(function(value)
    if getgenv().AutoInteractAutoChanging then return end
    getgenv().AutoInteractUserWants = value
    getgenv().AutoInteractState = value
end)

getgenv().AutoDepositState = false
local function IsMixerFull()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Name == "CountLabel" then
            local c, m = string.match(desc.Text, "(%d+)%s*/%s*(%d+)")
            if c and m and tonumber(c) >= tonumber(m) and tonumber(m) > 0 then
                return true
            end
        end
    end
    return false
end

AutoGroup:AddToggle("AutoDeposit", {
    Text = "自动存入",
    Default = false,
    Tooltip = "根据手持物品类型，自动存入对应的机器（19格内有效，满载自动激活）"
}):OnChanged(function(value)
    getgenv().AutoDepositState = value
    if not value then return end
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ZAP = ReplicatedStorage:FindFirstChild("ZAP")
        local ZAP_RELIABLE = ZAP and ZAP:FindFirstChild("ZAP_RELIABLE")
        if not ZAP_RELIABLE then
            Library:Notify("找不到 ZAP_RELIABLE，无法自动存入！", 3)
            Toggles.AutoDeposit:SetValue(false)
            return
        end
        while getgenv().AutoDepositState do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local stations = workspace:FindFirstChild("Stations")
            if hrp and stations then
                local heldItemType = nil
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, desc in ipairs(pg:GetDescendants()) do
                        if desc:IsA("ImageButton") then
                            local slotTypeLabel = desc:FindFirstChild("SlotType")
                            if slotTypeLabel and slotTypeLabel:IsA("TextLabel") then
                                local stroke = desc:FindFirstChildOfClass("UIStroke")
                                if stroke and stroke.Enabled and stroke.Transparency < 1 then
                                    heldItemType = slotTypeLabel.Text
                                    break
                                end
                            end
                        end
                    end
                end
                if heldItemType then
                    local targetMachineName = nil
                    local typeStr = tostring(heldItemType)
                    if string.find(typeStr, "Ingredient") then
                        targetMachineName = "Mixer"
                    elseif string.find(typeStr, "Corpse") then
                        targetMachineName = "Grinder"
                    elseif string.find(typeStr, "Crafting Part") or string.find(typeStr, "Blueprint") then
                        targetMachineName = "BlueprintsTable"
                    end
                    if targetMachineName then
                        local station = stations:FindFirstChild(targetMachineName)
                        local deposit = station and station:FindFirstChild("ObjectDeposit", true)
                        if deposit and deposit:IsA("BasePart") then
                            local dist = (hrp.Position - deposit.Position).Magnitude
                            if dist <= 19 then
                                if targetMachineName == "Mixer" and IsMixerFull() then
                                    local mixer = stations:FindFirstChild("Mixer")
                                    local prompt = mixer and mixer:FindFirstChild("MixProximityPrompt", true)
                                    if prompt and prompt:IsA("ProximityPrompt") then
                                        pcall(function() fireproximityprompt(prompt, 1) end)
                                    end
                                    task.wait(0.5)
                                else
                                    if (tick() - (getgenv().LastDepositTime or 0) > 0.2) then
                                        getgenv().LastDepositTime = tick()
                                        local buff = buffer.create(2)
                                        buffer.writeu8(buff, 0, 48)
                                        buffer.writeu8(buff, 1, 1)
                                        pcall(function()
                                            ZAP_RELIABLE:FireServer(buff, {deposit})
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- 第 8 段
getgenv().AutoTeleportMutualLock = false

AutoGroup:AddToggle("AutoTeleportSafety", {
    Text = "残血自动传送安全点",
    Default = false,
    Tooltip = "当玩家血量低于30%时，自动传送至安全点"
}):OnChanged(function(value)
    getgenv().AutoTeleportSafetyState = value
    if value then
        if not getgenv().AutoTeleportMutualLock then
            getgenv().AutoTeleportMutualLock = true
            Toggles.AutoVoidHeal:SetValue(false)
            getgenv().AutoTeleportMutualLock = false
        end
        getgenv().AutoTeleportSafetyLocked = false
        task.spawn(function()
            while getgenv().AutoTeleportSafetyState do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MaxHealth > 0 then
                    local healthPercent = hum.Health / hum.MaxHealth
                    if healthPercent > 0.3 then
                        getgenv().AutoTeleportSafetyLocked = false
                    end
                    if healthPercent <= 0.3 and not getgenv().AutoTeleportSafetyLocked then
                        getgenv().AutoTeleportSafetyLocked = true
                        local targetPos = hrp.Position + Vector3.new(0, 20, 0)
                        hrp.CFrame = CFrame.new(targetPos)
                        if Toggles.FlightToggle and not Toggles.FlightToggle.Value then
                            Toggles.FlightToggle:SetValue(true)
                        end
                        task.wait(1)
                    end
                else
                    getgenv().AutoTeleportSafetyLocked = false
                    task.wait(0.5)
                end
                task.wait(0.2)
            end
        end)
    end
end)

getgenv().AutoVoidHealCooldown = false
AutoGroup:AddToggle("AutoVoidHeal", {
    Text = "残血自动恢复至满血",
    Default = false,
    Tooltip = "当玩家血量低于30%时自动恢复至满血，打怪物时不建议开启，因为会刷新丧尸状态"
}):OnChanged(function(value)
    getgenv().AutoVoidHealState = value
    if value then
        if not getgenv().AutoTeleportMutualLock then
            getgenv().AutoTeleportMutualLock = true
            Toggles.AutoTeleportSafety:SetValue(false)
            getgenv().AutoTeleportMutualLock = false
        end
        getgenv().AutoVoidHealCooldown = false
        task.spawn(function()
            while getgenv().AutoVoidHealState do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MaxHealth > 0 then
                    local healthPercent = hum.Health / hum.MaxHealth
                    if healthPercent <= 0.3 and not getgenv().AutoVoidHealCooldown then
                        getgenv().AutoVoidHealCooldown = true
                        local savedCFrame = hrp.CFrame
                        local wasFlightOn = false
                        if Toggles.FlightToggle and Toggles.FlightToggle.Value then
                            wasFlightOn = true
                            Toggles.FlightToggle:SetValue(false)
                            task.wait(0.1)
                        end
                        hrp.CFrame = CFrame.new(hrp.Position.X, -490, hrp.Position.Z)
                        local waitTime = 0
                        while getgenv().AutoVoidHealState and waitTime < 10 do
                            task.wait(0.1)
                            waitTime = waitTime + 0.1
                            local currentChar = LocalPlayer.Character
                            local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
                            if currentHum and currentHum.Health >= currentHum.MaxHealth then break end
                        end
                        local newChar = LocalPlayer.Character
                        local newHrp = newChar and newChar:FindFirstChild("HumanoidRootPart")
                        if newHrp then newHrp.CFrame = savedCFrame end
                        if wasFlightOn and Toggles.FlightToggle then
                            Toggles.FlightToggle:SetValue(true)
                        end
                        task.wait(1)
                        getgenv().AutoVoidHealCooldown = false
                    end
                else
                    task.wait(0.5)
                end
                task.wait(0.2)
            end
        end)
    end
end)

-- 第 9 段
local ZAP = ReplicatedStorage:FindFirstChild("ZAP")
local ZAP_RELIABLE = ZAP and ZAP:FindFirstChild("ZAP_RELIABLE")
local lastCollectTime = 0
local WEAPON_SLOT_TYPES = { ["Melee"] = true, ["Gun"] = true, ["Ranged"] = true, ["Weapon"] = true }

local function GetHeldWeaponInfo()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local hotbar = pg and pg:FindFirstChild("Hotbar")
    if not hotbar then return nil, nil end
    local slots = hotbar:FindFirstChild("Slots")
    if not slots then return nil, nil end
    for _, slotFrame in ipairs(slots:GetChildren()) do
        if slotFrame:IsA("Frame") then
            local innerFrame = slotFrame:FindFirstChild("Frame")
            if innerFrame then
                local imgBtn = innerFrame:FindFirstChild("ImageButton")
                if imgBtn and imgBtn:IsA("ImageButton") then
                    local stroke = imgBtn:FindFirstChildOfClass("UIStroke")
                    if stroke and stroke.Transparency < 0.5 then
                        local nameLabel = imgBtn:FindFirstChild("Name")
                        local typeLabel = imgBtn:FindFirstChild("SlotType")
                        if nameLabel and typeLabel then
                            return nameLabel.Text, typeLabel.Text
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local weaponName, slotType = GetHeldWeaponInfo()
    local holdingWeapon = weaponName and slotType and WEAPON_SLOT_TYPES[slotType]

    if holdingWeapon and getgenv().AutoInteractState then
        getgenv().AutoInteractAutoChanging = true
        Toggles.AutoInteract:SetValue(false)
        getgenv().AutoInteractAutoChanging = false
        getgenv().AutoInteractState = false
        return
    end

    if not holdingWeapon and getgenv().AutoInteractUserWants and not getgenv().AutoInteractState then
        getgenv().AutoInteractAutoChanging = true
        Toggles.AutoInteract:SetValue(true)
        getgenv().AutoInteractAutoChanging = false
        getgenv().AutoInteractState = true
        return
    end

    if not getgenv().AutoInteractState then return end

    local selectedItems = {}
    if Options.AutoInteractItems and Options.AutoInteractItems.Value then
        for k, v in pairs(Options.AutoInteractItems.Value) do
            if v then
                local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
                selectedItems[baseName] = true
            end
        end
    end

    if tick() - lastCollectTime > 0.3 then
        local interactables = workspace:FindFirstChild("Interactables")
        if interactables then
            local mixer = workspace:FindFirstChild("Stations") and workspace.Stations:FindFirstChild("Mixer")
            local deposit = mixer and mixer:FindFirstChild("ObjectDeposit")

            for _, obj in ipairs(interactables:GetChildren()) do
                local uuid = obj:GetAttribute("ObjectUUID")
                if uuid then
                    local isInsideMixer = false
                    if deposit then
                        local itemPos = nil
                        if obj:IsA("BasePart") then itemPos = obj.Position
                        elseif obj:IsA("Model") then itemPos = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position end
                        if itemPos then
                            local localPos = deposit.CFrame:PointToObjectSpace(itemPos)
                            local halfSize = deposit.Size / 2
                            if math.abs(localPos.X) < halfSize.X and math.abs(localPos.Y) < halfSize.Y and math.abs(localPos.Z) < halfSize.Z then
                                isInsideMixer = true
                            end
                        end
                    end
                    if not isInsideMixer then
                        local tName = TranslateItemName(obj.Name)
                        if selectedItems[tName] then
                            local payloadStr = "/$" .. string.char(0) .. uuid
                            local payload = buffer.fromstring(payloadStr)
                            pcall(function() ZAP_RELIABLE:FireServer(payload, {}) end)
                            lastCollectTime = tick()
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- 第 10 段
local function AutoReadCode(promptPath, codeName, uiPath)
    task.spawn(function()
        task.wait(1.2)

        local node = workspace
        for _, seg in ipairs(promptPath) do
            node = node and node:FindFirstChild(seg)
        end
        if not node then Library:Notify("找不到" .. codeName .. "交互点", 4) return end

        local oldLOS = node.RequiresLineOfSight
        node.RequiresLineOfSight = false
        pcall(function() fireproximityprompt(node, 1) end)
        node.RequiresLineOfSight = oldLOS

        task.wait(0.8)

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then Library:Notify("没有 PlayerGui", 3) return end

        local uiNode = pg
        for _, seg in ipairs(uiPath or {"Code", "Paper"}) do
            uiNode = uiNode and uiNode:FindFirstChild(seg)
        end
        if not uiNode then Library:Notify(codeName .. " 未出现，请手动点一次", 5) return end

        local pwd = nil
        for _, v in ipairs(uiNode:GetDescendants()) do
            if v:IsA("TextLabel") then
                local n = string.match(v.Text, "(%d%d%d%d)")
                if n then pwd = n break end
            end
        end

        if pwd then Library:Notify(codeName .. "：" .. pwd, 15)
        else Library:Notify("未能读取" .. codeName, 5) end
    end)
end

local function AutoOpenNearestCrate(crateName, myPos, waitTime)
    task.spawn(function()
        task.wait(waitTime or 1.2)
        local containers = workspace:FindFirstChild("Containers")
        if not containers then
            Library:Notify("找不到 Containers", 3)
            return
        end
        local nearest, minDist = nil, math.huge
        for _, obj in ipairs(containers:GetChildren()) do
            if obj.Name == crateName then
                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if p then
                    local d = (p.Position - myPos).Magnitude
                    if d < minDist then
                        minDist = d
                        nearest = obj
                    end
                end
            end
        end

        if not nearest or minDist > 30 then
            Library:Notify("附近没有找到箱子", 3)
            return
        end

        local prompt = nearest:FindFirstChild("Top") and nearest.Top:FindFirstChild("ProximityPrompt")
        if not prompt then
            Library:Notify("附近没有找到交互点，箱子可能已被打开", 3)
            return
        end
        local oldLOS = prompt.RequiresLineOfSight
        prompt.RequiresLineOfSight = false
        pcall(function() fireproximityprompt(prompt, 1) end)
        prompt.RequiresLineOfSight = oldLOS
        Library:Notify("箱子已打开", 3)
    end)
end

local RescueGroup = Tabs.Teleport:AddLeftGroupbox("NPC营救")
local RescueLocations = {
    ["教堂-狙击手"]   = Vector3.new(-119.39, 51.33, -168.41),
    ["便利店-VIP"]    = Vector3.new(252.97, 51.75, 0.38),
    ["加油站-清洁工"] = Vector3.new(607.05, 51.46, 263.36),
    ["医院-医生"]     = Vector3.new(-431.49, 62.96, -22.26),
    ["银行-银行家"]   = Vector3.new(1038.48, 65.60, -111.33),
    ["仓库-维修工"]   = Vector3.new(625.81, 51.61, -183.91),
}
local RescueOrder = {"教堂-狙击手", "便利店-VIP", "加油站-清洁工", "医院-医生", "银行-银行家", "仓库-维修工"}
RescueGroup:AddDropdown("RescueDropdown", { Values = RescueOrder, Default = 1, Multi = false, Text = "选择营救目标", MaxVisibleDropdownItems = 3 })
RescueGroup:AddButton({
    Text = "传送",
    Func = function()
        local selected = Options.RescueDropdown.Value
        local target = RescueLocations[selected]
        if not target then Library:Notify("请先选择营救目标", 2) return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(target)
        if selected == "银行-银行家" then
            AutoReadCode({"World", "Bank", "BankClipboard", "Part", "ProximityPrompt"}, "金库密码", {"Code", "Paper"})
        end
    end,
    DoubleClick = false,
})

-- 第 11 段
local TeleportBossGroup = Tabs.Teleport:AddLeftGroupbox("固定Boss传送")
local BossLocations = {
    ["末日莓"] = Vector3.new(-430.81, 13.30, 193.98),
    ["格林博士"] = Vector3.new(358.60, 90.96, -411.06),
    ["至尊头"] = Vector3.new(-983.31, 91.00, -123.52),
    ["邪恶厨师"] = Vector3.new(-1115.46, 91.00, -267.71)
}
local bossNames = {"末日莓", "格林博士", "至尊头", "邪恶厨师"}
TeleportBossGroup:AddDropdown("BossLocationDropdown", { Values = bossNames, Default = 1, Multi = false, Text = "选择 Boss 传送点", MaxVisibleDropdownItems = 3 })
TeleportBossGroup:AddButton({
    Text = "传送",
    Func = function()
        local selected = Options.BossLocationDropdown.Value
        local target = BossLocations[selected]
        if not target then Library:Notify("请先选择 Boss传送点", 2) return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(target)
    end,
    DoubleClick = false,
})

local StoryBossGroup = Tabs.Teleport:AddLeftGroupbox("剧情/条件Boss传送")
local function CheckBossSpawnAndNotify(bossKeyword, displayName)
    if getgenv().TeleportNotified and getgenv().TeleportNotified[bossKeyword] then return end
    local isSpawned = false
    local monsters = workspace:FindFirstChild("Monsters")
    if monsters then
        for _, obj in ipairs(monsters:GetChildren()) do
            if string.find(obj.Name, bossKeyword, 1, true) then isSpawned = true break end
        end
    end
    if isSpawned then
        Library:Notify("当前" .. displayName .. "已刷新", 5)
        if not getgenv().TeleportNotified then getgenv().TeleportNotified = {} end
        getgenv().TeleportNotified[bossKeyword] = true
    else
        Library:Notify("当前" .. displayName .. "暂未刷新", 5)
    end
end

StoryBossGroup:AddButton({
    Text = "传送至邪恶的鸡-第6天",
    Func = function()
        CheckBossSpawnAndNotify("EvilChicken", "变异的鸡boss")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(-204.43, 54.00, 403.06)
    end,
    DoubleClick = false,
})
StoryBossGroup:AddButton({
    Text = "传送至邪恶的牛-第7天",
    Func = function()
        CheckBossSpawnAndNotify("EvilCow", "变异的牛boss")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(-295.57, 56.00, 425.27)
    end,
    DoubleClick = false,
})
StoryBossGroup:AddDivider()
local StoryBossLocations = {
    ["发电机"] = Vector3.new(91.19, 19.34, 158.39),
    ["1号接电处"] = Vector3.new(95.10, 19.49, 220.10),
    ["2号接电处"] = Vector3.new(179.02, 19.34, 230.72),
    ["鼠鼠国王"] = Vector3.new(122.90, 19.34, 382.52)
}
local storyBossNames = {"发电机", "1号接电处", "2号接电处", "鼠鼠国王"}
StoryBossGroup:AddDropdown("StoryBossDropdown", { Values = storyBossNames, Default = 1, Multi = false, Text = "鼠鼠国王-需要下水道钥匙，发电机电池", MaxVisibleDropdownItems = 5 })
StoryBossGroup:AddButton({
    Text = "传送",
    Func = function()
        local selected = Options.StoryBossDropdown.Value
        local target = StoryBossLocations[selected]
        if not target then Library:Notify("请先选择剧情 Boss", 2) return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(target)
    end,
    DoubleClick = false,
})

-- 第 12 段
local TeleportMapGroup = Tabs.Teleport:AddRightGroupbox("地图传送")
local MapLocations = {
    ["餐厅"] = Vector3.new(-26.93, 51.58, 111.03),
    ["实验室[入口]"] = Vector3.new(-87.50, 33.30, 378.85),
    ["重构器"] = Vector3.new(472.01, 90.96, -446.30),
    ["食品工厂"] = Vector3.new(-611.60, 51.10, 54.96),
    ["常绿大门"] = Vector3.new(462.72, 51.14, -296.68)
}
TeleportMapGroup:AddDropdown("MapLocationDropdown", { Values = {"餐厅", "实验室[入口]", "重构器", "食品工厂", "常绿大门"}, Default = 1, Multi = false, Text = "选择地图传送点", MaxVisibleDropdownItems = 5 })
TeleportMapGroup:AddButton({
    Text = "传送",
    Func = function()
        local selected = Options.MapLocationDropdown.Value
        local target = MapLocations[selected]
        if not target then Library:Notify("请先选择地图点", 2) return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(target)
        if selected == "常绿大门" then
            AutoReadCode({"KeyItemPromptAnchor", "ProximityPrompt"}, "常绿代码", {"KeyItemDiscovered", "ImageLabel"})
        end
    end,
    DoubleClick = false,
})

local WeaponGroup = Tabs.Teleport:AddRightGroupbox("武器获取")
local WeaponLocations = {
    ["外星步枪"] = Vector3.new(-208.06, 27.30, 231.97),
    ["军械库"] = Vector3.new(-4.37, 51.00, -25.46),
    ["激光枪"] = Vector3.new(433.35, 54.46, -572.75),
    ["加特林"] = Vector3.new(-968.95, 55.00, -12.65),
    ["远程武器箱1"] = Vector3.new(-306.85, 11.23, 509.47),
    ["远程武器箱2"] = Vector3.new(-238.17, 25.23, 457.84),
    ["远程武器箱3"] = Vector3.new(-275.51, 11.23, 337.59),
    ["远程武器箱4"] = Vector3.new(-106.53, 25.21, 506.10),
    ["近战武器箱1"] = Vector3.new(333.10, 62.56, 97.09),
    ["近战武器箱2"] = Vector3.new(642.24, 78.11, 300.26),
    ["近战武器箱3"] = Vector3.new(-404.64, 61.72, 310.06),
    ["近战武器箱4"] = Vector3.new(818.04, 62.03, -179.52)
}
local WeaponOrder = {"外星步枪", "军械库", "激光枪", "加特林", "远程武器箱1", "远程武器箱2", "远程武器箱3", "远程武器箱4", "近战武器箱1", "近战武器箱2", "近战武器箱3", "近战武器箱4", }
WeaponGroup:AddDropdown("WeaponDropdown", { Values = WeaponOrder, Default = 1, Multi = false, Text = "选择武器传送点", MaxVisibleDropdownItems = 4 })
WeaponGroup:AddButton({
    Text = "传送",
    Func = function()
        local selected = Options.WeaponDropdown.Value
        local target = WeaponLocations[selected]
        if not target then Library:Notify("请先选择武器传送点", 2) return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(target)

        if selected == "激光枪" then
            AutoReadCode({"World", "ScienceFacility", "RaygunCode", "Primary", "ProximityPrompt"}, "激光枪代码", {"Code", "Paper"})

        elseif selected == "外星步枪" then
            if Toggles.FastInteractToggle and not Toggles.FastInteractToggle.Value then
                Toggles.FastInteractToggle:SetValue(true)
            end
            AutoOpenNearestCrate("UltraWeaponCrate", target)

        elseif string.find(selected, "远程武器箱") then
            if Toggles.FastInteractToggle and not Toggles.FastInteractToggle.Value then
                Toggles.FastInteractToggle:SetValue(true)
            end
            AutoOpenNearestCrate("MediumWeaponCrate", target)

        elseif string.find(selected, "近战武器箱") then
            if Toggles.FastInteractToggle and not Toggles.FastInteractToggle.Value then
                Toggles.FastInteractToggle:SetValue(true)
            end
            AutoOpenNearestCrate("WeaponCrate", target)
        end
    end,
    DoubleClick = false,
})

-- 第 13 段
local AttrLeft = Tabs.Attributes:AddLeftGroupbox("玩家属性")
AttrLeft:AddToggle("WalkSpeedToggle", { Text = "启用移速", Default = false }):OnChanged(function(value)
    getgenv().WalkSpeedState = value
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if value then
        if hum then getgenv().OriginalWalkSpeed = hum.WalkSpeed end
    else
        if hum and getgenv().OriginalWalkSpeed then hum.WalkSpeed = getgenv().OriginalWalkSpeed end
    end
end)
AttrLeft:AddSlider("WalkSpeedSlider", { Text = "移速设置", Default = 16, Min = 10, Max = 200, Rounding = 0 })
RunService.RenderStepped:Connect(function()
    if not getgenv().WalkSpeedState then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and Options.WalkSpeedSlider then hum.WalkSpeed = Options.WalkSpeedSlider.Value end
end)
AttrLeft:AddToggle("NoclipToggle", { Text = "穿墙", Default = false }):OnChanged(function(value) getgenv().NoclipState = value end)
RunService.Stepped:Connect(function()
    if not getgenv().NoclipState then return end
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)
AttrLeft:AddToggle("FastInteractToggle", { Text = "快速交互", Default = false }):OnChanged(function(value)
    getgenv().FastInteractState = value
    if value then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end
end)
workspace.DescendantAdded:Connect(function(obj)
    if getgenv().FastInteractState and obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
end)
AttrLeft:AddToggle("FlightToggle", { Text = "飞行", Default = false }):OnChanged(function(value)
    getgenv().FlightState = value
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if value and char and hum and root then
        hum.PlatformStand = true
        local bg = Instance.new("BodyGyro", root)
        bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = root.CFrame
        getgenv().FlightBG = bg
        local bv = Instance.new("BodyVelocity", root)
        bv.velocity = Vector3.zero bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        getgenv().FlightBV = bv
        if getgenv().FlightConn then getgenv().FlightConn:Disconnect() end
        getgenv().FlightConn = RunService.RenderStepped:Connect(function()
            if not getgenv().FlightState then return end
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then return end
            local cam = workspace.CurrentCamera
            local speed = Options.FlightSpeed and Options.FlightSpeed.Value or 5
            local moveVec = Vector3.zero
            pcall(function()
                local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                moveVec = controls:GetMoveVector()
            end)
            if moveVec.Magnitude > 0 then
                local dir = (cam.CFrame.RightVector * moveVec.X + cam.CFrame.LookVector * -moveVec.Z).Unit
                bv.velocity = dir * (speed * 8)
            else
                bv.velocity = Vector3.zero
            end
            bg.cframe = cam.CFrame
        end)
    else
        if getgenv().FlightConn then getgenv().FlightConn:Disconnect() getgenv().FlightConn = nil end
        if getgenv().FlightBG then getgenv().FlightBG:Destroy() getgenv().FlightBG = nil end
        if getgenv().FlightBV then getgenv().FlightBV:Destroy() getgenv().FlightBV = nil end
        if hum then hum.PlatformStand = false end
    end
end)
AttrLeft:AddSlider("FlightSpeed", { Text = "飞行速度", Default = 5, Min = 1, Max = 100, Rounding = 0 })

-- 第 14 段
local AttrRight = Tabs.Attributes:AddRightGroupbox("远程武器杀戮光环")
AttrRight:AddSlider("KillAuraRange", { Text = "范围", Default = 66, Min = 15, Max = 500, Rounding = 0 })

-- ===== 武器优先级下拉 =====
local GunNameList = {}
local seenGunName = {}
for _, trans in pairs(getgenv().GlobalWeaponTranslations) do
    if not seenGunName[trans] then
        seenGunName[trans] = true
        table.insert(GunNameList, trans)
    end
end
table.sort(GunNameList)

AttrRight:AddDropdown("KillAuraPriority", {
    Values = GunNameList,
    Default = 1,
    Multi = false,
    Text = "武器优先级（杀戮使用）",
    MaxVisibleDropdownItems = 4,
})

-- 扫 hotbar 里的所有枪
local function ScanHotbarGuns()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local hotbar = pg and pg:FindFirstChild("Hotbar")
    local slots = hotbar and hotbar:FindFirstChild("Slots")
    if not slots then return {} end

    local guns = {}
    for _, slotFrame in ipairs(slots:GetChildren()) do
        local inner = slotFrame:FindFirstChild("Frame")
        local img = inner and inner:FindFirstChild("ImageButton")
        if img then
            local numL = img:FindFirstChild("SlotNumber")
            local typeL = img:FindFirstChild("SlotType")
            local nameL = img:FindFirstChild("Name")
            if numL and typeL and nameL and typeL.Text == "Gun" then
                local rawName = nameL.Text
                local chinese = getgenv().GlobalWeaponTranslations[rawName] or rawName
                table.insert(guns, {
                    slot = tonumber(numL.Text) or 0,
                    raw = rawName,
                    chinese = chinese,
                })
            end
        end
    end
    return guns
end

-- 检测当前是否有手持物品
local function IsHoldingSomething()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local hotbar = pg and pg:FindFirstChild("Hotbar")
    local slots = hotbar and hotbar:FindFirstChild("Slots")
    if not slots then return false end

    for _, slotFrame in ipairs(slots:GetChildren()) do
        local inner = slotFrame:FindFirstChild("Frame")
        local img = inner and inner:FindFirstChild("ImageButton")
        if img then
            local stroke = img:FindFirstChildOfClass("UIStroke")
            if stroke and stroke.Transparency < 0.5 then
                return true
            end
        end
    end
    return false
end

-- 自动准备：只留目标枪在第 1 格，其他枪全丢，前置非枪物品也丢
local function AutoPrepareGunKillAura(targetTranslatedName)
    task.spawn(function()
        local RS = game:GetService("ReplicatedStorage")
        local ZAP = RS:FindFirstChild("ZAP")
        local ZAP_RELIABLE = ZAP and ZAP:FindFirstChild("ZAP_RELIABLE")
        if not ZAP_RELIABLE then
            Library:Notify("找不到 ZAP", 3)
            return
        end

        local function Fire(buf)
            pcall(function() ZAP_RELIABLE:FireServer(buf, {}) end)
        end
        local function SwitchTo(slotNum)
            local b = buffer.create(3)
            buffer.writeu8(b, 0, 44)
            buffer.writeu8(b, 1, 1)
            buffer.writeu8(b, 2, slotNum)
            Fire(b)
        end
        local function DropHeld()
            local b = buffer.create(2)
            buffer.writeu8(b, 0, 48)
            buffer.writeu8(b, 1, 0)
            Fire(b)
        end
        local function Unhold()
            local b = buffer.create(2)
            buffer.writeu8(b, 0, 44)  -- 0x2C
            buffer.writeu8(b, 1, 0)   -- 空手
            Fire(b)
        end

        -- ★ Step 0: 如果手持着东西，先卸下（让 hotbar 显示回枪名，才能读到）
        if IsHoldingSomething() then
            Unhold()
            task.wait(0.3)
        end

        -- Step 1: 检查目标枪在不在背包
        local guns = ScanHotbarGuns()
        local targetInBag = false
        for _, g in ipairs(guns) do
            if g.chinese == targetTranslatedName then targetInBag = true break end
        end
        if not targetInBag then
            Library:Notify("背包里没有 " .. targetTranslatedName, 4)
            return
        end

-- Step 2: 只丢"目标枪前面"的枪，后面的保留
for i = 1, 20 do
    local curGuns = ScanHotbarGuns()
    if #curGuns <= 1 then break end

    -- 找目标枪的 slot
    local targetSlot = nil
    for _, g in ipairs(curGuns) do
        if g.chinese == targetTranslatedName then
            targetSlot = g.slot
            break
        end
    end
    if not targetSlot then break end

    -- 找目标枪前面（slot 更小）的第一把非目标枪
    local toDrop = nil
    for _, g in ipairs(curGuns) do
        if g.slot < targetSlot and g.chinese ~= targetTranslatedName then
            toDrop = g
            break
        end
    end
    if not toDrop then break end

    SwitchTo(toDrop.slot)
    task.wait(0.15)
    DropHeld()
    task.wait(0.2)
end

        -- Step 3: 丢第 1 格的非枪物品
        for i = 1, 40 do
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local hotbar = pg and pg:FindFirstChild("Hotbar")
            local slots = hotbar and hotbar:FindFirstChild("Slots")
            if not slots then break end

            local firstSlot = nil
            local minNum = math.huge
            for _, slotFrame in ipairs(slots:GetChildren()) do
                local inner = slotFrame:FindFirstChild("Frame")
                local img = inner and inner:FindFirstChild("ImageButton")
                if img then
                    local numL = img:FindFirstChild("SlotNumber")
                    local typeL = img:FindFirstChild("SlotType")
                    if numL and typeL then
                        local num = tonumber(numL.Text) or 0
                        if num > 0 and num < minNum then
                            minNum = num
                            firstSlot = { slot = num, type = typeL.Text }
                        end
                    end
                end
            end

            if not firstSlot then break end
            if firstSlot.type == "Gun" then break end

            SwitchTo(firstSlot.slot)
            task.wait(0.15)
            DropHeld()
            task.wait(0.2)
        end

-- ★ Step 4: 直接切第 1 格（此时目标枪已在第 1 格）
        task.wait(0.3)
        SwitchTo(1)
        task.wait(0.2)
    end)
end

AttrRight:AddToggle("KillAuraVisualize", { Text = "可视化范围（地面红圈）", Default = false }):OnChanged(function(value)
    getgenv().KillAuraVisualizeState = value
    if value then
        local ring = Instance.new("Part")
        ring.Name = "KillAuraVisualizer" ring.Shape = Enum.PartType.Cylinder ring.Material = Enum.Material.ForceField
        ring.Color = Color3.fromRGB(255, 60, 60) ring.Transparency = 0.6 ring.Anchored = true ring.CanCollide = false
        ring.CanQuery = false ring.CanTouch = false ring.Parent = workspace
        getgenv().KillAuraRing = ring
        if getgenv().KillAuraVisConn then getgenv().KillAuraVisConn:Disconnect() end
        getgenv().KillAuraVisConn = RunService.RenderStepped:Connect(function()
            if not getgenv().KillAuraVisualizeState then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local range = Options.KillAuraRange and Options.KillAuraRange.Value or 66
            ring.Size = Vector3.new(0.1, range * 2, range * 2)
            ring.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
        end)
    else
        if getgenv().KillAuraVisConn then getgenv().KillAuraVisConn:Disconnect() getgenv().KillAuraVisConn = nil end
        if getgenv().KillAuraRing then getgenv().KillAuraRing:Destroy() getgenv().KillAuraRing = nil end
    end
end)

AttrRight:AddToggle("KillAuraToggle", { Text = "开启远程杀戮", Default = false }):OnChanged(function(value)
    getgenv().KillAuraState = value
    if value then
        local priority = Options.KillAuraPriority and Options.KillAuraPriority.Value
        if priority then
            AutoPrepareGunKillAura(priority)
            task.wait(1)
        end

        task.spawn(function()
            local ZAP = ReplicatedStorage:WaitForChild("ZAP")
            local ZAP_RELIABLE = ZAP:WaitForChild("ZAP_RELIABLE")
            local ZAP_UNRELIABLE_0 = ZAP:FindFirstChild("ZAP_UNRELIABLE_0")
            while getgenv().KillAuraState do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local monstersFolder = workspace:FindFirstChild("Monsters")
                local weaponName, slotType = GetHeldWeaponInfo()
                if not weaponName then task.wait(0.5) continue end
                if not WEAPON_SLOT_TYPES[slotType] then task.wait(0.5) continue end
                if hrp and monstersFolder then
                    local targets = {}
                    local radius = Options.KillAuraRange and Options.KillAuraRange.Value or 66
                    for _, monster in ipairs(monstersFolder:GetChildren()) do
                        local targetHrp = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                        local humanoid = monster:FindFirstChildOfClass("Humanoid") or monster:FindFirstChild("Humanoid")
                        if targetHrp and humanoid and humanoid.Health > 0 then
                            local dist = (hrp.Position - targetHrp.Position).Magnitude
                            if dist <= radius then table.insert(targets, { model = monster, hrp = targetHrp, humanoid = humanoid }) end
                        end
                    end
                    if #targets > 0 then
                        for _, t in ipairs(targets) do
                            local buff = buffer.create(39)
                            buffer.writeu8(buff, 0, 0) buffer.writeu8(buff, 1, 1)
                            local dir = (t.hrp.Position - hrp.Position).Unit
                            if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(0, 0, -1) end
                            buffer.writef32(buff, 2, dir.X) buffer.writef32(buff, 6, dir.Y) buffer.writef32(buff, 10, dir.Z)
                            buffer.writeu8(buff, 14, 1)
                            buffer.writef32(buff, 15, t.hrp.Position.X) buffer.writef32(buff, 19, t.hrp.Position.Y) buffer.writef32(buff, 23, t.hrp.Position.Z)
                            buffer.writef32(buff, 27, -dir.X) buffer.writef32(buff, 31, -dir.Y) buffer.writef32(buff, 35, -dir.Z)
                            ZAP_UNRELIABLE_0:FireServer(buff, {t.humanoid})
                        end
                        task.wait(0.1)
                    else
                        task.wait(0.2)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

-- 第 15 段
-- ===== 教程页 =====
local SkipDayInfoGroup = Tabs.Info:AddLeftGroupbox("“跳过一天”解锁教程")
SkipDayInfoGroup:AddLabel("餐厅门旁边的“跳过一天”如何解锁？")
SkipDayInfoGroup:AddLabel("——————————————")
SkipDayInfoGroup:AddLabel("首先传送至格林博士Boss点击败他")
SkipDayInfoGroup:AddLabel("击败格林博士boss后，会掉落DVD光盘")
SkipDayInfoGroup:AddLabel("捡起DVD光盘之后，返回餐厅")
SkipDayInfoGroup:AddLabel("与餐厅后面的电脑交互，将软盘插入电脑")
SkipDayInfoGroup:AddLabel("等待剧情结束后，你会获得一张钥匙卡")
SkipDayInfoGroup:AddLabel("再次返回食品工厂使用这张钥匙卡")
SkipDayInfoGroup:AddLabel("与食品工厂大门旁边的安全扫描仪交互")
SkipDayInfoGroup:AddLabel("“跳过一天”以及食品工厂则会永久解锁")

local BossInfoGroup = Tabs.Info:AddRightGroupbox("剧情/条件Boss说明")
BossInfoGroup:AddLabel("什么是剧情/条件boss？")
BossInfoGroup:AddLabel("——————————————")
BossInfoGroup:AddLabel("【剧情Boss】")
BossInfoGroup:AddLabel("指定天数才会刷新的Boss")
BossInfoGroup:AddLabel(" 变异的鸡Boss 在第6天刷新")
BossInfoGroup:AddLabel("——————————————")
BossInfoGroup:AddLabel("【条件Boss】")
BossInfoGroup:AddLabel("需要某个条件触发才会刷新的boss")
BossInfoGroup:AddLabel(" 变异的牛Boss ")
BossInfoGroup:AddLabel("需要玩家击败变异的鸡")
BossInfoGroup:AddLabel("boss后的第二天才会刷新")
BossInfoGroup:AddLabel("条件：击败变异的鸡Boss")
BossInfoGroup:AddLabel("——————————————")
BossInfoGroup:AddLabel(" 鼠鼠国王Boss ")
BossInfoGroup:AddLabel("需要击败变异的牛boss获取下水道钥匙")
BossInfoGroup:AddLabel("打开下水道后发电机电池就会刷新")
BossInfoGroup:AddLabel("找齐三个发电机电池后给发电机通电")
BossInfoGroup:AddLabel("通电后保险丝会刷新")
BossInfoGroup:AddLabel("将两个保险丝分别放到两个接电处")
BossInfoGroup:AddLabel("就可以挑战鼠鼠国王boss了")
BossInfoGroup:AddLabel("条件：击败变异的牛boss获取地下室钥匙")
BossInfoGroup:AddLabel("给发电机通电给接电处通电")
BossInfoGroup:AddLabel("——————————————")
BossInfoGroup:AddLabel("【提示】")
BossInfoGroup:AddLabel("如果不获取地下室钥匙")
BossInfoGroup:AddLabel("发电机电池根本不会刷新")

-- ===== 菜单 =====
local MenuGroup = Tabs["UI Settings"]:AddRightGroupbox("菜单", { PopOutEnabled = false })
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "打开快捷键", Callback = function(value) Library.KeybindFrame.Visible = value end })
MenuGroup:AddToggle("ShowCustomCursor", { Text = "自定义光标", Default = Library.ShowCustomCursor, Callback = function(Value) Library.ShowCustomCursor = Value end })
MenuGroup:AddDropdown("DPIDropdown", { Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%", Text = "DPI缩放", Callback = function(Value) Value = Value:gsub("%%", "") Library:SetDPIScale(tonumber(Value)) end })
MenuGroup:AddSlider("UICornerSlider", { Text = "圆角半径", Default = Library.CornerRadius, Min = 0, Max = 20, Rounding = 0, Callback = function(value) Window:SetCornerRadius(value) end })
MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单绑定"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "菜单快捷键" })

MenuGroup:AddButton("卸载", function()
    getgenv().AutoInteractState = false getgenv().WalkSpeedState = false getgenv().NoclipState = false
    getgenv().FastInteractState = false getgenv().FlightState = false getgenv().KillAuraState = false
    getgenv().AutoCheckEnabled = false getgenv().AutoTeleportSafetyState = false
    getgenv().AutoVoidHealState = false
    getgenv().ZombieIsActive = false getgenv().ZombieStatusState = false
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then local statusGui = pg:FindFirstChild("StatusMonitorGui") if statusGui then statusGui:Destroy() end end
    if getgenv().ZombieStatusConn then pcall(function() task.cancel(getgenv().ZombieStatusConn) end) getgenv().ZombieStatusConn = nil end
    if getgenv().MutantBossConn then pcall(function() task.cancel(getgenv().MutantBossConn) end) getgenv().MutantBossConn = nil end
    if getgenv().FlightConn then getgenv().FlightConn:Disconnect() getgenv().FlightConn = nil end
    if getgenv().FlightBG then getgenv().FlightBG:Destroy() getgenv().FlightBG = nil end
    if getgenv().FlightBV then getgenv().FlightBV:Destroy() getgenv().FlightBV = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false if getgenv().OriginalWalkSpeed then hum.WalkSpeed = getgenv().OriginalWalkSpeed end end
    getgenv().GE_Hub_Loaded = nil
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("GEHub")
SaveManager:SetFolder("GEHub/烤或死")
SaveManager:SetSubFolder("Config")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
Library:Notify("通知：加载成功！", 4)
SaveManager:LoadAutoloadConfig()
