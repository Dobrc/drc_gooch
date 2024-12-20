local attacks = {}

CreateThread(function()
    local interval = Config.GoochSpawn * 60000

    while true do
        Wait(interval)

        local players = GetPlayers()

        if not players or #players < 1 then
            print("No players online, skipping Gooch spawn this cycle.")
            goto skip
        end

        local randomIndex = math.random(#players)
        local attackerTarget = tonumber(players[randomIndex])
        attacks[tostring(attackerTarget)] = {}
        TriggerClientEvent('attacker:spawnAttackerClient', attackerTarget)

        ::skip::
    end
end)

if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
    ESX.RegisterCommand('spawnGooch', 'admin', function(xPlayer, args, showError)
        if xPlayer.getGroup() ~= 'admin' then
            xPlayer.showNotification("You do not have permission to use this command.")
            return
        end

        local playerID = tonumber(args[1])
        if not playerID or not GetPlayerName(playerID) then
            xPlayer.showNotification("Invalid player ID.")
            return
        end

        local rewardKey = args[2]
        local chosenRewardKey = nil

        if rewardKey and Config.AddRewards[rewardKey] then
            chosenRewardKey = rewardKey
        else
            local rewardKeys = {}
            for k, _ in pairs(Config.AddRewards) do
                table.insert(rewardKeys, k)
            end
            local randomIndex = math.random(#rewardKeys)
            chosenRewardKey = rewardKeys[randomIndex]
        end

        attacks[tostring(playerID)] = {}
        TriggerClientEvent('attacker:spawnAttackerClient', playerID)
        xPlayer.showNotification("Spawned Gooch on player " .. playerID .. " with reward: " .. chosenRewardKey)
    end, {
        help = 'Spawn Gooch on a player',
        arguments = {
            { name = 'playerId', help = 'ID of the player', type = 'number' },
            { name = 'rewardKey', help = 'Optional reward key', type = 'string' }
        }
    })

elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Commands.Add('spawnGooch', 'Spawn Gooch on a player', {{name='playerId', help='Player ID'}, {name='rewardKey', help='Optional reward key'}}, false, function(source, args)
        if not QBCore.Functions.HasPermission(source, "admin") then
            TriggerClientEvent('QBCore:Notify', source, "You do not have permission to use this command.", "error")
            return
        end

        local playerID = tonumber(args[1])
        if not playerID or not GetPlayerName(playerID) then
            TriggerClientEvent('QBCore:Notify', source, "Invalid player ID.", "error")
            return
        end

        local rewardKey = args[2]
        local chosenRewardKey = nil

        if rewardKey and Config.AddRewards[rewardKey] then
            chosenRewardKey = rewardKey
        else
            local rewardKeys = {}
            for k, _ in pairs(Config.AddRewards) do
                table.insert(rewardKeys, k)
            end
            local randomIndex = math.random(#rewardKeys)
            chosenRewardKey = rewardKeys[randomIndex]
        end

        attacks[tostring(playerID)] = {}
        TriggerClientEvent('attacker:spawnAttackerClient', playerID)
        TriggerClientEvent('QBCore:Notify', source, "Spawned Gooch on player " .. playerID .. " with reward: " .. chosenRewardKey, "success")
    end)
end

RegisterNetEvent('attacker:pedKilled')
AddEventHandler('attacker:pedKilled', function(deathCoords)
    local killer = source
    if not attacks[tostring(killer)] or attacks[tostring(killer)].canTakeReward then
        print("Security: Player "..killer.." triggered pedKilled but is not the chosen target.")
        return
    end

    local propModel = `bzzz_xmas_gift_box_a`
    local prop = CreateObject(propModel, deathCoords.x, deathCoords.y, deathCoords.z, true, true, true)
    Wait(100)

    if prop ~= 0 and DoesEntityExist(prop) then
        local propNetId = NetworkGetNetworkIdFromEntity(prop)
        TriggerClientEvent('attacker:addPropTarget', killer, propNetId)

        attacks[tostring(killer)].canTakeReward = true
    else
        print("Failed to create prop. Check if the model is valid and streamed.")
    end
end)

RegisterNetEvent('drc_gooch:takemoney')
AddEventHandler('drc_gooch:takemoney', function()
    local src = source
    if not attacks[tostring(src)] then
        print("Security: Player "..src.." tried to takemoney without permission.")
        return
    end

    local amount = math.random(Config.TakeMoney.Min, Config.TakeMoney.Max)
    RemoveMoney(amount, src)
end)

RegisterNetEvent('drc_gooch:addrewards')
AddEventHandler('drc_gooch:addrewards', function()
    local src = source
    if not attacks[tostring(src)] or not attacks[tostring(src)].canTakeReward then
        print("Security: Player "..src.." tried to addrewards without permission.")
        return
    end

    local randomRewardIndex = math.random(#Config.AddRewards)
    local reward = Config.AddRewards[randomRewardIndex]

    if not reward then
        print("No valid reward found.")
        return
    end

    local money = math.random(reward.Money.Min, reward.Money.Max)
    AddMoney(money, src)

    for _, itemData in ipairs(reward.Items) do
        AddItem(itemData.name, itemData.count, src)
    end

    attacks[tostring(src)] = nil
end)