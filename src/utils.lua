utils = {}

local rolls = require('data/rolls')
local config = require('data/config').load()
local settings = require('settings')
local lastChatMessage = nil

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    local party = AshitaCore:GetMemoryManager():GetParty()
    if e.id == 0xB then
        zoning_bool = true
        gambler.snakeEyeMeritsReceived = false
    elseif e.id == 0xA and zoning_bool then
        zoning_bool = false
    end
    
    if e.id == 0x8C and not gambler.snakeEyeMeritsReceived then
        local meritCount = struct.unpack('H', e.data, 0x04 + 1)
        
        for i = 0, meritCount - 1 do
            local offset = 0x08 + (i * 4)
            local meritIndex = struct.unpack('H', e.data, offset + 1)
            local meritNext = struct.unpack('B', e.data, offset + 2 + 1)
            local meritCount = struct.unpack('B', e.data, offset + 3 + 1)
            
            local actualIndex = bit.band(meritIndex, bit.bnot(1))
            
            if actualIndex == 0xC00 then
                gambler.config.snakeEyeMerits[1] = meritCount
                gambler.snakeEyeMeritsReceived = true
                utils.chatPrint(string.format('Snake Eye merit points detected: %d', meritCount), 'bonus')
                settings.save()
                break
            end
        end
    end
    
    if not zoning_bool then
        if e.id == 0x28 then
            local actor = struct.unpack('I', e.data, 6);
            local category = ashita.bits.unpack_be(e.data_raw, 82, 4);
            local rollNumber = ashita.bits.unpack_be(e.data_raw, 213, 17);

            if category == 6 then
                roll_id = ashita.bits.unpack_be(e.data_raw, 86, 10);
                -- Verify that the ability ID is actually a roll before processing
                if rolls.IDs[roll_id] and rollNumber and actor == AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0) then
                    -- Crooked Cards status is already stored in monitor[3] from useRoll()
                    
                    -- Store gear when we first detect the roll (only if we haven't already captured it)
                    if not gambler.initialRollGear or not gambler.initialRollGear.neckId then
                        local ring1Id, ring1Item = utils.getEquippedItem(13)
                        local ring2Id, ring2Item = utils.getEquippedItem(14)
                        local neckId, neckItem = utils.getEquippedItem(9)
                        local mainhandId, mainhandItem = utils.getEquippedItem(0)
                        
                        gambler.initialRollGear = {
                            ring1Id = ring1Id,
                            ring2Id = ring2Id,
                            neckId = neckId,
                            mainhandId = mainhandId,
                            mainhandItem = mainhandItem
                        }
                    end
                    
                    utils.useDoubleUp(roll_id, rollNumber)
                end
            end
        end
    end
    return false;
end);

function utils.useRoll(ID)
    if not utils.canRoll(ID) then
        return false
    end

    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if player then
        local effects = player:GetBuffs()
        local hasCrookedCards = false
        for i = 1, 32 do
            local effect = effects[i]
            if effect == 601 then
                hasCrookedCards = true
                break
            end
        end
        gambler.monitor[3] = hasCrookedCards
    else
        gambler.monitor[3] = false
    end

    -- Check Snake Eye availability ONCE at the start of the roll
    gambler.snakeEyeAvailableThisRoll = utils.canCastAbility("Snake Eye")

    local rollName = rolls.IDs[ID]
    AshitaCore:GetChatManager():QueueCommand(-1, string.format('/ja "%s" <me>', rollName))

    return true
end

function utils.useSnakeEye()
    -- Set the pending flag immediately to prevent spam
    gambler.pendingSnakeEyeDoubleUp = true
    
    -- Mark Snake Eye as used for this roll
    gambler.snakeEyeAvailableThisRoll = false
    
    AshitaCore:GetChatManager():QueueCommand(-1, '/ja "Snake Eye" <me>')
    
    -- Clear the pending flag after a delay
    ashita.tasks.once(2, function()
        gambler.pendingSnakeEyeDoubleUp = false
    end)
    
    return true
end

