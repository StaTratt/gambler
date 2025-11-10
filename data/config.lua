local settings = require('settings')

local config = {}

local default = T {
    chatPresence = { false },
    autoRoll = { false },
    maxReRoll = { 5 },
    snakeEyeMerits = { 0 },
    maxBustRisk = { 50 },
    autoCheckMerits = { true },
    stopOnLucky = { false },
    doubleUpOnUnlucky = { false },
    doubleUpBeforeLucky = { false },
    doubleUpOn11 = { false },
    useCrookedCardsBustRisk = { false },
    crookedCardsBustRisk = { 75 },
    debugMode = { false },
    debugStopOnSnakeEye = { false },
    autoRollExceptions = {} -- List of roll IDs to exclude from auto-rolling
}

config.load = function ()
    return settings.load(default)
end

return config