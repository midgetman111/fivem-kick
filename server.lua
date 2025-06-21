local QBCore = exports['qb-core']:GetCoreObject()


QBCore.Commands.Add('kicknew', 'kick', {
    {name = "Id", help = "Player Id"}
}, false, function(source, args)
    local targetId = tonumber(args[1])
    if not targetId or GetPlayerName(targetId) == nil then
        TriggerClientEvent("chat:addMessage", source, {
            args = {"^1Error", "Invalid player ID"}
        })
        return
    end

    TriggerClientEvent("kick:ilv-scripts:KickKidnapScene", targetId)

    SetTimeout(10000, function()
        DropPlayer(targetId, "You have been kidnapped and kicked from the server.")
    end)
end, 'god')
