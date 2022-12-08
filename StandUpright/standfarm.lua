--++-- If Script is already active don't run again --++--
if _G.ScriptActive == true then
	return;
end;
_G.ScriptActive = true;

--++ Script Services --++--
local Settings = _G.Settings;

local ArrowType = Settings.ArrowType;
local BuyItemInterval = Settings.BuyItemInterval;

local Webhook = Settings.Webhook;



--++-- Synapse Services --++--
local request = syn.request;

--++ Get Services --++--
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");
local Players = game:GetService("Players");
local HTTPService = game:GetService("HttpService");
local AnalyticsService = game:GetService("RbxAnalyticsService");

--++ Create Variables --++--
local Player = Players.LocalPlayer;
local PlayerGui = Player.PlayerGui;

local Character = Player.Character;
local Backpack = Player.Backpack;

local Data = Player.Data

local StandData = Data.Stand
local AttributeData = Data.Attri

--++ Game Variables --++--
local EventBinder = ReplicatedStorage.Events;


--++ Functions --++--
local function GetTool(Tool)
	if Backpack:FindFirstChild(Tool) then
		Tool = Backpack[Tool]
		return Tool
	end
	return nil
end

local function EquipTool(Tool)
	if not Tool then
		return
	end
	for _, __Tool in pairs(Character:GetChildren()) do
		if __Tool:IsA("Tool") then
			__Tool.Parent = Backpack
		end
	end

	Tool.Parent = Character
end

local function BuyItem(Item)
	local BuyItemEvent = EventBinder.BuyItem;
	local Options = {
		["Stand Arrow"] = "Option4",
		["Rokakaka"] = "Option2"
	};

	local ItemToBuy = Options[Item];
	BuyItemEvent:FireServer("MerchantAU", ItemToBuy);
end

local function Use(Item)
	EquipTool(Item);
	Item:FindFirstChild("Use"):FireServer();
end

local function CreateMessage(Message)
	StarterGui:SetCore("ChatMakeSystemMessage",{
		['Text'] = Message,
		['Color'] = Color3.fromRGB(44, 180, 52),
		['Font'] = Enum.Font.SourceSansLight
	});
end;

local function WebhookMessage(Message)
    if Webhook == "" then
        return;
    end;

    local Response = request({
        Url = Webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = 'application/json'
        },
        Body = HTTPService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "**SUR Stand Farm**",
                ["description"] = "",
                ["type"] = "rich",
                ["color"] = tonumber(0xffffff),
                ["fields"] = {
                    {
                        ["name"] = "Client",
                        ["value"] = Player.Name,
                        ["inline"] = true;
                    },
                    {
                        ["name"] = "HWID",
                        ["value"] = "**DISABLED**",
                        ["inline"] = true;
                    },
                    {
                        ["name"] = "Container",
                        ["value"] = Message,
                        ["inline"] = false;
                    },
            }
            }}
        })
    })
end

local StartupSuccess, StartupData = xpcall(function()
    CreateMessage("SUR Stand Farm: By Repturr")
    WebhookMessage("Webhook Attached");

    if Player and Character and Data then
        return true;
    end

    return false;
end)


