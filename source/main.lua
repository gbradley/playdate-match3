
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

import "Grid/grid"
import "Team/team"

local gfx <const> = playdate.graphics

local turnFocus = { grid = 0, playerTeam = 1, opponentTeam = 2}
local currentTurnFocus = turnFocus.grid
local currentTeam = turnFocus.playerTeam

local grid = Grid()
grid:setup()

local teams = {
    [turnFocus.playerTeam] = Team({ "Frodo", "Sam", "Pippin"}, kTextAlignment.left),
    [turnFocus.opponentTeam] = Team({ "Sauron", "WitchKing", "Saruman"}, kTextAlignment.right)
}
teams[turnFocus.playerTeam]:setup()
teams[turnFocus.opponentTeam]:setup()

-- Update --

function playdate.update()
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 240);
    gfx.setColor(gfx.kColorBlack)

    grid.view:drawInRect(88, 8, 224, 224)
    teams[turnFocus.playerTeam].view:drawInRect(0, 0, 88, 240)
    teams[turnFocus.opponentTeam].view:drawInRect(400 - 82, 0, 88, 240)
    
    playdate.timer.updateTimers()
end

-- Helpers

function ternary(condition, yes, no)
    if condition then return yes else return no end
end

function switchTeam()
    local previousTeam = teams[currentTeam]
    currentTeam = ternary(currentTeam == turnFocus.playerTeam, turnFocus.opponentTeam, turnFocus.playerTeam)
    teams[currentTeam]:switchFrom(previousTeam)
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
            grid.view:selectPreviousColumn(true)
        end
        setKeyTimer(playdate.kButtonLeft, timerCallback)
    end,
    
    rightButtonDown = function()
        local function timerCallback()
            grid.view:selectNextColumn(true)
        end
        setKeyTimer(playdate.kButtonRight, timerCallback)
    end,
    
    upButtonDown = function()
        local function timerCallback()
            grid.view:selectPreviousRow(true)
        end
        setKeyTimer(playdate.kButtonUp, timerCallback)
    end,
    
    downButtonDown = function()
        local function timerCallback()
            grid.view:selectNextRow(true)
        end
        setKeyTimer(playdate.kButtonDown, timerCallback)
    end,
    
    -- Switching from grid to current team
    BButtonDown = function()
        
        grid:deselect()
        teams[currentTeam]:reselect()
        
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
                
        teams[currentTeam]:deselect()
        grid:reselect()
        
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