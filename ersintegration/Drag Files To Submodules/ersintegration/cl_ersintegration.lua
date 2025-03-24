--[[
    Sonaran CAD Plugins

    Plugin Name: ersintegration
    Creator: Sonoran Software
    Description: Integrates Knight ERS callouts to SonoranCAD
]]
CreateThread(function() Config.LoadPlugin("ersintegration", function(pluginConfig)
    RegisterNetEvent('night_ers:ERS_GetPedDataFromServer_cb', function(data)
        TriggerServerEvent('SonoranCAD::ErsIntegration::BuildChars', data)
    end)
    RegisterNetEvent('night_ers:receiveVehicleInformation', function(_, data)
        TriggerServerEvent('SonoranCAD::ErsIntegration::BuildVehs', data)
    end)
end) end)