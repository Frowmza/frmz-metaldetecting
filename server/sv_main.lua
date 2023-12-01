local coreModule = Framework.core

coreModule.RegisterUsableItem('digtool', function(source)
    TriggerClientEvent("frmz-metaldetecting:startDig", source)
end)

coreModule.RegisterUsableItem('metaldetector', function(source)
    TriggerClientEvent("frmz-metaldetecting:startdetect", source)
end)