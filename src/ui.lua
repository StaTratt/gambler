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
        settings.save()
    end

    if imgui.Checkbox('Auto roll', gambler.config.autoRoll) then
        settings.save()
    end
    
    imgui.Separator()
    
    -- Snake Eye Merits Section
    imgui.Text('Snake Eye Merits Configuration:')
    
    if imgui.Checkbox('Auto-check merits on load', gambler.config.autoCheckMerits) then
        settings.save()
    end
    
    imgui.Text(string.format('Snake Eye merit points: %d', gambler.config.snakeEyeMerits[1]))
    imgui.SameLine()
    imgui.PushItemWidth(50)
    if imgui.InputInt('##snakeEyeMerits', gambler.config.snakeEyeMerits) then
        if gambler.config.snakeEyeMerits[1] < 0 then
            gambler.config.snakeEyeMerits = { 0 } 
        elseif gambler.config.snakeEyeMerits[1] > 5 then
            gambler.config.snakeEyeMerits = { 5 }
        end
        settings.save()
    end
    imgui.PopItemWidth()
    
    if imgui.Button('Check Merits Now') then
        if utils.readSnakeEyeMeritsFromMemory() then
            utils.chatPrint(string.format('Snake Eye merit points: %d', gambler.config.snakeEyeMerits[1]), 'bonus')
        else
            utils.chatPrint('Failed to read merit data from memory. Make sure you are logged in.', 'error')
        end
    end
end

function ui.drawProbabilitySettings()
    imgui.Text('Bust Risk Management:')
    imgui.Separator()
    
    imgui.Text('Normal rolls - Max acceptable bust risk (%):')
    if imgui.SliderInt('##maxBustRisk', gambler.config.maxBustRisk, 0, 100) then
        settings.save()
    end
    
    if imgui.Checkbox('Use different bust risk for Crooked Cards', gambler.config.useCrookedCardsBustRisk) then
        settings.save()
    end
    
    if gambler.config.useCrookedCardsBustRisk[1] then
        imgui.Text('Crooked Cards - Max acceptable bust risk (%):')
        if imgui.SliderInt('##crookedCardsBustRisk', gambler.config.crookedCardsBustRisk, 0, 100) then
            settings.save()
        end
    end
    
    imgui.Separator()
    
    -- Use columns to display behaviors side by side
    imgui.Columns(2, 'behaviorColumns', true)
    
    -- Left column: Double-Up Behavior
    imgui.Text('Double-Up Behavior:')
    imgui.Separator()
    
    if imgui.Checkbox('Stop on lucky number', gambler.config.stopOnLucky) then
        settings.save()
    end
    
    -- Right column: Snake Eye Behavior
    imgui.NextColumn()
    imgui.Text('Snake Eye Behavior:')
    imgui.Separator()
    
    if imgui.Checkbox('Use on unlucky number', gambler.config.doubleUpOnUnlucky) then
        settings.save()
    end
    
    if imgui.Checkbox('Use before lucky number', gambler.config.doubleUpBeforeLucky) then
        settings.save()
    end
    
    if imgui.Checkbox('Use on 11', gambler.config.doubleUpOn11) then
        settings.save()
    end
    
    -- End columns
    imgui.Columns(1)
end

function ui.drawDebugSettings()
    imgui.TextColored({1.0, 0.5, 0.0, 1.0}, 'WARNING: These are debug settings for testing purposes.')
    imgui.Separator()
    
    if imgui.Checkbox('Stop rolling when Snake Eye would be used', gambler.config.debugStopOnSnakeEye) then
        settings.save()
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