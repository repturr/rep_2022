--++-- Game Services --++--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService");
local VirtualInputManager = game:GetService("VirtualInputManager");

--++-- Synapse API Services --++--
local SimulateLeftClick = mouse1click;
local SimulateLeftHold = mouse1press;
local SimulateLeftRelease = mouse1release;

local SimulateRightClick = mouse2click;
local SimulateRightHold = mouse2press;
local SimulateRightRelease = mouse2release;

local SimulateKeyPress = keypress;
local SimulateKeyRelease = keyrelease;

local Request = syn.request;

--++-- Loader Services --++--
local Settings = _G.Settings;

--++-- Unpack Settings --++--
local PerformanceSettings = Settings.Perfomance;
local PerfomanceFunctions = {};

local HTTPSettings = Settings.HTTPS;
local HTTPFunctions = {};

local RollSettings = Settings.Roll;
local RollFunctions = {
    RollToggledBool = false;
    RollBusy = false;
};

--++-- Messages --++--
local Messages = {
    EXECUTE_MESSAGE = "Stand Upright Rebooted: Stand Farm";
    CREDIT_MESSAGE = "Made by Repturr";

    PLATFORM_TELEPORT_MESSAGE = "Teleporting to hidden platform";

    FARM_TOGGLE_MESSAGE = "Stand Farm %s";

    STAND_ATTRIBUTE_MESSAGE = "%s / %s";
}


--++-- Player Variables --++--
local Player = Players.LocalPlayer;
local PlayerHWID = RbxAnalyticsService:GetClientId();

local Backpack = Player.Backpack;

local Character = Player.Character or Player.CharacterAdded:Wait();

local Data = Player.Data;

local PlayerStand = Data.Stand;
local PlayerAttribute = Data.Attri;

--++ Game Variables --++
local Events = ReplicatedStorage.Events;
local BuyEvent = Events.BuyItem;

--++-- Functions --++--
local function ChatMessageInstance(Message)
	StarterGui:SetCore("ChatMakeSystemMessage",{
		['Text'] = Message,
		['Color'] = Color3.fromRGB(44, 180, 52),
		['Font'] = Enum.Font.SourceSansLight
	});
end;

function PerfomanceFunctions.IncreaseQualityLevel()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F10, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F10, false, nil)
    return
end

function PerfomanceFunctions.DecreaseQualityLevel()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, nil)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F10, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F10, false, nil)
    return
end

function PerfomanceFunctions.SetQualityLevel(QualityLevel)
    assert(type(QualityLevel) == "number")
    QualityLevel = math.clamp(QualityLevel, 1, 10)
    local DeltaQualityLevel = UserSettings().GameSettings.SavedQualityLevel.Value - QualityLevel
    for _ = 1, math.abs(DeltaQualityLevel) do
        if DeltaQualityLevel < 0 then
           PerfomanceFunctions.IncreaseQualityLevel()
        else
           PerfomanceFunctions.DecreaseQualityLevel()
        end
    end
    return
end

function RollFunctions.EquipItem(Item)
    if not Item then
		return;
	end;
	Item = Backpack:FindFirstChild(Item);

    if Item then
        Item.Parent = Character;
        return Item;
    end
end

function RollFunctions.UnequipAll()
    for _, Item in pairs(Character:GetChildren()) do
        if Item:IsA("Tool") then
            Item.Parent = Backpack;
        end;
    end;
end

function RollFunctions.UseItem(Item)
    local NewItem  = RollFunctions.EquipItem(Item);
    NewItem:FindFirstChild("Use"):FireServer();
end

function RollFunctions.BuyItems()
    BuyEvent:FireServer("MerchantAU", "Option4");
    BuyEvent:FireServer("MerchantAU", "Option2");
end

function  RollFunctions.RollToggle()
    RollFunctions.RollToggledBool = not RollFunctions.RollToggledBool;

    while RollFunctions.RollToggledBool == true do
        task.wait();

        if (PlayerStand.Value ~= "None") then
            if RollSettings.Stands[PlayerStand.Value] and RollSettings.Stands[PlayerStand.Value] == true then
                RollFunctions.RollToggledBool = false;

                ChatMessageInstance(Messages.STAND_ATTRIBUTE_MESSAGE:format(PlayerStand.Value, PlayerAttribute.Value));

                if PerformanceSettings.KickUponRoll == true then
                    Player:Kick(Messages.STAND_ATTRIBUTE_MESSAGE:format(PlayerStand.Value, PlayerAttribute.Value));
                end

                break;
            end;

            if RollSettings.Attributes[PlayerAttribute.Value] and RollSettings.Attributes[PlayerAttribute.Value] == true then
                RollFunctions.RollToggledBool = false;
                ChatMessageInstance(Messages.STAND_ATTRIBUTE_MESSAGE:format(PlayerStand.Value, PlayerAttribute.Value));

                if PerformanceSettings.KickUponRoll == true then
                    Player:Kick(Messages.STAND_ATTRIBUTE_MESSAGE:format(PlayerStand.Value, PlayerAttribute.Value));
                end

                break;
            end;

            RollFunctions.UseItem("Rokakaka");
        end;

        task.spawn(function()
            wait(2);
            RollFunctions.BuyItems();
        end);

        task.spawn(function()
            if (PlayerStand.Value ~= "None") then
                return;
            end;
            if RollFunctions.RollBusy == true then
                return;
            end

            RollFunctions.RollBusy = true;
            RollFunctions.UseItem("Stand Arrow");
            task.wait(2);
            RollFunctions.UseItem("Rokakaka");
            task.wait(1);
            RollFunctions.RollBusy = false;
        end)

    end;
end

coroutine.wrap(function()
    do -- Decrease Quality
        if (PerformanceSettings.DecreaseQuality) == true then
            PerfomanceFunctions.SetQualityLevel(1);
            local function Check(v)
                if v:IsA'Part' then
                    v.Material = Enum.Material.Plastic;
                elseif v.ClassName:match'Light' then
                    v:Destroy'';
                elseif v.ClassName:match'Effect' then
                    pcall(function()
                        v.Enabled = false;
                    end);
                end;
            end;
            
            local Lighting = game:GetService'Lighting';
            for i, v in next, Lighting:GetChildren'' do
                Check(v);
            end;
            
            Lighting.DescendantAdded:Connect(Check);
            
            for i, v in next, workspace:GetDescendants() do
                Check(v);
            end;
            
            workspace.DescendantAdded:Connect(Check);
        end;
    end; -- Decrease Quality

	task.wait(7);
    mousemoveabs(900, 600)  
    task.wait(1);
    for i = 1, 10 do
        SimulateLeftClick();
    end
    task.wait(2);

    ChatMessageInstance(Messages.EXECUTE_MESSAGE);
    ChatMessageInstance(Messages.CREDIT_MESSAGE);
    ChatMessageInstance(Messages.PLATFORM_TELEPORT_MESSAGE);
    task.wait(3);
    
    local Platform = Instance.new("Part", workspace);
    Platform.CFrame = Platform.CFrame * CFrame.new(0, -100, 0);
    Platform.Size = Vector3.new(50, 50, 50)
    Platform.Anchored = true;

    Character.HumanoidRootPart.CFrame = Platform.CFrame * CFrame.new(0, 5, 0);

    task.wait(1);
    RollFunctions.RollToggle();
end)()
