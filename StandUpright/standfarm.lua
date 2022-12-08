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
local CollectionService = game:GetService("CollectionService")
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
    AutoRollUsingItem = false;
    AutoRollInUse = false;
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
          if (StandData.Value ~= "None") then
            CreateNotification("Warning this will ROKA your current stand in 10 seconds \n " .. StandData.Value .. " / " .. AttributeData.Value);
            task.wait(10);

            local Roka = GetTool("Rokakaka");

            if Roka then
                Use(Roka);
            elseif not Roka then
                Buy("Rokakaka");
                task.wait(.15);
                Roka = GetTool("Rokakaka");

                Use(Roka);
            end
          end

          local Platform = Instance.new("Part", workspace); 
          Platform.Size = Vector3.new(50, 50, 50);
          Platform.Anchored = true;
          Platform.CFrame = Platform.CFrame * CFrame.new(0, -50, 0);

          CreateMessage("SUR Stand Farm: Teleporting to hidden platform");
          task.wait(1.50);

          Character.HumanoidRootPart.CFrame = Platform.CFrame * CFrame.new(0, 5, 0);
          CreateMessage("SUR Stand Farm: Starting Farm");

          local Arrow = GetTool(ArrowType);

          if Arrow then
            Use(Arrow);
          elseif not Arrow then
            Buy("Stand Arrow");
            task.wait(.15);
            Arrow = GetTool("Stand Arrow");
            Use(Arrow);
          end;

          task.spawn(function()
            while task.wait() do
                if Settings.Attributes[AttributeData.Value] and Settings.Attributes[AttributeData.Value] == true then
                    FunctionConnections.AutoBuyActive = false;
                    FunctionConnections.AutoRollActive = false;

                    CreateMessage("SUR Stand Farm: " .. StandData.Value .. "/" .. AttributeData.Value);
                    WebhookMessage(StandData.Value .. "/" .. AttributeData.Value, tonumber(0x42f551));
                    return;
                end
            end
          end)

          task.spawn(function()
            while task.wait() do
                if Settings.Stands[StandData.Value] and Settings.Stands[StandData.Value] == true then
                    FunctionConnections.AutoBuyActive = false;
                    FunctionConnections.AutoRollActive = false;

                    CreateMessage("SUR Stand Farm: " .. StandData.Value .. "/" .. AttributeData.Value);
                    WebhookMessage(StandData.Value .. "/" .. AttributeData.Value, tonumber(0x42f551));
                    return;
                end
            end
          end)

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
            end
        end)

        task.spawn(function()
            local UsingTool = ""

            while FunctionConnections.AutoRollActive == true do
                if (StandData.Value == "None") then
                    local _Arrow = GetTool(ArrowType);

                    if _Arrow then
                        if UsingTool ~= "Stand Arrow" then
                            return;
                        end
                        Use(_Arrow);
                    end
                else
                    local _Roka = GetTool("Rokakaka");

                    if _Roka then
                        if UsingTool ~= "Rokakaka" then
                            return;
                        end
                        Use(_Roka);
                    end
                end


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