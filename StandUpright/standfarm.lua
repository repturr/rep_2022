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

local FunctionConnections = {
    AutoBuyActive = false;
    AutoRollActive = false;
};
local StartupConfirmed = false;

--++ Game Variables --++--
local EventBinder = ReplicatedStorage.Events;


--++ Functions --++--
local function GetTool(Tool)
	if Backpack:FindFirstChild(Tool) then
		Tool = Backpack[Tool]
		return Tool;
	end;
	return nil;
end;

local function EquipTool(Tool)
	if not Tool then
		return;
	end;
	for _, __Tool in pairs(Character:GetChildren()) do
		if __Tool:IsA("Tool") then
			__Tool.Parent = Backpack;
		end;
	end;

	Tool.Parent = Character;
end;

local function UnequipAll()
    for _, Item in pairs(Character:GetChildren()) do
        if Item:IsA("Tool") then
            Item.Parent = Backpack;
        end;
    end;
end

local function Buy(Item)
	local BuyItemEvent = EventBinder.BuyItem;
	local Options = {
		["Stand Arrow"] = "Option4",
		["Rokakaka"] = "Option2"
	};

	local ItemToBuy = Options[Item];
	BuyItemEvent:FireServer("MerchantAU", ItemToBuy);
end;

local function Use(Item)
   UnequipAll();

	EquipTool(Item);
	Item:FindFirstChild("Use"):FireServer();
end;

local function CreateMessage(Message)
	StarterGui:SetCore("ChatMakeSystemMessage",{
		['Text'] = Message,
		['Color'] = Color3.fromRGB(44, 180, 52),
		['Font'] = Enum.Font.SourceSansLight
	});
end;

local function CreateNotification(Message, Duration)
    StarterGui:SetCore("SendNotification", {
        Title = "SUR Stand Farm";
        Text = Message;
        Duration = Duration;
    });
end;

local function Autobuy()
    FunctionConnections.AutoBuyActive = not FunctionConnections.AutoBuyActive;

    task.spawn(function()
        while FunctionConnections.AutoBuyActive == true do
            task.wait(BuyItemInterval);
            local OwnsArrows = false;
            local OwnsRokas = false;

            for _, Item in pairs(Backpack:GetChildren()) do
                if Item:IsA("Tool") then
                if Item.Name == "Rokakaka" then
                    OwnsRokas = true;
                end;

                if Item.Name == "Stand Arrow" then
                    OwnsArrows = true;
                end;
              end;
            end;

            for _, Item in pairs(Character:GetChildren()) do
                if Item:IsA("Tool") then
                    if Item.Name == "Rokakaka" then
                        OwnsRokas = true
                    end

                    if Item.Name == "Stand Arrow" then
                        OwnsArrows = true
                    end;
                end;
            end;

            if OwnsRokas == false then
                Buy("Rokakaka");
            end;

            if OwnsArrows == false then
                if ArrowType ~= "Charged Arrow" then
                Buy("Stand Arrow");
                end;
            end
        end;
    end);
end;

local function AutoRoll()
    local UsingVariable = false;
    FunctionConnections.AutoRollActive = not FunctionConnections.AutoRollActive;

        task.wait(1);
        do
            if (StandData.Value) == "None" then
                local Arrow = GetTool(ArrowType);

                if (Arrow) then
                    Use(Arrow);
            end;
        end;
        UsingVariable = false;

        while FunctionConnections.AutoRollActive == true do
            task.wait(.25);
            if UsingVariable == true then
                return;
            end;

            local Roka = GetTool("Rokakaka");
            local Arrow = GetTool(ArrowType);
    
            if Roka and Arrow then
                UsingVariable = true;
                UnequipAll();
                Use(Roka);
                task.wait(2);
                UnequipAll();
                Use(Arrow);
                task.wait(1);
                UsingVariable = false;
            end;
        end
    end);
end;


local function WebhookMessage(Message, Color)
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
				["color"] = Color,
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

local StartupCall, StartupReturnedData = pcall(function()
    task.spawn(function()
        CreateMessage("SUR Stand Farm: By Repturr");
	    WebhookMessage("Webhook Attached", tonumber(0xffd500));
    end);
	
	if Player and Character and Data then
     return true;
	end;

    return false;
end);

local function RunScript(Value)
    local Functions = {
        [true] = function()
          local WarningNotification = CreateNotification("Warning this will ROKA your current stand in 10 seconds \n " .. StandData.Value .. " / " .. AttributeData.Value);
          task.wait(10);
          
          do
            local Roka = GetTool("Rokakaka");

            if Roka then
                Use(Roka);
            elseif not Roka then
                Buy("Rokakaka");
                task.wait(.25);
                Roka = GetTool("Rokakaka");
                Use(Roka);
            end;
          end;

          local Platform = Instance.new("Part", workspace); 
          Platform.Size = Vector3.new(50, 50, 50);
          Platform.Anchored = true;
          Platform.CFrame = Platform.CFrame * CFrame.new(0, -50, 0);

          CreateMessage("SUR Stand Farm: Teleporting to hidden platform");
          task.wait(1.50);

          Character.HumanoidRootPart.CFrame = Platform.CFrame * CFrame.new(0, 5, 0);
          CreateMessage("SUR Stand Farm: Starting Farm");

          Player.Idled:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)

          Autobuy();
          AutoRoll();

          task.spawn(function()
            while task.wait() do
                if (Settings.Attributes[AttributeData.Value] and Settings.Attributes[AttributeData.Value] == true) then
                    Autobuy();
                    AutoRoll();
                    CreateMessage("Got Stand: " .. StandData.Value);
                    CreateMessage("Got Attribute: " .. AttributeData.Value);
                    WebhookMessage("Stats: "  .. StandData.Value  .. "/" ..  AttributeData.Value,  tonumber(0x40ff00));

                    if Settings.KickUponRoll == true then
                        Player:Kick("Requested Kick Upon Roll \n " .. StandData.Value .. "/" .. AttributeData.Value);
                    end

                    task.wait(.50);
                    Platform:Destroy();
                    break;
                end;
    
                if (Settings.Stands[StandData.Value] and Settings.Stands[StandData.Value] == true) then
                    Autobuy();
                    AutoRoll();
                    CreateMessage("Got Stand: " .. StandData.Value);
                    CreateMessage("Got Attribute: " .. AttributeData.Value);
                    WebhookMessage("Stats: "  .. StandData.Value  .. "/" ..  AttributeData.Value,  tonumber(0x40ff00));
                  
                    task.wait(.50);
                    Platform:Destroy();
                    break;
                end;
            end
          end)

        end,
        [false] = function()
            
        end,
    };

    local Success, Error = pcall(function()
        task.spawn(function()
            Functions[Value]();
        end);
    end)
end

RunScript(StartupReturnedData)