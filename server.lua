
local QBCore = exports['qb-core']:GetCoreObject()
local PERM_TIMESTAMP = 10413791999   

QBCore.Commands.Add('ban', 'Ban a player with optional duration (leave empty for permanent ban)', {
    { name = "Id",     help = "Player Id"         },
    { name = "Reason", help = "Ban reason"        },
    { name = "Hours",  help = "Hours (optional)"  },
    { name = "Days",   help = "Days (optional)"   },
    { name = "Months", help = "Months (optional)" },
}, false, function(source, args)
    if not IsPlayerAceAllowed(source, 'command.ban') then
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1Error", "You do not have permission to use this command." }
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1Error", "Invalid player ID" }
        })
        return
    end

    local reason  = args[2] or "Non specified"
    local hours   = tonumber(args[3]) or 0
    local days    = tonumber(args[4]) or 0
    local months  = tonumber(args[5]) or 0

    local permBan = (hours == 0 and days == 0 and months == 0)
    local banDuration = hours * 3600 + days * 86400 + months * 2629743
    local expiresAt = permBan and PERM_TIMESTAMP or (os.time() + banDuration)

    local playerName    = GetPlayerName(targetId) or "Unknown"
    local playerLicense = GetPlayerIdentifierByType(targetId, 'license') or "Unknown"
    local playerDiscord = GetPlayerIdentifierByType(targetId, 'discord') or "Unknown"
    local playerIP      = GetPlayerIdentifierByType(targetId, 'ip') or "Unknown"
    local bannedBy      = GetPlayerName(source) or "Console"

    exports.oxmysql:insert(
        'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            playerName,
            playerLicense,
            playerDiscord,
            playerIP,
            reason,
            expiresAt,
            bannedBy
        }
    )

    TriggerClientEvent("kick:ilv-scripts:KickKidnapScene", targetId)

    SetTimeout(13000, function()
        local displayExpiry = expiresAt > 10400000000 and "Permanent" or os.date('%c', expiresAt)
        DropPlayer(targetId, ("Banned for: %s\nExpires: %s"):format(reason, displayExpiry))
    end)
end, 'admin')
