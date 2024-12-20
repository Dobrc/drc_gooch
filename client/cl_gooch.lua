local attackerPed = nil
local isAttackerSpawned = false

RegisterNetEvent('attacker:spawnAttackerClient')
AddEventHandler('attacker:spawnAttackerClient', function()
    if isAttackerSpawned then
        return
    end
    isAttackerSpawned = true

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local pedModel = `U_M_M_YuleMonster`
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

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

    RequestNamedPtfxAsset(ptfxDict)
    while not HasNamedPtfxAssetLoaded(ptfxDict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(ptfxDict)
    local ptfxHandle = StartNetworkedParticleFxLoopedOnEntity(ptfxName, attackerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 0)
    SetParticleFxLoopedColour(ptfxHandle, 0.0, 1.0, 0.0)

    TaskGoToEntity(attackerPed, playerPed, -1, 1.0, 2.0, 1073741824.0, 0)

    CreateThread(function()
        local ragdolled = false
        while isAttackerSpawned and DoesEntityExist(attackerPed) do
            Wait(100)
            local attackerCoords = GetEntityCoords(attackerPed)
            local distance = #(attackerCoords - GetEntityCoords(playerPed))

            if distance < 1.5 and not ragdolled and not IsPedDeadOrDying(attackerPed, true) then
                SetPedToRagdoll(playerPed, 2000, 2000, 0, true, true, false)
                ragdolled = true
                TaskSmartFleePed(attackerPed, playerPed, 100.0, -1, true, true)
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
    end)
end)

local giftSpehere = nil
RegisterNetEvent('attacker:addPropTarget')
AddEventHandler('attacker:addPropTarget', function(propNet)
    giftSpehere = nil
    local prop = NetToObj(propNet)
    PlaceObjectOnGroundProperly(prop)
    local giftPosition = GetEntityCoords(prop)

    local function openReward()
        if Config.InteractionType == 'target' then
            RemoveZone("gooch_reward")
        else
            giftSpehere:remove()
        end
        local propCoords = GetEntityCoords(prop)
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
        Wait(2000)
        RequestAnimDict("anim@amb@business@coc@coc_unpack_cut@")
        while not HasAnimDictLoaded("anim@amb@business@coc@coc_unpack_cut@") do
            Wait(0)
        end

        TaskPlayAnim(ped, 'anim@amb@business@coc@coc_unpack_cut@', 'fullcut_cycle_v6_cokecutter', 8.0, -8.0, -1, 49, 0, 0, 0, 0)

        CreateThread(function()
            local startTime = GetGameTimer()

            while (GetGameTimer() - startTime) < 4000 do
                UseParticleFxAssetNextCall("core")
                StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_newspaper", propCoords.x, propCoords.y, propCoords.z + 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
                Wait(1000)
            end
        end)

        ProgressBar(4000, "Opening gift")

        ClearPedTasks(ped)
        DeleteEntity(prop)
        FreezeEntityPosition(ped, false)
        TriggerServerEvent('drc_gooch:addrewards')
        Notify('info', 'Gooch !', Config.Locales.NiceGiftFromGooch)
    end

    if Config.InteractionType == 'target' then
        AddCircleZone("gooch_reward", vec3(giftPosition.x, giftPosition.y, giftPosition.z), 0.75, {
            useZ = true,
            name = "gooch_reward",
            debugPoly = Config.Debug
        }, {
            options = {
                {
                    action = function()
                        openReward()
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
                    openReward()
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