function utils.useDoubleUp(ID, v)
    if not gambler.config.autoRoll[1] then
        return false
    end

    if v > 11 then
        if gambler.config.chatPresence[1] then
            local rollData = utils.getRollData(ID)
            local bustDebuff = ''
            if rollData then
                local bustValue = rollData.bust
                local isPercentage = rollData.desc:find('%%') ~= nil
                bustDebuff = isPercentage and string.format(' (-%d%% %s)', bustValue, rollData.desc) or string.format(' (-%d %s)', bustValue, rollData.desc)
            end
            local coloredBust = string.format('\x1F\xA7BUST!\x1F\xA8')
            local message = string.format('%s %s %d%s', coloredBust, rolls.IDs[ID], v, bustDebuff)
            local formattedMsg = string.format('\x1F\xCF[gambler]\x1F\xA8 %s', message)
            AshitaCore:GetChatManager():AddChatMessage(207, false, formattedMsg)
        end
        gambler.monitor[1] = nil
        gambler.monitor[2] = nil
        gambler.monitor[3] = false
        gambler.initialRollGear = {}
        gambler.pendingSnakeEyeDoubleUp = false
        gambler.snakeEyeAvailableThisRoll = false
        return false
    end

    gambler.monitor[1] = ID
    gambler.monitor[2] = v
    
    -- Always stop on 11 - can't improve from here (check this FIRST before any pending flags)
    if v == 11 then
        gambler.monitor[1] = nil
        gambler.monitor[2] = nil
        gambler.pendingSnakeEyeDoubleUp = false
        gambler.snakeEyeAvailableThisRoll = false
        if gambler.config.chatPresence[1] then
            ashita.tasks.once(1, function()
                if gambler.lastMessage and gambler.lastMessage:find('Final Roll Buff:') then
                    return
                end
                
                local bonusInfo = utils.calculateRollBonus(ID, v)
                if bonusInfo then
                    local bonusText = bonusInfo.isPercentage and string.format('+%d%%', bonusInfo.value) or string.format('+%d', bonusInfo.value)
                    
                    local rollName = rolls.IDs[ID]
                    local rollNumberText = string.format('%s %d', rollName, v)
                    local reason = 'SWAGROLL'
                    local message = string.format('\x1F\x9C%s - %s\n  \x1F\x9CFinal Roll Buff: \x1F\x9E%s %s', rollNumberText, reason, bonusText, bonusInfo.description)
                    
                    local formattedMsg = string.format('\x1F\xCF[gambler]\x1F\x9C %s', message)
                    AshitaCore:GetChatManager():AddChatMessage(207, false, formattedMsg)
                    gambler.lastMessage = rollNumberText .. ' - ' .. reason .. '\n  Final Roll Buff: ' .. bonusText .. ' ' .. bonusInfo.description
                end
                gambler.initialRollGear = {}
                gambler.monitor[3] = false
            end)
        else
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
        end
        return false
    end
    
    -- Check if we're in the middle of a Snake Eye sequence
    if gambler.pendingSnakeEyeDoubleUp then
        return true
    end

    if gambler.config.stopOnLucky[1] and utils.isLuckyNumber(ID, v) then
        gambler.monitor[1] = nil
        gambler.monitor[2] = nil
        gambler.pendingSnakeEyeDoubleUp = false
        gambler.snakeEyeAvailableThisRoll = false
        if gambler.config.chatPresence[1] then
            ashita.tasks.once(1, function()
                if gambler.lastMessage and gambler.lastMessage:find('Final Roll Buff:') then
                    return
                end
                
                local bonusInfo = utils.calculateRollBonus(ID, v)
                if bonusInfo then
                    local bonusText = bonusInfo.isPercentage and string.format('+%d%%', bonusInfo.value) or string.format('+%d', bonusInfo.value)
                    
                    local rollName = rolls.IDs[ID]
                    local rollNumberText = string.format('%s %d', rollName, v)
                    local reason = 'Lucky Number'
                    local message = string.format('\x1F\x9C%s - %s\n  \x1F\x9CFinal Roll Buff: \x1F\x9E%s %s', rollNumberText, reason, bonusText, bonusInfo.description)
                    
                    local formattedMsg = string.format('\x1F\xCF[gambler]\x1F\x9C %s', message)
                    AshitaCore:GetChatManager():AddChatMessage(207, false, formattedMsg)
                    gambler.lastMessage = rollNumberText .. ' - ' .. reason .. '\n  Final Roll Buff: ' .. bonusText .. ' ' .. bonusInfo.description
                end
                gambler.initialRollGear = {}
                gambler.monitor[3] = false
            end)
        else
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
        end
        return false
    end

    -- Check if Snake Eye buff is active (buff ID 357)
    -- If it is, use Double-Up immediately without risk assessment
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if player then
        local effects = player:GetBuffs()
        for i = 1, 32 do
            local effect = effects[i]
            if effect == 357 then
                -- Snake Eye buff active, just use Double-Up
                if gambler.pendingDoubleUp then
                    return true
                end
                
                local canUseDoubleUp = utils.canCastAbility("Double-Up")
                if not canUseDoubleUp then
                    return true
                end
                
                AshitaCore:GetChatManager():QueueCommand(-1, '/ja "Double-Up" <me>')
                gambler.pendingDoubleUp = true
                
                ashita.tasks.once(2, function()
                    gambler.pendingDoubleUp = false
                end)
                
                return true
            end
        end
    end
    
    -- Check if we should use Snake Eye (only if it was available at the start of this roll)
    if gambler.snakeEyeAvailableThisRoll and gambler.config.doubleUpOnUnlucky[1] and utils.isUnluckyNumber(ID, v) and v < 11 then
        if gambler.config.chatPresence[1] then
            utils.chatPrint(string.format('Rolled unlucky number %d | using Snake Eye to push to %d', v, v+1), 'info')
        end
        
        if gambler.config.debugStopOnSnakeEye[1] then
            utils.chatPrint('[DEBUG] Would use Snake Eye here - stopping instead', 'warning')
            gambler.monitor[1] = nil
            gambler.monitor[2] = nil
            gambler.pendingSnakeEyeDoubleUp = false
            gambler.snakeEyeAvailableThisRoll = false
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
            return false
        end
        
        utils.useSnakeEye()
        return true
    elseif gambler.snakeEyeAvailableThisRoll and gambler.config.doubleUpBeforeLucky[1] and utils.isBeforeLucky(ID, v) then
        if gambler.config.chatPresence[1] then
            local rollData = utils.getRollData(ID)
            utils.chatPrint(string.format('Rolled %d | using Snake Eye to push to lucky number %d', v, rollData.lucky), 'info')
        end
        
        if gambler.config.debugStopOnSnakeEye[1] then
            utils.chatPrint('[DEBUG] Would use Snake Eye here - stopping instead', 'warning')
            gambler.monitor[1] = nil
            gambler.monitor[2] = nil
            gambler.pendingSnakeEyeDoubleUp = false
            gambler.snakeEyeAvailableThisRoll = false
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
            return false
        end
        
        utils.useSnakeEye()
        return true
    elseif gambler.snakeEyeAvailableThisRoll and gambler.config.doubleUpOn11[1] and v == 10 then
        if gambler.config.chatPresence[1] then
            utils.chatPrint('Rolled 10, using Snake Eye to reach 11', 'info')
        end
        
        if gambler.config.debugStopOnSnakeEye[1] then
            utils.chatPrint('[DEBUG] Would use Snake Eye here - stopping instead', 'warning')
            gambler.monitor[1] = nil
            gambler.monitor[2] = nil
            gambler.pendingSnakeEyeDoubleUp = false
            gambler.snakeEyeAvailableThisRoll = false
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
            return false
        end
        
        utils.useSnakeEye()
        return true
    end
    
    -- No Snake Eye buff or usage, check bust risk
    local bustChance = utils.calculateBustChance(v, ID)
    local hasCrookedCards = (gambler.monitor[3] == true)
    local maxBustRisk = gambler.config.maxBustRisk[1]
    
    if hasCrookedCards and gambler.config.useCrookedCardsBustRisk[1] then
        maxBustRisk = gambler.config.crookedCardsBustRisk[1]
    end

    if bustChance >= maxBustRisk then
        gambler.monitor[1] = nil
        gambler.monitor[2] = nil
        gambler.pendingSnakeEyeDoubleUp = false
        gambler.snakeEyeAvailableThisRoll = false
        if gambler.config.chatPresence[1] then
            ashita.tasks.once(1, function()
                if gambler.lastMessage and gambler.lastMessage:find('Final Roll Buff:') then
                    return
                end
                
                local bonusInfo = utils.calculateRollBonus(ID, v)
                if bonusInfo then
                    local bonusText = bonusInfo.isPercentage and string.format('+%d%%', bonusInfo.value) or string.format('+%d', bonusInfo.value)
                    local rollName = rolls.IDs[ID]
                    local rollNumberText = string.format('%s %d', rollName, v)
                    local reason = string.format('Bust Risk %d%%', bustChance)
                    local message = string.format('\x1F\x9C%s - %s\n  \x1F\x9CFinal Roll Buff: \x1F\x9E%s %s', rollNumberText, reason, bonusText, bonusInfo.description)
                    
                    local formattedMsg = string.format('\x1F\xCF[gambler]\x1F\x9C %s', message)
                    AshitaCore:GetChatManager():AddChatMessage(207, false, formattedMsg)
                    gambler.lastMessage = rollNumberText .. ' - ' .. reason .. '\n  Final Roll Buff: ' .. bonusText .. ' ' .. bonusInfo.description
                end
                gambler.initialRollGear = {}
                gambler.monitor[3] = false
            end)
        else
            gambler.initialRollGear = {}
            gambler.monitor[3] = false
        end
        return false
    end

    -- If we already queued a Double-Up, wait for the result
    if gambler.pendingDoubleUp then
        return true
    end
    
    local canUseDoubleUp = utils.canCastAbility("Double-Up")
    
    if not canUseDoubleUp then
        -- Double-Up is on cooldown, keep waiting
        return true
    end
    
    -- Queue the Double-Up and set the pending flag
    AshitaCore:GetChatManager():QueueCommand(-1, '/ja "Double-Up" <me>')
    gambler.pendingDoubleUp = true
    
    -- Clear the pending flag after a delay to prevent spamming
    -- Don't clear the monitor - let the packet handler update it with the new roll
    ashita.tasks.once(2, function()
        gambler.pendingDoubleUp = false
    end)
    
    return true
