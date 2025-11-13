local settings = require('settings')
local imgui = require('imgui')
local utils = require('src/utils')

ui = {}

ui.maxLabelWidth = 0

function ui.update()
    if not gambler.visible[1] then
        return
    end

    ui.drawUI()
end

function ui.drawGeneralSettings()
    if imgui.Checkbox('Print to chat', gambler.config.chatPresence) then
        settings.save(gambler.config)
    end

    if imgui.Checkbox('Auto roll', gambler.config.autoRoll) then
        settings.save(gambler.config)
    end
    
    -- Auto-Roll Exceptions (moved under Auto roll checkbox)
    if gambler.config.autoRoll[1] then
        imgui.Separator()
        imgui.Text('Auto-Roll Exceptions:')
        imgui.TextWrapped('Add rolls that should NOT auto-roll:')
        ui.drawRollExceptions()
    end
end

function ui.drawMeritsSettings()
    imgui.Text('Snake Eye Merits Configuration:')
    imgui.Separator()
    
    if imgui.Checkbox('Auto-check merits on load', gambler.config.autoCheckMerits) then
        settings.save(gambler.config)
    end
    
    imgui.Separator()
    
    imgui.Text(string.format('Snake Eye merit points: %d', gambler.config.snakeEyeMerits[1]))
    imgui.SameLine()
    imgui.PushItemWidth(50)
    if imgui.InputInt('##snakeEyeMerits', gambler.config.snakeEyeMerits) then
        if gambler.config.snakeEyeMerits[1] < 0 then
            gambler.config.snakeEyeMerits = { 0 } 
        elseif gambler.config.snakeEyeMerits[1] > 5 then
            gambler.config.snakeEyeMerits = { 5 }
        end
        settings.save(gambler.config)
    end
    imgui.PopItemWidth()
    
    imgui.Separator()
    
    if imgui.Button('Check Merits Now') then
        gambler.shouldCheckMerits = true
        gambler.snakeEyeMeritsReceived = false
        if utils.readSnakeEyeMeritsFromMemory() then
            utils.chatPrint(string.format('Snake Eye merit points: %d', gambler.config.snakeEyeMerits[1]), 'bonus')
            gambler.shouldCheckMerits = false
        else
            utils.chatPrint('Failed to read merit data from memory. Make sure you are logged in.', 'error')
            gambler.shouldCheckMerits = false
        end
    end
end

function ui.drawProbabilitySettings()
    imgui.Text('Bust Risk Management:')
    imgui.Separator()
    
    imgui.Text('Normal rolls - Max acceptable bust risk (%):')
    if imgui.SliderInt('##maxBustRisk', gambler.config.maxBustRisk, 0, 100) then
        settings.save(gambler.config)
    end
    
    if imgui.Checkbox('Use different bust risk for Crooked Cards', gambler.config.useCrookedCardsBustRisk) then
        settings.save(gambler.config)
    end
    
    if gambler.config.useCrookedCardsBustRisk[1] then
        imgui.Text('Crooked Cards - Max acceptable bust risk (%):')
        if imgui.SliderInt('##crookedCardsBustRisk', gambler.config.crookedCardsBustRisk, 0, 100) then
            settings.save(gambler.config)
        end
    end
    
    imgui.Separator()
    
    -- Use columns to display behaviors side by side
    imgui.Columns(2, 'behaviorColumns', true)
    
    -- Left column: Double-Up Behavior
    imgui.Text('Double-Up Behavior:')
    imgui.Separator()
    
    if imgui.Checkbox('Stop on lucky number', gambler.config.stopOnLucky) then
        settings.save(gambler.config)
    end
    
    -- Right column: Snake Eye Behavior
    imgui.NextColumn()
    imgui.Text('Snake Eye Behavior:')
    imgui.Separator()
    
    if imgui.Checkbox('Use on unlucky number', gambler.config.doubleUpOnUnlucky) then
        settings.save(gambler.config)
    end
    
    if imgui.Checkbox('Use before lucky number', gambler.config.doubleUpBeforeLucky) then
        settings.save(gambler.config)
    end
    
    if imgui.Checkbox('Use on 11', gambler.config.doubleUpOn11) then
        settings.save(gambler.config)
    end
    
    -- End columns
    imgui.Columns(1)
