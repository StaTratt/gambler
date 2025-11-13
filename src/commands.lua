local rolls = require('data/rolls')
local utils = require('src/utils')
local settings = require('settings')

commands = {}

function commands.handleCommand(args)
    local command = string.lower(args[1])
    local arg = #args > 1 and string.lower(args[2]) or ''

    if command ~= '/gambler' then
        return false
    end

    if arg == '' or arg == 'config' then
        gambler.visible[1] = not gambler.visible[1]
    elseif arg == 'help' then
        print('\x1F\xCF====================[Gambler]=====================')
        print(string.format('\x1F\x7FVersion: \x1F\x01%s', addon.version))
        print(string.format('\x1F\x7FAuthor: \x1F\x01%s', addon.author))
        print(string.format('\x1F\x7FDescription: \x1F\x01%s', addon.desc))
        print('\x1F\xCF--------------------------------------------------')
        print('\x1F\x9EAvailable Commands:')
        print('\x1F\x7F  /gambler \x1F\x01- Toggle configuration window')
        print('\x1F\x7F  /gambler config \x1F\x01- Toggle configuration window')
        print('\x1F\x7F  /gambler help \x1F\x01- Display this help message')
        print('\x1F\x7F  /gambler roll <name> \x1F\x01- Manually cast a roll')
        print('\x1F\x7F  /gambler lookup <text> \x1F\x01- Search for roll by name or effect')
        print('\x1F\xCF==================================================')
    elseif arg == 'roll' then
        -- Concatenate all args from index 3 onwards for the roll name
        local rollName = ''
        for i = 3, #args do
            rollName = rollName .. args[i]
            if i < #args then
                rollName = rollName .. ' '
            end
        end
        
        if rollName ~= '' then
            local rollIndex
            for i, v in pairs(rolls.IDs) do
                if string.find(string.lower(v), string.lower(rollName)) then
                    rollIndex = i
                    break
                end
            end
            if rollIndex then
                if gambler.config.chatPresence[1] then
                    utils.chatPrint(string.format("Rolling %s...", rolls.IDs[rollIndex]), 'info')
                end
                utils.useRoll(rollIndex)
            else
                utils.chatPrint(string.format("Roll not found: %s", rollName), 'error')
            end
        else
            utils.chatPrint("Usage: /gambler roll <roll name>", 'warning')
        end
    elseif arg == 'lookup' then
        -- Concatenate all args from index 3 onwards for the lookup search
        local searchTerm = ''
        for i = 3, #args do
            searchTerm = searchTerm .. args[i]
            if i < #args then
                searchTerm = searchTerm .. ' '
            end
        end
        
        if searchTerm ~= '' then
            utils.lookupRoll(searchTerm)
        else
            utils.chatPrint("Usage: /gambler lookup <roll name or effect>", 'warning')
        end
    elseif arg ~= '' then
        utils.chatPrint(string.format("Unknown command: %s", arg), 'error')
    end
end

return commands