end

function utils.canAction()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if not player then 
        utils.chatPrint("Cannot perform action: Player entity not found.", 'error')
        return false 
    end

    if player:GetMainJob() ~= 17 then 
        utils.chatPrint("Cannot perform action: Player's main job is not Corsair, it's " .. tostring(player:GetMainJob()) .. ".", 'error')
        return false 
    end

    local effects = player:GetBuffs()
    local blockingEffects = {
        [2] = true, [7] = true, [10] = true, [14] = true, 
        [28] = true, [29] = true, [193] = true
    }

    for i = 1, 32 do
        local effect = effects[i]
        if effect ~= 0 and blockingEffects[effect] then
            utils.chatPrint(string.format("Cannot perform action: Player is affected by status effect ID %d.", effect), 'warning')
            return false
        end
    end

    return true
end

function utils.canRoll(ID)
    local rollName = rolls.IDs[ID]

    if not utils.canAction() then return false end
    
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    local unlockLevel = rolls.unlockLevel[ID]
    if unlockLevel and player:GetMainJobLevel() < unlockLevel then
        utils.chatPrint("Cannot roll: Player's level is too low. Required level: " .. unlockLevel .. ", Player level: " .. player:GetMainJobLevel(), 'warning')
        return false
    end

    if not utils.canCastAbility(rollName) then
        utils.chatPrint("Cannot roll: Phantom-Roll is on cooldown.", 'warning')
        return false
    end

    local effects = player:GetBuffs()
    for i = 1, 32 do
        local effect = effects[i]
        if effect == rolls.buffs[ID] then
            utils.chatPrint(string.format("Cannot roll: Player is already affected by the roll '%s' (buff ID %d).", rollName, effect), 'warning')
            return false
        end
    end

    return true
