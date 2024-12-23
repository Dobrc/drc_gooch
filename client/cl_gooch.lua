local attackerPed = nil
local isAttackerSpawned = false

RegisterNetEvent('attacker:spawnAttackerClient')
AddEventHandler('attacker:spawnAttackerClient', function()
    if isAttackerSpawned then
        return
    end
    isAttackerSpawned = true

    local playerCoords = GetEntityCoords(cache.ped)

    local pedModel = `U_M_M_YuleMonster`
    lib.requestModel(pedModel)

    local spawnCoords = vector3(playerCoords.x + math.random(-30, 10), playerCoords.y + math.random(-30, 10), playerCoords.z)
    attackerPed = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    SetModelAsNoLongerNeeded(pedModel)

    SetPedFleeAttributes(attackerPed, 0, false)
    SetPedCombatAttributes(attackerPed, 46, true)
    SetPedCanRagdoll(attackerPed, true)
    SetBlockingOfNonTemporaryEvents(attackerPed, true)
    SetPedDiesWhenInjured(attackerPed, true)
    SetPedCanPlayAmbientAnims(attackerPed, true)
    SetPedCanUseAutoConversationLookat(attackerPed, true)

    local ptfxDict = "scr_sum2_hal"
    local ptfxName = "scr_sum2_hal_rider_death_green"

    lib.requestNamedPtfxAsset(ptfxDict)
    UseParticleFxAssetNextCall(ptfxDict)
    local ptfxHandle = StartNetworkedParticleFxLoopedOnEntity(ptfxName, attackerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 0)
    SetParticleFxLoopedColour(ptfxHandle, 0.0, 1.0, 0.0)

    TaskGoToEntity(attackerPed, cache.ped, -1, 1.0, 2.0, 1073741824.0, 0)

    CreateThread(function()
        local ragdolled = false
        while isAttackerSpawned and DoesEntityExist(attackerPed) do
            Wait(100)
            local attackerCoords = GetEntityCoords(attackerPed)
            local distance = #(attackerCoords - GetEntityCoords(cache.ped))

            if distance < 1.5 and not ragdolled and not IsPedDeadOrDying(attackerPed, true) then
                SetPedToRagdoll(cache.ped, 2000, 2000, 0, true, true, false)
                ragdolled = true
                TaskSmartFleePed(attackerPed, cache.ped, 100.0, -1, true, true)
                SetPedAsNoLongerNeeded(attackerPed)
                TriggerServerEvent('drc_gooch:takemoney')
                Notify('info', 'Gooch !', Config.Locales.GoochStoleMoney)
            end

            if IsPedDeadOrDying(attackerPed, true) then
                local deathCoords = GetEntityCoords(attackerPed)

                UseParticleFxAssetNextCall(ptfxDict)
                StartNetworkedParticleFxNonLoopedAtCoord(ptfxName, deathCoords.x, deathCoords.y, deathCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)

                DeletePed(attackerPed)
                attackerPed = nil
                isAttackerSpawned = false

                TriggerServerEvent('attacker:pedKilled', deathCoords)
                break
            end
        end

        RemoveNamedPtfxAsset(ptfxDict)
    end)
end)

local giftSpehere = nil

function OpenReward(rewardPosition)
    if Config.InteractionType == 'target' then
        RemoveZone("gooch_reward")
    else
        giftSpehere:remove()
    end
    FreezeEntityPosition(cache.ped, true)
    TaskStartScenarioInPlace(cache.ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
    Wait(2000)
    lib.requestAnimDict("anim@amb@business@coc@coc_unpack_cut@")
    TaskPlayAnim(cache.ped, 'anim@amb@business@coc@coc_unpack_cut@', 'fullcut_cycle_v6_cokecutter', 8.0, -8.0, -1, 49, 0, 0, 0, 0)
    RemoveAnimDict("anim@amb@business@coc@coc_unpack_cut@")

    CreateThread(function()
        local startTime = GetGameTimer()

        lib.requestNamedPtfxAsset('core')

        while (GetGameTimer() - startTime) < 4000 do
            UseParticleFxAssetNextCall("core")
            StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_newspaper", rewardPosition.x, rewardPosition.y, rewardPosition.z + 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
            Wait(1000)
        end

        RemoveNamedPtfxAsset('core')
    end)

    ProgressBar(4000, "Opening gift")

    ClearPedTasks(cache.ped)
    FreezeEntityPosition(cache.ped, false)
    TriggerServerEvent('drc_gooch:addrewards')
    Notify('info', 'Gooch !', Config.Locales.NiceGiftFromGooch)
end

RegisterNetEvent('attacker:addPropTarget')
AddEventHandler('attacker:addPropTarget', function(propNet)
    giftSpehere = nil

    local spawnTries = 10

    while not NetworkDoesEntityExistWithNetworkId(propNet) do
        spawnTries -= 1

        if spawnTries <= 0 then
            print("Failed to get prop entity by net id.")
            return
        end

        Wait(100)
    end

    local prop = NetToObj(propNet)

    if not DoesEntityExist(prop) then
        print("Failed to get prop entity.")
        return
    end

    PlaceObjectOnGroundProperly(prop)
    local giftPosition = GetEntityCoords(prop)

    if Config.InteractionType == 'target' then
        AddCircleZone("gooch_reward", vec3(giftPosition.x, giftPosition.y, giftPosition.z), 0.75, {
            useZ = true,
            name = "gooch_reward",
            debugPoly = Config.Debug
        }, {
            options = {
                {
                    action = function()
                        OpenReward(giftPosition)
                    end,
                    icon = "fas fa-gift",
                    label =  Config.Locales.OpenGift
                }
            },
            distance = 1.5
        })
    else
        giftSpehere = lib.zones.sphere({
            coords = vec3(giftPosition.x, giftPosition.y, giftPosition.z),
            radius = 2.0,
            debug = Config.Debug,
            inside = function(self)
                if IsControlJustReleased(0, 38) then
                    OpenReward(giftPosition)
                end
                if Config.InteractionType == "3dtext" then
                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s",  Config.Locales.OpenGift))
                end
            end,
            onEnter = function()
                if Config.InteractionType == "textui" then
                    TextUIShow(string.format("[E] - %s",  Config.Locales.OpenGift))
                end    
            end,
            onExit = function()
                if Config.InteractionType == "textui" then
                    TextUIHide()
                end
            end
        })
    end
end)