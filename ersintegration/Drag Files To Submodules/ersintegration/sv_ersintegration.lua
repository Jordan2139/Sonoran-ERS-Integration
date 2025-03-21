--[[
    Sonaran CAD Plugins

    Plugin Name: ersintegration
    Creator: Sonoran Software
    Description: Integrates Knight ERS callouts to SonoranCAD
]]
local pluginConfig = Config.GetPluginConfig("ersintegration")

if pluginConfig.enabled then
    RegisterNetEvent('SonoranCAD::ErsIntegration::CalloutOffered')
    RegisterNetEvent('SonoranCAD::ErsIntegration::CalloutAccepted')
    RegisterNetEvent('SonoranCAD::ErsIntegration::BuildChars')
    local processedCalloutOffered = {}
    local processedCalloutAccepted = {}
    local processedPedData = {}
    local ersCallouts = {}
    local function generateUniqueCalloutKey(callout)
        return string.format(
            "%s_%s_%s_%s_%.2f_%.2f_%.2f",
            callout.calloutId,
            callout.FirstName,
            callout.LastName,
            callout.StreetName,
            callout.Coordinates.x,
            callout.Coordinates.y,
            callout.Coordinates.z
        )
    end
    local function generateUniquePedDataKey(pedData)
        return string.format(
            "%s_%s_%s_%s",
            pedData.uniqueId,
            pedData.FirstName,
            pedData.LastName,
            pedData.Address
        )
    end
    function generateCallNote(callout)
        -- Start with basic callout information
        local note = ''

        -- Append potential weapons information
        if callout.PedWeaponData and #callout.PedWeaponData > 0 then
            note = note .. "Potential weapons: " .. table.concat(callout.PedWeaponData, ", ") .. ". "
        else
            note = note .. "No weapons reported. "
        end

        -- Determine the required units from the callout
        local requiredUnits = {}
        local units = callout.CalloutUnitsRequired or {}
        if units.policeRequired then table.insert(requiredUnits, "Police") end
        if units.ambulanceRequired then table.insert(requiredUnits, "Ambulance") end
        if units.fireRequired then table.insert(requiredUnits, "Fire") end
        if units.towRequired then table.insert(requiredUnits, "Tow") end

        if #requiredUnits > 0 then
            note = note .. "Required units: " .. table.concat(requiredUnits, ", ") .. "."
        else
            note = note .. "No additional units required."
        end

        return note
    end

    function generateReplaceValues(pedData, config)
        local replaceValues = {}
        for cadKey, source in pairs(config) do
            if type(source) == "function" then
                replaceValues[cadKey] = source(pedData)
            elseif type(source) == "string" then
                replaceValues[cadKey] = pedData[source]
            else
                error("Invalid mapping configuration for key: " .. tostring(cadKey))
            end
        end
        return replaceValues
    end

    if pluginConfig.create911Call then
        AddEventHandler('SonoranCAD::ErsIntegration::CalloutOffered', function(calloutData)
            local uniqueKey = generateUniqueCalloutKey(calloutData)
            if processedCalloutOffered[uniqueKey] then
                debugPrint("Callout " .. calloutData.calloutId .. " already processed. Skipping 911 call.")
                return
            end
            local caller = calloutData.FirstName .. " " .. calloutData.LastName
            local location = calloutData.StreetName
            local description = calloutData.Description
            local postal = calloutData.Postal
            local plate = ""
            if calloutData.VehiclePlate ~= nil then
                plate = calloutData.VehiclePlate
            end
            local data = {
                ['serverId'] = Config.serverId,
                ['isEmergency'] = true,
                ['caller'] = caller,
                ['location'] = location,
                ['description'] = description,
                ['metaData'] = {
                    ['x'] = calloutData.Coordinates.x,
                    ['y'] = calloutData.Coordinates.y,
                    ['plate'] = plate,
                    ['postal'] = postal
                }
            }
            performApiRequest({data}, 'CALL_911', function(response)
            end)
            processedCalloutOffered[uniqueKey] = true
        end)
    end
    if pluginConfig.createEmergencyCall then
        AddEventHandler('SonoranCAD::ErsIntegration::CalloutAccepted', function(calloutData)
            local uniqueKey = generateUniqueCalloutKey(calloutData)
            if processedCalloutAccepted[uniqueKey] then
                debugPrint("Callout " .. calloutData.calloutId .. " already processed. Skipping emergency call... adding new units")
                if pluginConfig.autoAddCall then
                    local callId = processedCalloutAccepted[uniqueKey]
                    local unit = exports['sonorancad']:GetUnitByPlayerId(source)
                    local unitId = unit.data.apiIds[0]
                    local data = {
                        ['serverId'] = Config.serverId,
                        ['callId'] = callId,
                        ['units'] = {unitId}
                    }
                    performApiRequest({data}, 'ATTACH_UNIT', function(response)
                        debugPrint("Added unit to call: " .. response)
                    end)
                end
            else
                debugPrint("Processing callout " .. calloutData.calloutId .. " for emergency call.")
                local callCode = pluginConfig.callCodes[calloutData.CalloutName] or ""
                local unit = exports['sonorancad']:GetUnitByPlayerId(source)
                local unitId = unit.data.apiIds[0]
                local data = {
                    ['serverId'] = Config.serverId,
                    ['origin'] = 0,
                    ['status'] = 1,
                    ['priority'] = pluginConfig.callPriority,
                    ['block'] = calloutData.Postal,
                    ['postal'] = calloutData.Postal,
                    ['address'] = calloutData.StreetName,
                    ['title'] = calloutData.CalloutName,
                    ['code'] = callCode,
                    ['description'] = calloutData.Description,
                    ['units'] = {unitId},
                    ['notes'] = generateCallNote(calloutData), -- required
                    ['metaData'] = {
                        ['x'] = calloutData.Coordinates.x,
                        ['y'] = calloutData.Coordinates.y
                    }
                }
                performApiRequest({data}, 'NEW_DISPATCH', function(response)
                    local callId = response:match("ID: {?(%w+)}?")
                    if callId then
                        -- Save the callId in the processedCalloutOffered table using the unique key
                        processedCalloutOffered[uniqueKey] = callId
                        debugPrint("Call ID " .. callId .. " saved for unique key: " .. uniqueKey)
                    else
                        debugPrint("Failed to extract callId from response: " .. response)
                    end
                end)
            end
        end)
        AddEventHandler('SonoranCAD::ErsIntegration::BuildChars', function(pedData)
            local uniqueKey = generateUniquePedDataKey(pedData)
            if processedPedData[uniqueKey] then
                debugPrint("Ped " .. pedData.FirstName .. " " .. pedData.LastName .. " already processed. Skipping 911 call.")
                return
            end
            local data = {
                ['user'] = '000-000-0000',
                ['useDictionary'] = true,
                ['recordTypeId'] = pluginConfig.customRecords.civilianRecordID,
            }
            data.replaceValues = generateReplaceValues(pedData, pluginConfig.customRecords.civilianValues)
            performApiRequest({data}, 'NEW_RECORD', function(response)
                local recordId = response:match("ID: {?(%w+)}?")
                if recordId then
                    -- Save the recordId in the processedPedData table using the unique key
                    processedPedData[uniqueKey] = recordId
                    debugPrint("Record ID " .. recordId .. " saved for unique key: " .. uniqueKey)
                else
                    debugPrint("Failed to extract recordId from response: " .. response)
                end
            end)
        end)
        CreateThread(function()
            Wait(5000)
            debugPrint('Loading ERS Callouts...')
            local calloutData = exports.night_ers.getCallouts()
            for uid, callout in pairs(calloutData) do
                ersCallouts[uid] = callout
            end
            local data = {
                ['serverId'] = Config.serverId,
                ['callouts'] = {ersCallouts}
            }
            debugPrint('Loaded ' .. #ersCallouts .. ' ERS callouts.')
            performApiRequest(data, 'ERS_CALLS', function(response)
                debugPrint('ERS callouts sent to CAD.')
            end)
        end)
    end
end