end

function utils.canCastAbility(ability)
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if not player then return false end
    
    local abilityRes = AshitaCore:GetResourceManager():GetAbilityByName(ability, 0)
    local recastMgr = AshitaCore:GetMemoryManager():GetRecast()
    if not abilityRes or not recastMgr then return false end
    
    local recastTime = recastMgr:GetAbilityTimer(abilityRes.RecastTimerId)
    return recastTime == 0
end

function utils.chatPrint(msg, msgType)
    if gambler.config.chatPresence[1] then
        local colorCode = 207
        
        if msgType == 'success' then
            colorCode = 158
        elseif msgType == 'warning' then
            colorCode = 208
        elseif msgType == 'error' then
            colorCode = 167
        elseif msgType == 'info' then
            colorCode = 207
        elseif msgType == 'roll' then
            colorCode = 122
        elseif msgType == 'bonus' then
            colorCode = 200
        end
        
        local formattedMsg = string.format('\x1F\xCF[gambler]\x1F%c %s', colorCode, msg)
        if formattedMsg ~= lastChatMessage then
            AshitaCore:GetChatManager():AddChatMessage(207, false, formattedMsg)
            lastChatMessage = formattedMsg
            gambler.lastMessage = msg
        end
    end
end

function utils.hasCrookedCards()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if not player then
        return false
    end
    
    local effects = player:GetBuffs()
    for i = 1, 32 do
        local effect = effects[i]
        if effect == 601 then
            return true
        end
    end
    
    return false
