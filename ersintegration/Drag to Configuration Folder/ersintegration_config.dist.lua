--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = true,
    pluginName = "ersintegration", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    configVersion = "1.0",
    -- put your configuration options below
    create911Call = true, -- Create a 911 call when an ERS callout is created
    createEmergencyCall = true, -- Create an emergency call when an ERS callout is accepted
    callPriority = 2, -- Priority of the call created in CAD (1-3) | Only used if createEmergencyCall is true
    callCodes = {
        ['Stolen_motorbike'] = '10-22'
    }, -- Call codes for each ERS callout type | Only used if createEmergencyCall is true
    autoAddCall = true, -- Automatically add members to the call when an ERS callout is accepted
    customRecords = {
        civilianRecordID = 7, -- Record ID for civilian records
        civilianValues = {
            -- Configurable mapping for SonoranCAD replaceValues.
            -- The key is what SonoranCAD expects and the value is either:
            --    • A string that matches a key in pedData, or
            --    • A function that returns a value based on pedData.
            --    • Left side of mapping is the SonoranCAD field mapping ID from Custom Records, right side is the ERS field.
            first = "FirstName",
            last = "LastName",
            dob = "DOB",
            sex = "Gender",
            residence = function(pedData)
                return pedData.Address .. " " .. pedData.City .. ", " .. pedData.State
            end,
            zip = "Zip",
            phone = "Phone",
            skin = "Nationality",
            -- Add more keys as needed:
            -- email = "Email"  -- Example: if pedData.Email exists.
        },
    }

}

if config.enabled then Config.RegisterPluginConfig(config.pluginName, config) end
