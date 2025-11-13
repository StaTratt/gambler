addon.name = 'gambler'
addon.version = '1.0'
addon.author = 'StaTratt, partially based on rollTracker'
addon.desc = 'auto-roll corsair rolls based on config parameters'
addon.link = 'https://github.com/StaTratt/gambler'

require 'common'
local settings = require('settings')
local chat = require('chat')
local imgui = require('imgui')

local config = require('data/config')
local rolls = require('data/rolls')
local utils = require('src/utils')
local commands = require('src/commands')
local ui = require('src/ui')

gambler = {
    visible = { false },
    config = config.load(),
    monitor = {
        [1] = nil,  -- Roll ID
        [2] = nil,  -- Roll number
        [3] = false -- Crooked Cards flag (defaults to false, not nil)
    },
    snakeEyeMeritsReceived = false,
    shouldCheckMerits = false, -- Flag to control when merit packets should be processed
    pendingSnakeEyeDoubleUp = false,
    pendingDoubleUp = false, -- Flag to prevent spamming Double-Up
    initialRollGear = {},
    lastMessage = nil, -- Store last printed message to prevent duplicates
    snakeEyeAvailableThisRoll = false -- Checked once at start of roll, used throughout
}

-- Load event to ensure settings are loaded
ashita.events.register('load', 'load_cb', function()
    gambler.config = config.load()
    print(chat.header(addon.name):append(chat.message('Configuration loaded.')))
end)

-- Snake Eye merits are automatically detected from packet 0x8C in utils.lua

ashita.events.register('command', 'command_cb', function (cmd, nType)
    local args = cmd.command:args()
    if #args ~= 0 then
        commands.handleCommand(args)
    end
end)

ashita.events.register('d3d_present', 'd3d_present_cb', function ()
    if gambler.monitor[1] ~= nil then
        utils.useDoubleUp(gambler.monitor[1], gambler.monitor[2])
    end
    ui.update()
end)