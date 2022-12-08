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
local RollFunctions = {};

--++-- Player Variables --++--
local Player = Players.LocalPlayer;
local PlayerID = Player.UserId;
local PlayerHWID = RbxAnalyticsService:GetClientId();

local Data = Player.Data;

local PlayerStand = Data.Stand;
local PlayerAttribute = Data.Attri;

--++-- Functions --++--
local function IsLoaded()
    if Player.PlayerGui.MainGUI.Enabled == true then
        return false;
    end
    return true;
end
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

coroutine.wrap(function()
    do
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
    end;

end)()
