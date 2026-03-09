local QBCore = exports['qb-core']:GetCoreObject()

local trackedJobs = {
    {
        jobs = { 'police' },
        label = 'Police',
        icon = 'shield-halved',
        iconColor = 'darkblue',
        sort = 1
    },

    {
        jobs = { 'ambulance' },
        label = 'Ambulance',
        icon = 'truck-medical',
        iconColor = 'snow',
        sort = 2
    },

    {
        jobs = { 'fire' },
        label = 'Fire Department',
        icon = 'fire',
        iconColor = 'red',
        sort = 3
    },

    {
        jobs = { 'sheriff' },
        label = 'Blaine County Sheriff',
        icon = 'hat-cowboy',
        iconColor = 'white',
        sort = 4
    },

	{
        jobs = { 'fib' },
        label = 'FIB',
        icon = 'user-secret',
        iconColor = 'black',
        sort = 4
    },

    {
        jobs = { 'mechanic', 'bennys', 'tirenutz' },
        label = 'Mechanic',
        icon = 'wrench',
        iconColor = 'ghostwhite',
        sort = 5
    },

    {
        jobs = { 'taxi' },
        label = 'Taxi',
        icon = 'taxi',
        iconColor = 'yellow',
        sort = 6
    },

    {
        jobs = { 'burgershot' },
        label = 'BurgerShot',
        icon = 'burger',
        iconColor = 'darkorange',
        sort = 7
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
    local Player = QBCore.Functions.GetPlayer(src)

    local citizenid = "Unknown"
    if Player and Player.PlayerData and Player.PlayerData.citizenid then
        citizenid = Player.PlayerData.citizenid
    end

    local counts, totalPlayers, maxPlayers, jobs = GetServiceCounts()
    TriggerClientEvent('tagus_services:updateNumbers', src, counts, totalPlayers, maxPlayers, jobs, citizenid)
end)

CreateThread(function()
    while true do
        local counts, totalPlayers, maxPlayers, jobs = GetServiceCounts()
        TriggerClientEvent('tagus_services:updateNumbers', -1, counts, totalPlayers, maxPlayers, jobs)
        Wait(3000)
    end
end)
