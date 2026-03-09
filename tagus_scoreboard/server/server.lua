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
        sort = 5,
        visibleToJobs = { 'police', 'sheriff' }
    },

    {
        jobs = { 'mechanic', 'bennys', 'tirenutz' },
        label = 'Mechanic',
        icon = 'wrench',
        iconColor = 'ghostwhite',
        sort = 6
    },

    {
        jobs = { 'taxi' },
        label = 'Taxi',
        icon = 'taxi',
        iconColor = 'yellow',
        sort = 7
    },

    {
        jobs = { 'burgershot' },
        label = 'BurgerShot',
        icon = 'burger',
        iconColor = 'darkorange',
        sort = 8
    },
}

table.sort(trackedJobs, function(a, b)
    return (a.sort or 999) < (b.sort or 999)
end)

local function CanPlayerSeeEntry(playerJobName, entry)
    if not entry then
        return false
    end

    if type(entry.visibleToJobs) ~= 'table' then
        return true
    end

    if #entry.visibleToJobs == 0 then
        return true
    end

    for _, allowedJob in ipairs(entry.visibleToJobs) do
        if allowedJob == playerJobName then
            return true
        end
    end

    return false
end

local function GetVisibleTrackedJobs(playerJobName)
    local visibleJobs = {}

    for _, entry in ipairs(trackedJobs) do
        if CanPlayerSeeEntry(playerJobName, entry) then
            visibleJobs[#visibleJobs + 1] = entry
        end
    end

    return visibleJobs
end

local function GetServiceCounts(visibleTrackedJobs)
    local counts = {}
    local jobLookup = {}

    if type(visibleTrackedJobs) ~= 'table' then
        visibleTrackedJobs = {}
    end

    for index, data in ipairs(visibleTrackedJobs) do
        counts[index] = 0

        if type(data.jobs) == 'table' then
            for _, jobName in ipairs(data.jobs) do
                jobLookup[jobName] = index
            end
        end
    end

    local players = QBCore.Functions.GetQBPlayers()

    for _, Player in pairs(players) do
        if Player and Player.PlayerData and Player.PlayerData.job then
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

    return counts, totalPlayers, maxPlayers
end

RegisterNetEvent('tagus_services:requestUpdate', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = 'Unknown'
    local playerJobName = 'unemployed'

    if Player.PlayerData then
        if Player.PlayerData.citizenid then
            citizenid = Player.PlayerData.citizenid
        end

        if Player.PlayerData.job and Player.PlayerData.job.name then
            playerJobName = Player.PlayerData.job.name
        end
    end

    local visibleTrackedJobs = GetVisibleTrackedJobs(playerJobName)
    local counts, totalPlayers, maxPlayers = GetServiceCounts(visibleTrackedJobs)

    TriggerClientEvent('tagus_services:updateNumbers', src, counts, totalPlayers, maxPlayers, visibleTrackedJobs, citizenid)
end)

CreateThread(function()
    while true do
        local players = QBCore.Functions.GetQBPlayers()

        for _, Player in pairs(players) do
            if Player and Player.PlayerData then
                local src = Player.PlayerData.source
                local playerJobName = 'unemployed'

                if Player.PlayerData.job and Player.PlayerData.job.name then
                    playerJobName = Player.PlayerData.job.name
                end

                local visibleTrackedJobs = GetVisibleTrackedJobs(playerJobName)
                local counts, totalPlayers, maxPlayers = GetServiceCounts(visibleTrackedJobs)

                TriggerClientEvent('tagus_services:updateNumbers', src, counts, totalPlayers, maxPlayers, visibleTrackedJobs)
            end
        end

        Wait(3000)
    end
end)