end

function utils.checkSnakeEyeMerits()
    return gambler.config.snakeEyeMerits[1] or 0
end

function utils.readSnakeEyeMeritsFromMemory()
    local pInventory = AshitaCore:GetPointerManager():Get('inventory')
    if pInventory == 0 then
        return false
    end
    
    local ptr = ashita.memory.read_uint32(pInventory)
    if ptr == 0 then
        return false
    end
    
    ptr = ashita.memory.read_uint32(ptr)
    if ptr == 0 then
        return false
    end
    
    ptr = ptr + 0x2CFF4
    local count = ashita.memory.read_uint16(ptr + 2)
    local meritptr = ashita.memory.read_uint32(ptr + 4)
    
    if count > 0 then
        for i = 1, count do
            local meritId = ashita.memory.read_uint16(meritptr + 0)
            local meritCount = ashita.memory.read_uint8(meritptr + 3)
            
            if meritId == 0xC00 then
                gambler.config.snakeEyeMerits[1] = meritCount
                settings.save()
                return true
            end
            
            meritptr = meritptr + 4
        end
    end
    
    return false
end

function utils.getRollData(rollID)
    local rollName = rolls.IDs[rollID]
    if rollName and rolls.corsairRoll_Data[rollName] then
        return rolls.corsairRoll_Data[rollName]
    end
    return nil
end

function utils.isLuckyNumber(rollID, value)
    local rollData = utils.getRollData(rollID)
    if rollData then
        return rollData.lucky == value
    end
    return false
end

function utils.isUnluckyNumber(rollID, value)
    local rollData = utils.getRollData(rollID)
    if rollData then
        return rollData.unlucky == value
    end
    return false
end

function utils.isBeforeLucky(rollID, value)
    local rollData = utils.getRollData(rollID)
    if rollData then
        return (rollData.lucky - 1) == value
    end
    return false
end

function utils.getEquippedItem(slot)
    local inventoryManager = AshitaCore:GetMemoryManager():GetInventory()
    local equippedItem = inventoryManager:GetEquippedItem(slot)
    local index = bit.band(equippedItem.Index, 0x00FF)

    if index == 0 or index == nil then
        return 0, nil
    end

    local container = bit.band(equippedItem.Index, 0xFF00) / 256
    local item = inventoryManager:GetContainerItem(container, index)
    
    if item and item.Id ~= 0 and item.Count ~= 0 then
        return item.Id, item
    end
    
    return 0, nil
end

function utils.getMainhandAugmentPhantomRoll(item)
    if not item or not item.Extra then
        return 0
    end
    
    if not rolls.gearData.mainhand[item.Id] then
        return 0
    end
    
    local itemTable = item.Extra:totable()
    local path = ashita.bits.unpack_be(itemTable, 32, 2)
    
    if path ~= 2 then
        return 0
    end
    
    local rank = ashita.bits.unpack_be(itemTable, 50, 5)
    
    if rolls.rankAugmentPhantomRoll and rolls.rankAugmentPhantomRoll[rank] then
        return rolls.rankAugmentPhantomRoll[rank]
    end
    
    return 0
