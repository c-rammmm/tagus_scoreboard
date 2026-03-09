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
    local jobLookup = {}

    for index, data in ipairs(trackedJobs) do
        counts[index] = 0

        for _, jobName in ipairs(data.jobs) do
            jobLookup[jobName] = index
        end
    end

    local players = QBCore.Functions.GetQBPlayers()

    for _, Player in pairs(players) do
        if Player.PlayerData and Player.PlayerData.job then
            local job = Player.PlayerData.job

            if job.onduty then
                local groupIndex = jobLookup[job.name]
                if groupIndex then
                    counts[groupIndex] = counts[groupIndex] + 1
                end
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
        Wait(3000)
    end
end)
