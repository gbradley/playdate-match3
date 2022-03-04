
-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/object"


local gfx <const> = playdate.graphics

local gridView = playdate.ui.gridview.new(24, 24)
local lastGridSelection = { 1, 1, 1 }

local turnFocus = { grid = 0, playerTeam = 1, opponentTeam = 2}
local currentTurnFocus = turnFocus.grid
local currentTeam = turnFocus.playerTeam

local teams = {}
teams[turnFocus.playerTeam] = {
    members = { "Frodo", "Sam", "Pippin"},
    view =  playdate.ui.gridview.new(80, 78),
    lastSelection = { 1, 1, 1 }
}
teams[turnFocus.opponentTeam] = {
    members = { "Sauron", "WitchKing", "Saruman"},
    view = playdate.ui.gridview.new(80, 78),
    lastSelection = { 1, 1, 1 }
}

-- Grid --

function setupGrid()

    gridView:setNumberOfColumns(8)
    gridView:setNumberOfRows(8)
    gridView:setCellPadding(2, 2, 2, 2)
    gridView.changeRowOnColumnWrap = false
    gridView.changeColumnonRowWrap = false
    gridView.scrollCellsToCenter = false

    function gridView:drawCell(section, row, column, selected, x, y, width, height)
        gfx.setLineWidth(ternary(selected, 3, 1))
        gfx.drawCircleInRect(x, y, width, height)
    end

end

-- Setup team view

function setupTeam(teamType, alignment)

    local team = teams[teamType]
    team.view:setNumberOfRows(#team.members)
    team.view:setCellPadding(1, 1, 1, 1)
    
    function team.view:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        
        local xOffset = ternary(alignment == kTextAlignment.left, 3, -3)
        gfx.drawTextInRect(team.members[row], x + xOffset, y + 3, width, height, nil, "...", alignment)
    end
    
    team.view:setSelection(team.lastSelection)
    
end

setupGrid()
setupTeam(turnFocus.playerTeam, kTextAlignment.left)
setupTeam(turnFocus.opponentTeam, kTextAlignment.right)

-- Update --

function playdate.update()
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 240);
    gfx.setColor(gfx.kColorBlack)

    gridView:drawInRect(88, 8, 224, 224)
    teams[turnFocus.playerTeam].view:drawInRect(0, 0, 88, 240)
    teams[turnFocus.opponentTeam].view:drawInRect(400 - 82, 0, 88, 240)
    
    playdate.timer.updateTimers()

end

-- Helpers

function ternary(condition, yes, no)
    if condition then return yes else return no end
end

function switchTeam()
    
    previousTeam = teams[currentTeam]
    previousTeam.lastSelection = table.pack(previousTeam.view:getSelection())
    previousTeam.view:setSelection(nil)
    
    currentTeam = ternary(currentTeam == turnFocus.playerTeam, turnFocus.opponentTeam, turnFocus.playerTeam)
    
    teams[currentTeam].view:setSelection(table.unpack(previousTeam.lastSelection))
    currentTurnFocus = currentTeam
end

-- Input Handlers

local keyTimers = {}
local baseInputHandlers = nil
local gridInputHandlers = nil
local teamInputHandlers = nil

baseInputHandlers = {
    
    leftButtonUp = function()
        keyTimers[playdate.kButtonLeft]:remove()
    end,
    
    rightButtonUp = function()
        keyTimers[playdate.kButtonRight]:remove()
    end,
    
    upButtonUp = function()
        keyTimers[playdate.kButtonUp]:remove()
    end,
    
    downButtonUp = function()
        keyTimers[playdate.kButtonDown]:remove()
    end
    
}

gridInputHandlers = {
    
    leftButtonDown = function()
        local function timerCallback()
            gridView:selectPreviousColumn(true)
        end
        setKeyTimer(playdate.kButtonLeft, timerCallback)
    end,
    
    rightButtonDown = function()
        local function timerCallback()
            gridView:selectNextColumn(true)
        end
        setKeyTimer(playdate.kButtonRight, timerCallback)
    end,
    
    upButtonDown = function()
        local function timerCallback()
            gridView:selectPreviousRow(true)
        end
        setKeyTimer(playdate.kButtonUp, timerCallback)
    end,
    
    downButtonDown = function()
        local function timerCallback()
            gridView:selectNextRow(true)
        end
        setKeyTimer(playdate.kButtonDown, timerCallback)
    end,
    
    -- Switching from grid to current team
    BButtonDown = function()
        
        lastGridSelection = table.pack(gridView:getSelection())
        gridView:setSelection(nil)
        
        local team = teams[currentTeam]
        team.view:setSelection(table.unpack(team.lastSelection))
        
        currentTurnFocus = currentTeam
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push(teamInputHandlers)
        
    end
    
}

teamInputHandlers = {
    
    leftButtonDown = function()
        local function timerCallback()
            switchTeam()
        end
        setKeyTimer(playdate.kButtonLeft, timerCallback)
    end,
    
    rightButtonDown = function()
        local function timerCallback()
            switchTeam()
        end
        setKeyTimer(playdate.kButtonRight, timerCallback)
    end,
    
    upButtonDown = function()
        local function timerCallback()
            teams[currentTeam].view:selectPreviousRow(true)
        end
        setKeyTimer(playdate.kButtonUp, timerCallback)
    end,
    
    downButtonDown = function()
        local function timerCallback()
           teams[currentTeam].view:selectNextRow(true)
        end
        setKeyTimer(playdate.kButtonDown, timerCallback)
    end,
    
    -- Switching from current team to grid
    BButtonDown = function()
                
        local team = teams[currentTeam]
        team.lastSelection = table.pack(team.view:getSelection())
        team.view:setSelection(nil)
        
        gridView:setSelection(table.unpack(lastGridSelection))
        
        currentTurnFocus = turnFocus.grid
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push(gridInputHandlers)
        
    end
    
}

function setKeyTimer(button, timerCallback)
    keyTimers[button] = playdate.timer.keyRepeatTimer(timerCallback)
end

playdate.inputHandlers.push(baseInputHandlers)
playdate.inputHandlers.push(gridInputHandlers)