local settings = require('settings')

local config = {}

local default = T {
    chatPresence = { false },
    autoRoll = { false },
    maxReRoll = { 5 },
    snakeEyeMerits = { 0 },
    maxBustRisk = { 25 },
    autoCheckMerits = { true },
    stopOnLucky = { true },
    doubleUpOnUnlucky = { true },
    doubleUpBeforeLucky = { true },
    doubleUpOn11 = { false },
    useCrookedCardsBustRisk = { false },
    crookedCardsBustRisk = { 10 },
    debugMode = { false },
    debugStopOnSnakeEye = { false },
    autoRollExceptions = {} -- List of roll IDs to exclude from auto-rolling
}

config.load = function ()
    return settings.load(default)
end

return config