TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local sprite = {}
local colour = {}
local create = false
local gestion = false
local rBlipbuild = {
    name = nil,
    coords = nil,
    sprite = nil,
    colour = nil,

    IndexSprite = 1,
    IndexColour = 1
}
local AllBlip = {}
-----------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("rBlip:GetGroupPlayer")
AddEventHandler("rBlip:GetGroupPlayer", function()
    RefreshBlip()
    OpenBuilder()
end)
-----------------------------------------------------------------------------------------------------------------------------
function GetNumber()
    for i = 0, 600, 1 do
        table.insert(sprite, i)
    end
    for i = 0, 100, 1 do
        table.insert(colour, i)
    end
end

GetNumber()

function OpenBuilder()
    local Menu = RageUI.CreateMenu(Cfg_blips.Name, "Que voulez-vous faire ?")
    RageUI.Visible(Menu, true)
    CreateThread(function()
        while Menu do
            Wait(0)
            RageUI.IsVisible(Menu, function()
                RageUI.Checkbox("Crée un blip", nil, create, {}, {
                    onChecked = function()
                        create = true
                    end,
                    onUnChecked = function()
                        create = false
                    end
                })
                if create then
                    RageUI.Button("Nom du blip", nil, {RightLabel = rBlipbuild.name}, true, {
                        onSelected = function()
                            rBlipbuild.name = KeyboardInput("Comment voulez-vous appeller le blip ?", "", 200)
                        end
                    })
                    if rBlipbuild.coords == nil then
                        RageUI.Button("Coordonnée", nil, {RightLabel = "❌"}, true, {
                            onSelected = function()
                                rBlipbuild.coords = GetEntityCoords(PlayerPedId())
                            end
                        })
                    else
                        RageUI.Button("Coordonnée", nil, {RightLabel = "✅"}, true, {
                            onSelected = function()
                                rBlipbuild.coords = GetEntityCoords(PlayerPedId())
                            end
                        })
                    end
                    RageUI.List("Sprite du blip", sprite, rBlipbuild.IndexSprite, "Appuyez sur W pour indiquez un type de blip", {}, true, {
                        onListChange = function(a)
                            rBlipbuild.IndexSprite = a
                            RemoveBlip(blip)
                        end,
                        onActive = function()
                            if IsControlJustPressed(1, 20) then
                                local blips = tonumber(KeyboardInput("Indiquez le type de blip que vous voulez ", "", 20))
                                if blips ~= nil then
                                    rBlipbuild.IndexSprite = blips
                                end
                            end
                        end,
                        onSelected = function()
                            local coords = GetEntityCoords(PlayerPedId())
                            blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                            SetBlipSprite(blip, rBlipbuild.IndexSprite)
                            SetBlipDisplay(blip, 4)
                            SetBlipColour(blip, 1)
                            SetBlipScale(blip, 1.0)
                            SetBlipAsShortRange(blip, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(rBlipbuild.name)
                            EndTextCommandSetBlipName(blip)
                            rBlipbuild.sprite = rBlipbuild.IndexSprite
                        end
                    })
                    RageUI.List("Couleur du blip", colour, rBlipbuild.IndexColour, nil, {}, true, {
                        onListChange = function(a)
                            rBlipbuild.IndexColour = a
                            SetBlipColour(blip, rBlipbuild.IndexColour)
                        end,
                        onSelected = function()
                            rBlipbuild.colour = rBlipbuild.IndexColour
                        end
                    })
                    if rBlipbuild.name ~= nil and rBlipbuild.coords ~= nil and rBlipbuild.sprite ~= nil and rBlipbuild.colour ~= nil then
                        RageUI.Button("~b~Crée le blips", nil, {}, true, {
                            onSelected = function()
                                TriggerServerEvent("rBlip:CreateBlip", rBlipbuild)
                                RemoveBlip(blip)
                                RefreshBlip()
                                create = false
                            end
                        })
                    end
                end
                RageUI.Checkbox("Gestion des blips", nil, gestion, {}, {
                    onChecked = function()
                        gestion = true
                        RefreshBlip()
                    end,
                    onUnChecked = function()
                        gestion = false
                    end
                })
                if gestion then
                    for k,v in pairs(AllBlip) do
                        RageUI.Button("Blip : ~b~"..v.name, "Sprite : ~b~"..v.sprite.."~s~\nCouleur : ~b~"..v.colour.."~s~\nAppuyez sur E pour supprimer", {}, true, {
                            onSelected = function()
                                SetEntityCoords(PlayerPedId(), json.decode(v.coords).x, json.decode(v.coords).y, json.decode(v.coords).z)
                                ESX.ShowNotification("Vous venez de vous teleporter sur le blip : ~b~"..v.name)
                            end,
                            onActive = function()
                                if IsControlJustPressed(1, 51) then
                                    TriggerServerEvent("rBlip:DeleteBlip", v.name)
                                    table.remove(AllBlip, k)
                                    AllBlips(false)
                                end
                            end
                        })
                    end
                end

                RageUI.Button("Rafraichir les blips", nil, {}, true, {
                    onSelected = function()
                        RefreshBlip()
                        AllBlips(true)
                    end
                })
            end)
        end
    end)
end

-----------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("blipbuilder", "Ouvrir le blips builder (Staff)", "keyboard", Cfg_blips.Touche)
RegisterCommand("blipbuilder", function()
    TriggerServerEvent("rBlip:GetGroupPlayer")
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function AllBlips(type)
    ESX.TriggerServerCallback("rBlip:GetBlip", function(result)
        if type then
            print(true)
            for k,v in pairs(result) do
                blipbuild = AddBlipForCoord(json.decode(v.coords).x, json.decode(v.coords).y, json.decode(v.coords).z)
                SetBlipSprite(blipbuild, v.sprite)
                SetBlipDisplay(blipbuild, 4)
                SetBlipColour(blipbuild, v.colour)
                SetBlipScale(blipbuild, 0.8)
                SetBlipAsShortRange(blipbuild, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(blipbuild)
            end
        else
            print(false)
            RemoveBlip(blipbuild)
        end
    end)
end

function RefreshBlip()
    ESX.TriggerServerCallback("rBlip:GetBlip", function(result)
        AllBlip = result
    end)
end

CreateThread(function()
    AllBlips(true)
end)