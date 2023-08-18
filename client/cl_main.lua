local Config = require 'config'
local count = 1
local inSpot = 0
local usingDetector = false
local treasureFound = 0
local heatC = 0
local metalScanner = 0
local treasures = {}
local polys = {}

local audioName = 'IDLE_BEEP'
local audioRef = 'EPSILONISM_04_SOUNDSET'

if not lib then return end

local getGroundZ = GetGroundZFor_3dCoord
local treasure = lib.points
local coords = {}
local soundID = GetSoundId()

local function removeTool()
    usingDetector = false
    TriggerEvent('AnimSet:default')
    DetachEntity(metalScanner, 0, 0)
    DeleteEntity(metalScanner)
end

local function GetCoordZ(x, y)
    for i = 6, -3, -1 do
        local z = i + 0.0
        local foundGround, coordZ = getGroundZ(x, y, z, true)
        if foundGround then
			return coordZ
		end
    end
    return 0
end

local function GenerateRandomCoords(data)
    local minX = data.x.min
    local minY = data.y.min
    local maxX = data.x.max
    local maxY = data.y.max
    local randomX = math.random() * (maxX - minX) + minX
    local randomY = math.random() * (maxY - minY) + minY
    local randomZ = GetCoordZ(randomX, randomY)
    local generatedCoords = vector3(randomX, randomY, randomZ)
    if not polys[inSpot]:contains(generatedCoords) then return end
    return generatedCoords
end

local function nearbyPoint(data)
    Wait(1000)
    local currentDist = data.currentDistance
    if not currentDist then return end
    PlaySoundFromCoord(soundID, audioName, data.coords.x, data.coords.y, data.coords.z, audioRef, false, currentDist, false)
    treasureFound = currentDist < 2 and data.id or 0
end

local function startDetecting()
    CreateThread(function()
        while usingDetector do 
            Wait(100)
            if inSpot ~= 0 and heatC < 80 and count < Config.treasures.count then
                local randomCoords = GenerateRandomCoords(coords[inSpot])
                if randomCoords then
                    treasures[count] = treasure.new({
                        coords = randomCoords,
                        distance = 6,
                        id = count,
                        nearby = nearbyPoint
                    })
                    if Config.debug.treasures then
                        CreateThread(function()
                            while usingDetector do
                                Wait(0)
                                DrawMarker(2, randomCoords.x, randomCoords.y, randomCoords.z + 3.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 200, 20, 20, 50, false, true, 2, false, nil, nil, false)
                            end
                        end)
                    end
                    count+=1
                end
            end
        end
    end)
end

local function AttachEntity()
    local model = `w_am_digiscanner`
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    lib.requestModel(model)
    metalScanner = CreateObjectNoOffset(model, pos, 1, 1, 0)
    AttachEntityToEntity(metalScanner, ped, GetPedBoneIndex(ped, 18905), 0.15, 0.1, 0.0, 270.0, 90.0, 80.0, true, true, false, false, 2, true)
end

local function removePoints()
    local table_remove = table.remove
    for k,v in ipairs(treasures) do
        v:remove()
        table_remove(treasures, k)
    end
end

RegisterNetEvent('frmz-metaldetecting:startdetect', function()
    if heatC >= 80 then TriggerEvent("DoLongHudText", "Metal detecting is overheat, wait till it cooldown",1) return end
    usingDetector = not usingDetector
    if usingDetector then
        startDetecting()
        AttachEntity()
    else
        removeTool()
        removePoints()
    end
end)

CreateThread(function() 
    local math_huge = math.huge
    for _, v in pairs(Config.detectZones) do
        local zone = {
            x = {min = math_huge, max = -math_huge},
            y = {min = math_huge, max = -math_huge}
        }
        for _, zones in ipairs(v) do
            local x = zone.x
            local y = zone.y
            if x.min > zones.x then
                x.min = zones.x
            end
            if y.min > zones.y then
                y.min = zones.y
            end
            if x.max < zones.x then
                x.max = zones.x
            end
            if y.max < zones.y then
                y.max = zones.y
            end
        end
        coords[_] = zone
        polys[_] = lib.zones.poly({
            points = v,
            debug = Config.debug.poly,
            zone = _,
            thickness = 30,
            onEnter = function()
                inSpot = _
            end,
            onExit = function()
                inSpot = 0
            end,
        })
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        if heatC >= 0 then
            Wait(8000)
            if usingDetector then
                heatC += 1
            else
                Wait(3000)
                heatC = heatC < 0 and 0 or heatC-1
            end
            if usingDetector and heatC >= 86 then
                usingDetector = false
                heatC = 0
                removeTool()
                TriggerServerEvent("frmz-inventory:server:removeItem",'metaldetector', 1)
                TriggerEvent("DoLongHudText", "Metal detecting is damaged",1)
            elseif usingDetector and heatC >= 80 then
                TriggerEvent("DoLongHudText", "Metal detecting is overheating",1)
                Wait(5000)
            end
        end
    end
end)


--------------- DIGGING

local function startDig()
    if treasureFound == 0 then return end
    local ped = cache.ped
    removeTool()
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    treasures[treasureFound]:remove()
    treasureFound = 0
    Wait(4000)
    TriggerEvent('frmz-metaldetecting:treasureFound')
    ClearPedTasks(ped)
end

RegisterNetEvent('frmz-metaldetecting:startDig', startDig)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DetachEntity(metalScanner)
        DeleteEntity(metalScanner)
    end
end)