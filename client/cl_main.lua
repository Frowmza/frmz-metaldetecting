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

lib.disableControls:Add(0,21)
lib.disableControls:Add(0,22)

local getGroundZ = GetGroundZFor_3dCoord
local treasure = lib.points
local coords = {}
local soundID = GetSoundId()

local function notification(string)
    local QBCore = exports['qb-core']:GetCoreObject()
    if not QBCore then return end
    QBCore.Functions.Notify(string, "success")
end

local function removeDetector()
    usingDetector = false
    DetachEntity(metalScanner)
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
    local minX, minY, maxX, maxY = data.x.min, data.y.min, data.x.max, data.y.max
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
    treasureFound = currentDist < Config.treasures.close and data.id or 0
end

local function startDetecting()
    CreateThread(function()
        while usingDetector do
            Wait(0)
            lib.disableControls()
        end
    end)
    CreateThread(function()
        while usingDetector and inSpot ~= 0 and heatC < Config.detector.heat and count < Config.treasures.count do 
            Wait(100)
            local randomCoords = GenerateRandomCoords(coords[inSpot])
            if randomCoords then
                treasures[count] = treasure.new({
                    coords = randomCoords,
                    distance = Config.treasures.distance,
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
    if heatC >= Config.detector.heat then notification("Metal detecting is overheat, wait till it cooldown") return end
    usingDetector = not usingDetector
    if usingDetector then
        startDetecting()
        AttachEntity()
    else
        removeDetector()
        removePoints()
    end
end)

CreateThread(function() 
    local math_huge = math.huge
    local lib_zones = lib.zones
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
        polys[_] = lib_zones.poly({
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
                if heatC ~= 0 then
                   Wait(3000)
                   heatC = heatC < 0 and 0 or heatC-1
                end
            end
            
            if usingDetector and heatC >= Config.detector.overheat then
                usingDetector = false
                heatC = 0
                removeDetector()
                TriggerEvent('frmz-metaldetecting:detectorOverheated')
                notification("Metal detecting is damaged")
            elseif usingDetector and heatC >= Config.detector.heat then
                notification("Metal detecting is overheating")
                Wait(5000)
            end
        end
    end
end)


--------------- DIGGING

local function startDig()
    if treasureFound == 0 then return end
    local ped = cache.ped
    removeDetector()
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
        removeDetector()
    end
end)