end

function utils.calculateRollBonus(rollID, rollNumber)
    local rollData = utils.getRollData(rollID)
    if not rollData then
        return nil
    end
    
    local rollName = rolls.IDs[rollID]
    local bonus = 0
    
    if rollNumber > 11 then
        bonus = -rollData.bust
        return {
            value = bonus,
            description = rollData.desc,
            isBust = true,
            isPercentage = false
        }
    end
    
    local ring1Id, ring2Id, neckId, mainhandItem
    if gambler.initialRollGear and gambler.initialRollGear.neckId then
        ring1Id = gambler.initialRollGear.ring1Id
        ring2Id = gambler.initialRollGear.ring2Id
        neckId = gambler.initialRollGear.neckId
        mainhandItem = gambler.initialRollGear.mainhandItem
    else
        ring1Id = utils.getEquippedItem(13)
        ring2Id = utils.getEquippedItem(14)
        neckId = utils.getEquippedItem(9)
        local mainhandId
        mainhandId, mainhandItem = utils.getEquippedItem(0)
    end
    
    local hasCrookedCards = (gambler.monitor[3] == true)
    local effectiveRollNumber = rollNumber
    
    if hasCrookedCards then
        effectiveRollNumber = rollData.lucky
    end
    
    local baseBonus = rollData.rolls[effectiveRollNumber]
    bonus = baseBonus
    
    local effect = rollData.effect
    local gearBonus = 0
    local gearEnhancements = {}
    
    if effect ~= "Unknown" and rollName ~= "Companion's Roll" then
        local highestPhantomRoll = 0
        local phantomRollSources = {}
        
        local neckData = rolls.gearData.neck[neckId]
        if neckData and neckData.phantomRoll then
            table.insert(phantomRollSources, { value = neckData.phantomRoll, name = neckData.name })
            if neckData.phantomRoll > highestPhantomRoll then
                highestPhantomRoll = neckData.phantomRoll
            end
        end
        
        local ring1Data = rolls.gearData.ring[ring1Id]
        local ring2Data = rolls.gearData.ring[ring2Id]
        if ring1Data and ring1Data.phantomRoll then
            table.insert(phantomRollSources, { value = ring1Data.phantomRoll, name = ring1Data.name })
            if ring1Data.phantomRoll > highestPhantomRoll then
                highestPhantomRoll = ring1Data.phantomRoll
            end
        end
        if ring2Data and ring2Data.phantomRoll then
            table.insert(phantomRollSources, { value = ring2Data.phantomRoll, name = ring2Data.name })
            if ring2Data.phantomRoll > highestPhantomRoll then
                highestPhantomRoll = ring2Data.phantomRoll
            end
        end
        
        local mainhandPhantomRoll = utils.getMainhandAugmentPhantomRoll(mainhandItem)
        if mainhandPhantomRoll > 0 then
            local mainhandData = rolls.gearData.mainhand[gambler.initialRollGear.mainhandId]
            if mainhandData then
                table.insert(phantomRollSources, { value = mainhandPhantomRoll, name = mainhandData.name .. ' (augmented)' })
                if mainhandPhantomRoll > highestPhantomRoll then
                    highestPhantomRoll = mainhandPhantomRoll
                end
            end
        end
        
        -- Apply the highest Phantom Roll bonus
        if highestPhantomRoll > 0 then
            gearBonus = effect * highestPhantomRoll
            bonus = bonus + gearBonus
            
            -- Add enhancement text showing which piece provided the highest bonus
            for _, source in ipairs(phantomRollSources) do
                if source.value == highestPhantomRoll then
                    table.insert(gearEnhancements, string.format('+%d Phantom Roll (%s)', highestPhantomRoll, source.name))
                    break
                end
            end
        end
    end
    
    -- Check if this roll uses percentages
    local percentageRolls = {
        'Chaos Roll', 'Corsair\'s Roll', 'Healer\'s Roll', 'Choral Roll', 'Beast Roll',
        'Rogue\'s Roll', 'Fighter\'s Roll', 'Gallant\'s Roll', 'Scholar\'s Roll',
        'Naturalist\'s Roll', 'Bolter\'s Roll', 'Caster\'s Roll', 'Courser\'s Roll',
        'Blitzer\'s Roll', 'Allies\' Roll', 'Avenger\'s Roll'
    }
    
    local isPercentage = false
    for _, name in ipairs(percentageRolls) do
        if rollName == name then
            isPercentage = true
            break
        end
    end
    
    return {
        value = bonus,
        description = rollData.desc,
        isBust = false,
        isPercentage = isPercentage,
        gearBonus = gearBonus,
        gearEnhancements = gearEnhancements,
        hasCrookedCards = hasCrookedCards
    }