end

function ui.drawRollExceptions()
    local rolls = require('data/rolls')
    
    -- Initialize exceptions table if it doesn't exist
    if not gambler.config.autoRollExceptions then
        gambler.config.autoRollExceptions = {}
    end
    
    -- Initialize input buffer if it doesn't exist
    if not ui.rollExceptionInput then
        ui.rollExceptionInput = { '' }
    end
    
    -- Text input for roll name
    imgui.PushItemWidth(250)
    imgui.InputText('##rollExceptionInput', ui.rollExceptionInput, 100)
    imgui.PopItemWidth()
    
    imgui.SameLine()
    
    -- Plus button to add roll
    if imgui.Button('+##addException') then
        local inputName = ui.rollExceptionInput[1]:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
        
        if inputName ~= '' then
            -- Find matching roll by name using substring match (same as command system)
            local foundRollID = nil
            for id, name in pairs(rolls.IDs) do
                if string.find(string.lower(name), string.lower(inputName)) then
                    foundRollID = id
                    break
                end
            end
            
            if foundRollID then
                -- Check if already in exceptions
                local alreadyExists = false
                for _, id in ipairs(gambler.config.autoRollExceptions) do
                    if id == foundRollID then
                        alreadyExists = true
                        break
                    end
                end
                
                if not alreadyExists then
                    table.insert(gambler.config.autoRollExceptions, foundRollID)
                    settings.save(gambler.config)
                    ui.rollExceptionInput = { '' } -- Clear input
                else
                    utils.chatPrint('Roll already in exception list', 'warning')
                end
            else
                utils.chatPrint('Roll not found: ' .. ui.rollExceptionInput[1], 'error')
            end
        end
    end
    
    imgui.Separator()
    
    -- Display current exceptions with remove buttons
    if #gambler.config.autoRollExceptions > 0 then
        imgui.Text('Current Exceptions:')
        
        local toRemove = nil
        for i, rollID in ipairs(gambler.config.autoRollExceptions) do
            local rollName = rolls.IDs[rollID] or 'Unknown Roll'
            
            -- Minus button to remove
            if imgui.Button('-##remove' .. rollID) then
                toRemove = i
            end
            
            imgui.SameLine()
            imgui.Text(rollName)
        end
        
        -- Remove after iteration to avoid modifying table while iterating
        if toRemove then
            table.remove(gambler.config.autoRollExceptions, toRemove)
            settings.save(gambler.config)
        end
    else
        imgui.TextColored({0.7, 0.7, 0.7, 1.0}, 'No exceptions added')
    end
end

function ui.drawDebugSettings()
    imgui.TextColored({1.0, 0.5, 0.0, 1.0}, 'WARNING: These are debug settings for testing purposes.')
    imgui.Separator()
    
    if imgui.Checkbox('Stop rolling when Snake Eye would be used', gambler.config.debugStopOnSnakeEye) then
        settings.save(gambler.config)
    end
    
    if gambler.config.debugStopOnSnakeEye[1] then
        imgui.TextWrapped('When enabled, the addon will stop rolling instead of using Snake Eye. This helps test/verify Snake Eye detection logic without actually using the ability.')
    end
end

function ui.drawUI()
    if imgui.Begin('gambler', gambler.visible) then
        if imgui.BeginTabBar('gambler settings') then
            if imgui.BeginTabItem('General Settings') then
                ui.drawGeneralSettings()
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Probability Settings') then
                ui.drawProbabilitySettings()
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Merits') then
                ui.drawMeritsSettings()
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem('DEBUG') then
                ui.drawDebugSettings()
                imgui.EndTabItem()
            end
            imgui.EndTabBar()
        end
        imgui.End()
    end
end

return ui