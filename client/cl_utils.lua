
local function AutoDetectFramework()
    if GetResourceState("es_extended") == "started" then
        return "esx"
    elseif GetResourceState("qb-core") == "started" then
        return "qbcore"
    else
        return "standalone"
    end
end

local function AutoDetectTarget()
    if GetResourceState("qtarget") == "started" then
        return "qtarget"
    elseif GetResourceState("qb-target") == "started" then
        return "qb-target"
    elseif GetResourceState("ox_target") == "started" then
        return "ox_target"
    end
end

if Config.Framework == "auto-detect" then
    Config.Framework = AutoDetectFramework()
end

if Config.FrameworkTarget == "auto-detect" then
    Config.FrameworkTarget = AutoDetectTarget()
end

if Config.Framework == "esx" then
    if Config.NewESX then
        ESX = exports["es_extended"]:getSharedObject()
    else
        ESX = nil
        CreateThread(function()
            while ESX == nil do
                TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
                Wait(100)
            end
        end)
    end
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports["qb-core"]:GetCoreObject()

elseif Config.Framework == "standalone" then
    -- ADD YOU FRAMEWORK
end

Notify = function(type, title, text)
    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(text)
    elseif Config.NotificationType == "ox_lib" then
        if type == "info" then
            lib.notify({
                title = title,
                description = text,
                type = "inform"
            })
        elseif type == "error" then
            lib.notify({
                title = title,
                description = text,
                type = "error"
            })
        elseif type == "success" then
            lib.notify({
                title = title,
                description = text,
                type = "success"
            })
        elseif Config.NotificationType == "qbcore" then
            if type == "success" then
                QBCore.Functions.Notify(text, "success")
            elseif type == "info" then
                QBCore.Functions.Notify(text, "primary")
            elseif type == "error" then
                QBCore.Functions.Notify(text, "error")
            end
        elseif Config.NotificationType == "custom" then
            print("add your notification system! in cl_Utils.lua")
            -- ADD YOUR NOTIFICATION | TYPES ARE info, error, success
        end
    end
end

ProgressBar = function(duration, label)
    if Config.Progress == "ox_lib" then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false
        })
    elseif Config.Progress == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Progressbar(label, label, duration - 500, false, true, {
        }, {}, {}, {}, function()
        end)
        Wait(duration)
    elseif Config.Progress == "progressBars" then
        exports['progressBars']:startUI(duration, label)
        Wait(duration)
    end
end


function AddCircleZone(name, coords, radius, options, eventOptions)
    if Config.FrameworkTarget == 'qtarget' then
        exports.qtarget:AddCircleZone(name, coords, radius, options, eventOptions)
    elseif Config.FrameworkTarget == 'ox_target' then
        exports.qtarget:AddCircleZone(name, coords, radius, options, eventOptions)
    elseif Config.FrameworkTarget == 'qb-target' then
        exports['qb-target']:AddCircleZone(name, coords, radius, options, eventOptions)
    end
end

function RemoveZone(name)
    if Config.FrameworkTarget == 'qtarget' then
        exports.qtarget:RemoveZone(name)
    elseif Config.FrameworkTarget == 'ox_target' then
        exports.qtarget:RemoveZone(name)
    elseif Config.FrameworkTarget == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    end
end


TextUIShow = function(text)
    if Config.TextUI == "ox_lib" then
        lib.showTextUI(text, {
            position = "top-center",
        })
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:TextUI(text)
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:ShowUI', text)
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO SHOW
    end
end

IsTextUIShowed = function()
    if Config.TextUI == "ox_lib" then
        return lib.isTextUIOpen()
    elseif Config.TextUI == "esx" then
        --exports["esx_textui"]:TextUI(text)
    elseif Config.TextUI == "luke" then
        --TriggerEvent('luke_textui:ShowUI', text)
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO SHOW
    end
end

TextUIHide = function()
    if Config.TextUI == "ox_lib" then
        lib.hideTextUI()
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:HideUI()
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:HideUI')
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO HIDE
    end
end

Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        SetTextFont(Config.FontId)
        SetTextScale(0.33, 0.30)
        SetTextDropshadow(10, 100, 100, 100, 255)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 350
        DrawRect(_x,_y+0.0135, 0.025+ factor, 0.03, 0, 0, 0, 10)
    end
end