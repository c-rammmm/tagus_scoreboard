local QBCore = exports['qb-core']:GetCoreObject()

local trackedJobs = {
    {
        jobs = { 'police' }, -- job name
        label = 'Police', -- description
        icon = 'shield-halved', -- icons from https://fontawesome.com
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
        visibleToJobs = { 'police', 'sheriff', 'fib' },
        requireViewerOnDuty = true
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

local function CanPlayerSeeEntry(playerJobName, playerOnDuty, entry)
    if not entry then
        return false
    end

    if entry.requireViewerOnDuty and not playerOnDuty then
        return false
    end

    if type(entry.visibleToJobs) == 'table' and #entry.visibleToJobs > 0 then
        for _, allowedJob in ipairs(entry.visibleToJobs) do
            if allowedJob == playerJobName then
                return true
            end
        end

        return false
    end

    return true
end

local function GetVisibleTrackedJobs(playerJobName, playerOnDuty)
    local visibleJobs = {}

    for _, entry in ipairs(trackedJobs) do
        if CanPlayerSeeEntry(playerJobName, playerOnDuty, entry) then
            visibleJobs[#visibleJobs + 1] = entry
        end
    end

    return visibleJobs
end

local function GetServiceCounts(visibleTrackedJobs)
    local counts = {}
    local jobLookup = {}

    for index, data in ipairs(visibleTrackedJobs) do
        counts[index] = 0

        for _, jobName in ipairs(data.jobs) do
            jobLookup[jobName] = index
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
    local playerOnDuty = false

    if Player.PlayerData then
        if Player.PlayerData.citizenid then
            citizenid = Player.PlayerData.citizenid
        end

        if Player.PlayerData.job then
            playerJobName = Player.PlayerData.job.name or 'unemployed'
            playerOnDuty = Player.PlayerData.job.onduty == true
        end
    end

    local visibleTrackedJobs = GetVisibleTrackedJobs(playerJobName, playerOnDuty)
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
                local playerOnDuty = false

                if Player.PlayerData.job then
                    playerJobName = Player.PlayerData.job.name or 'unemployed'
                    playerOnDuty = Player.PlayerData.job.onduty == true
                end

                local visibleTrackedJobs = GetVisibleTrackedJobs(playerJobName, playerOnDuty)
                local counts, totalPlayers, maxPlayers = GetServiceCounts(visibleTrackedJobs)

                TriggerClientEvent('tagus_services:updateNumbers', src, counts, totalPlayers, maxPlayers, visibleTrackedJobs)
            end
        end

        Wait(3000)
    end
end)
