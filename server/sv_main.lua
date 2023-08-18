local Config = require 'config'

if Config.framework == 'qbcore' then
    local QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateUseableItem("metaldetector", function(source)
        TriggerClientEvent("frmz-metaldetecting:startdetect", source)
    end)

    QBCore.Functions.CreateUseableItem("digtool", function(source)
        TriggerClientEvent("frmz-metaldetecting:startDig", source)
    end)
elseif Config.framework == 'esx' then
    local esx = exports["es_extended"]:getSharedObject()
    
    esx.RegisterUsableItem('metaldetector', function(source)
        TriggerClientEvent("frmz-metaldetecting:startdetect", source)
    end)

    esx.RegisterUsableItem('digtool', function(source)
        TriggerClientEvent("frmz-metaldetecting:startDig", source)
    end)
end
