if Executed == true then
    return;
end
pcall(function() getgenv().Executed = true end)

--++ Services --++--
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("RbxAnalyticsService");

--++ Synapse API Services --++--
local SimulateLeftClick = mouse1click;
local SimulateLeftHold = mouse1press;
local SimulateLeftRelease = mouse1release;

local SimulateRightClick = mouse2click;
local SimulateRightHold = mouse2press;
local SimulateRightRelease = mouse2release;

local SetConsoleTitle = rconsolename;
local ConsolePrint = rconsoleprint;
local ConsoleClear = rconsoleclear;
local ConsoleInfo = rconsoleinfo;
local ConsoleInput = rconsoleinput;

local Request = syn.request;

--++ Script Services --++--
local Settings = _G.Settings;

local PerfomanceSettings = Settings.Perfomace;
local HTTPSettings = Settings.HTTPSettings;
local RollableSettings = Settings.Rollable;

local RollableStands = RollableSettings.Stands;
local RolllableAttributes = RollableSettings.Attributes;

local FarmActive = false;

--++-- Player Variables --++--
local Player = Players.LocalPlayer;
local PlayerHWID = AnalyticsService:GetClientId();

local Data = Player.Data;

local PlayerStand = Data.Stand;
local PlayerAttribute = Data.Attri;

local Character = Player.Character;

--++ Functions --++--
local function FarmToggle()
    FarmActive = not FarmActive;

    ConsolePrint("@@WHITE@@");
    ConsolePrint("\n------------------------------------------------------");
    ConsolePrint("\nFarm " .. FarmActive and "Started" or not FarmActive and "Stopped");
end

--++-- Wait until Loaded --++--
coroutine.wrap(function()
    task.wait(2);

    repeat task.wait()
    
    until Player.PlayerGui.MenuGUI.Enabled == false;
    
    --++-- Create Console --++--
    SetConsoleTitle("Stand Upright Rebooted: Stand Farm");
    ConsolePrint("Welcome " .. Player.Name .. " (" .. PlayerHWID ..")");
    ConsolePrint("\n------------------------------------------------------");
    ConsolePrint("\nCurrent Stats: " .. PlayerStand.Value .. "/" .. PlayerAttribute.Value);
    ConsolePrint("\n------------------------------------------------------");
    ConsolePrint("\nCommands");
    ConsolePrint("\n------------------------------------------------------");
    ConsolePrint("\n rstart - Starts the Farm");
    ConsolePrint("\n rstop - Stops the Farm");
    ConsolePrint("\n rcmds - Displays the commands");

    local Success, Error = pcall(function()
        local Commands = {
            ["rstart"] = function()
                if FarmActive == true then
                    ConsolePrint("@@WHITE@@");
                    ConsolePrint("\n------------------------------------------------------");
                    ConsolePrint("\nFarm Already Active");
                    return;
                end

                ConsolePrint("\n------------------------------------------------------");
                ConsolePrint("\nStand Farm Starting");
                task.wait(2);
                ConsolePrint("\n------------------------------------------------------");
                ConsolePrint("\nActive Stands and Attributes");

                for Stand, Enabled in pairs(RollableStands) do
                    if (Enabled) == true then
                        ConsolePrint("@@YELLOW@@");
                        ConsolePrint("\n" .. Stand);
                    end
                end;

                for Attribute, Enabled in pairs(RolllableAttributes) do
                    ConsolePrint("\n------------------------------------------------------");
                    if (Enabled) == true then
                        ConsolePrint("@@CYAN@@");
                        ConsolePrint("\n" .. Attribute);
                    end
                end;

                FarmToggle();
            end,
            ["rstop"] = function()
                if FarmActive == false then
                    ConsolePrint("@@WHITE@@");
                    ConsolePrint("\n------------------------------------------------------");
                    ConsolePrint("\nFarm not Active. Cannot stop");
                    return;
                end
                ConsolePrint("@@WHITE@@");
                ConsolePrint("\n------------------------------------------------------");
                ConsolePrint("\nStand Farm Stopping");

            end,
            ["rcmds"] = function()
                ConsolePrint("@@WHITE@@");
                ConsolePrint("\n------------------------------------------------------");
                ConsolePrint("\nCommands");
                ConsolePrint("\n------------------------------------------------------");
                ConsolePrint("\n rstart - Starts the Farm");
                ConsolePrint("\n rstop - Stops the Farm");
                ConsolePrint("\n rcmds - Displays the commands");
            end
        }

        Player.Chatted:Connect(function(Message)
             if Commands[Message] then
                Commands[Message]();
             end
        end)
    end)
    
end)()


