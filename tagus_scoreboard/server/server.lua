local QBCore = exports['qb-core']:GetCoreObject()

local trackedJobs = {
    {
        job = 'police', -- job name
        label = 'Police', -- description
        icon = 'shield-halved', -- icons from https://fontawesome.com/
        iconColor = 'darkblue', -- css color
        sort = 1 -- change this to the order number you want (Ex. 3 = 3rd on the menu)
    },

    {
        job = 'ambulance',
        label = 'Ambulance',
        icon = 'truck-medical',
        iconColor = 'snow',
        sort = 2
    },

    {
        job = 'fire',
        label = 'Fire Department',
        icon = 'fire',
        iconColor = 'red',
        sort = 3
    },

    {
        job = 'mechanic',
        label = 'Mechanic',
        icon = 'wrench',
        iconColor = 'ghostwhite',
        sort = 10
    },

    {
        job = 'burgershot',
        label = 'BurgerShot',
        icon = 'burger',
        iconColor = 'darkorange',
        sort = 20
    },

    {
        job = 'taxi',
        label = 'Taxi',
        icon = 'taxi',
        iconColor = 'yellow',
        sort = 25
    },
}

table.sort(trackedJobs, function(a, b)
    return (a.sort or 999) < (b.sort or 999)
end)

local function GetServiceCounts()
    local counts = {}

    for _, data in ipairs(trackedJobs) do
        counts[data.job] = 0
    end

    local players = QBCore.Functions.GetQBPlayers()

    for _, Player in pairs(players) do
        if Player.PlayerData and Player.PlayerData.job then
            local job = Player.PlayerData.job

            if job.onduty and counts[job.name] ~= nil then
                counts[job.name] = counts[job.name] + 1
            end
        end
    end

    local totalPlayers = #GetPlayers()
    local maxPlayers = GetConvarInt('sv_maxclients', 64)

    return counts, totalPlayers, maxPlayers, trackedJobs
end

RegisterNetEvent('tagus_services:requestUpdate', function()
    local src = source
    local counts, totalPlayers, maxPlayers, jobs = GetServiceCounts()
    TriggerClientEvent('tagus_services:updateNumbers', src, counts, totalPlayers, maxPlayers, jobs)
end)

CreateThread(function()
    while true do
        local counts, totalPlayers, maxPlayers, jobs = GetServiceCounts()
        TriggerClientEvent('tagus_services:updateNumbers', -1, counts, totalPlayers, maxPlayers, jobs)
        Wait(1000)
    end
end)
