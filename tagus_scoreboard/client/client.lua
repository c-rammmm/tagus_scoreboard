local cachedCounts = {}
local cachedTotalPlayers = 0
local cachedMaxPlayers = 64
local cachedJobs = {}
local cachedCitizenId = 'Unknown'
local pendingOpen = false

local function OpenServicesMenu()
    local options = {
        {
            title = 'Players Online',
            description = ('Total: %s/%s'):format(cachedTotalPlayers, cachedMaxPlayers),
            readOnly = true,
            icon = 'user',
            iconColor = 'white',
        },
        {
            title = 'Citizen ID',
            description = cachedCitizenId or 'Unknown',
            readOnly = true,
            icon = 'id-card',
            iconColor = 'white',
        },


    -- replace lines 9-23 if you want this option
        -- If you want the citizen ID in the same line as the Total Players
        --[[    -- local options = {
    {
        title = 'Players Online',
        description = ('Total: %s/%s | Citizen ID: %s'):format(
            cachedTotalPlayers,
            cachedMaxPlayers,
            cachedCitizenId or 'Unknown'
        ),
        readOnly = true,
        icon = 'user',
        iconColor = 'white',
    },
}]]
    }

    for index, data in ipairs(cachedJobs) do
        local count = cachedCounts[index] or 0
        local state = count > 0 and 'Active' or 'Inactive'
        local disabled = count <= 0

        options[#options + 1] = {
            title = data.label,
            description = ('Status: %s | Available: %s'):format(state, count),
            readOnly = true,
            icon = data.icon,
            iconColor = data.iconColor or 'white',
            disabled = disabled,
        }
    end

    lib.registerContext({
        id = 'some_menu',
        title = 'Scoreboard',
        options = options
    })

    lib.showContext('some_menu')
end

RegisterCommand('scoreboards', function()
    pendingOpen = true
    TriggerServerEvent('tagus_services:requestUpdate')
end)

RegisterKeyMapping('scoreboards', 'Show Scoreboard', 'keyboard', 'F1')

RegisterNetEvent('tagus_services:updateNumbers', function(counts, totalPlayers, maxPlayers, jobs, citizenid)
    cachedCounts = counts or {}
    cachedTotalPlayers = totalPlayers or 0
    cachedMaxPlayers = maxPlayers or 64
    cachedJobs = jobs or {}

    if citizenid then
        cachedCitizenId = citizenid
    end

    if pendingOpen then
        pendingOpen = false
        OpenServicesMenu()
    end
end)
