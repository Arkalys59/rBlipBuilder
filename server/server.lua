TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("rBlip:GetGroupPlayer")
AddEventHandler("rBlip:GetGroupPlayer", function()
    local player = ESX.GetPlayerFromId(source)
    if player.group == "admin" or player.group == "superadmin" then
        TriggerClientEvent("rBlip:GetGroupPlayer", -1)
    else
        player.showNotification("~r~Vous n'êtes pas staff")
    end
end)

RegisterNetEvent("rBlip:CreateBlip")
AddEventHandler("rBlip:CreateBlip", function(table)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.execute("INSERT INTO blip (name, sprite, colour, coords) VALUES (@name, @sprite, @colour, @coords)", {
        ["@name"] = table.name,
        ["@sprite"] = table.sprite,
        ["@colour"] = table.colour,
        ["@coords"] = json.encode(table.coords)
    })
    SendLogs(GetPlayerName(source).." ["..source.."] viens de crée un blip\n\nBlip : N°"..table.sprite.."\nCouleur : N°"..table.colour.."\nNom : "..table.name, Cfg_log.CreateBlip)
end)

RegisterNetEvent("rBlip:DeleteBlip")
AddEventHandler("rBlip:DeleteBlip", function(name)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.execute("DELETE FROM blip WHERE name = @name", {
        ["@name"] = name,
    })
    SendLogs(GetPlayerName(source).." ["..source.."] viens de supprimer un blip\n\nNom : "..name, Cfg_log.DeleteBlip)
end)

ESX.RegisterServerCallback("rBlip:GetBlip", function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM blip", {}, function(result)
        cb(result)
    end)
end)

function SendLogs (message,url)
    local DiscordWebHook = url
    local embeds = {
        {
            ["title"]=message,
            ["type"]="rich",
            ["color"] = 0xfc0303,
            ["footer"]=  {
                ["text"]= os.date('%d-%m-%Y %H:%M:%S', os.time() + (1 * 60 * 60)),
            },
        }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "Luthers",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end