end

function utils.calculateBustChance(currentRoll, rollID)
    if currentRoll >= 11 then
        return 100
    end
    
    -- Double-Up adds 1-6 to the current roll
    -- Calculate how many outcomes (1-6) would cause a bust (>11)
    local bustOutcomes = 0
    for diceRoll = 1, 6 do
        if currentRoll + diceRoll > 11 then
            bustOutcomes = bustOutcomes + 1
        end
    end
    
    -- Base bust chance is the number of busting outcomes / 6 possible outcomes
    local baseBustChance = (bustOutcomes / 6) * 100
    
    -- If there's no chance to bust, return 0 immediately
    if baseBustChance == 0 then
        return 0
    end
    
    local snakeEyeMerits = gambler.config.snakeEyeMerits[1] or 0
    local snakeEyeChance = 0
    
    if snakeEyeMerits > 1 then
        snakeEyeChance = (snakeEyeMerits - 1) * 10
    end
    
    local rollData = rollID and utils.getRollData(rollID) or nil
    local snakeEyeSaveChance = 0
    
    if gambler.snakeEyeAvailableThisRoll and rollData then
        local wouldUseSnakeEyeOnNumbers = {}
        
        -- Check which dice outcomes (1-6) would trigger Snake Eye usage
        for diceRoll = 1, 6 do
            local futureRoll = currentRoll + diceRoll
            if futureRoll <= 11 then
                if gambler.config.doubleUpOnUnlucky[1] and rollData.unlucky == futureRoll then
                    wouldUseSnakeEyeOnNumbers[diceRoll] = true
                end
                if gambler.config.doubleUpBeforeLucky[1] and (rollData.lucky - 1) == futureRoll then
                    wouldUseSnakeEyeOnNumbers[diceRoll] = true
                end
                if gambler.config.doubleUpOn11[1] and futureRoll == 10 then
                    wouldUseSnakeEyeOnNumbers[diceRoll] = true
                end
            end
        end
        
        local countSnakeEyeNumbers = 0
        for _ in pairs(wouldUseSnakeEyeOnNumbers) do
            countSnakeEyeNumbers = countSnakeEyeNumbers + 1
        end
        
        if countSnakeEyeNumbers > 0 then
            snakeEyeSaveChance = (countSnakeEyeNumbers / 6) * 100
        end
    end
    
    local meritSaveChance = (snakeEyeChance / 100)
    local abilitySaveChance = (snakeEyeSaveChance / 100)
    local totalSaveChance = meritSaveChance + abilitySaveChance - (meritSaveChance * abilitySaveChance)
    local finalBustChance = baseBustChance * (1 - totalSaveChance)
    
    return math.floor(finalBustChance + 0.5)
end

function utils.getBustInfo(currentRoll, rollID)
    -- Get detailed information about bust chance
    local bustChance = utils.calculateBustChance(currentRoll, rollID)
    local snakeEyeMerits = gambler.config.snakeEyeMerits[1] or 0
    local snakeEyeChance = 0
    
    if snakeEyeMerits > 1 then
        snakeEyeChance = (snakeEyeMerits - 1) * 10
    end
    
    return {
        bustChance = bustChance,
        snakeEyeChance = snakeEyeChance,
        currentRoll = currentRoll,
        snakeEyeMerits = snakeEyeMerits
    }
end

return utils
