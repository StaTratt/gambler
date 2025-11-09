local rolls = require('data/rolls')
local utils = require('src/utils')
local settings = require('settings')

commands = {}

function commands.handleCommand(args)
    local command = string.lower(args[1])
    local arg = #args > 1 and string.lower(args[2]) or ''
    local arg2 = #args > 2 and rolls.IDs[args[3]] or nil

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
        print('\x1F\xCF==================================================')
    elseif arg == 'roll' then
        local rollIndex
        for i, v in pairs(rolls.IDs) do
            if string.find(string.lower(v), string.lower(args[3])) then
                rollIndex = i
            end
        end
        if rollIndex then
            if gambler.config.chatPresence[1] then
                utils.chatPrint(string.format("Rolling %s...", rolls.IDs[rollIndex]), 'info')
            end
            utils.useRoll(rollIndex)
        else
            utils.chatPrint("Usage: /gambler roll <roll name>", 'warning')
            return
        end
    elseif arg then
        utils.chatPrint(string.format("Unknown command: %s", arg), 'error')
    end
end

return commands