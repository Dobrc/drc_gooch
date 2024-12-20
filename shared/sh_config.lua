 
--[[
##     ##    ###    #### ##    ##     ######   #######  ##    ## ######## ####  ######   
###   ###   ## ##    ##  ###   ##    ##    ## ##     ## ###   ## ##        ##  ##    ##  
#### ####  ##   ##   ##  ####  ##    ##       ##     ## ####  ## ##        ##  ##        
## ### ## ##     ##  ##  ## ## ##    ##       ##     ## ## ## ## ######    ##  ##   #### 
##     ## #########  ##  ##  ####    ##       ##     ## ##  #### ##        ##  ##    ##  
##     ## ##     ##  ##  ##   ###    ##    ## ##     ## ##   ### ##        ##  ##    ##  
##     ## ##     ## #### ##    ##     ######   #######  ##    ## ##       ####  ######   
--]]


Config = {}
Config.Debug = false
Config.Framework = 'esx'--  'qbcore' or 'esx' /  auto-detect
Config.NewESX = true
Config.InteractionType = "target" -- target or textui or 3dtext | which type of interaction you want
Config.FrameworkTarget = 'auto-detect' --qtarget or qb-target or ox_target / auto-detect
Config.NotificationType = 'ox_lib'
Config.Progress = 'ox_lib' -- qbcore / ox_lib /
Config.TextUI = "ox_lib" -- TextUIs | types: esx, ox_lib, luke

Config.GoochSpawn = 15 -- EVERY 15 MINUTES IT WILL CHOOSE PLAYER AND SPAWN GOOCH

Config.TakeMoney = {
    Min = 100,
    Max = 300
}

Config.AddRewards = {
    {
        Money = {
            Min = 500,
            Max = 3000
        },
        Items = {
            { name = "water", count = 1 },
            { name = "bread", count = 2 }
        }
    },
    {
        Money = {
            Min = 500,
            Max = 1000
        },
        Items = {
            { name = "ammo_pistol", count = 10 },
            { name = "medikit", count = 1 }
        }
    }
}

Config.Locales = {
    OpenGift = "Open Gift",
    GoochStoleMoney = "Gooch stole your money! Kill him to get it back!",
    NiceGiftFromGooch = "You got a nice gift from Gooch"
}
