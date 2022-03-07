
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

local moves = {
    
    --1. xoxx
    { 
        { 1, 0, 1, 1 }
    },
    
    --2. xxox
    { 
        { 1, 1, 0, 1 }
    },
    
    --3. x/o/x/x
    {
        { 1 },
        { 0 },
        { 1 },
        { 1 }
    },
    
    --4. x/x/o/x
    {
        { 1 },
        { 1 },
        { 0 },
        { 1 }
    },
    
    --5. ox/xo/ox
    {
        { 0, 1 },
        { 1, 0 },
        { 0, 1 }
    },
    
    --6. xo/ox/xo
    {
        { 1, 0 },
        { 0, 1 },
        { 1, 0 }
    },
    
    --7.oxo/xox
    {
        { 0, 1, 0 },
        { 1, 0, 1 }
    },
    
    --8. xox/oxo
    {
        { 1, 0, 1 },
        { 0, 1, 0 }
    },
    
    --9. xxo/oox
    {
        { 1, 1, 0 },
        { 0, 0, 1 }
    },
    
    --10. oox/xxo
    {
        { 0, 0, 1 },
        { 1, 1, 0 }
    },
    
    --11. ox/ox/xo
    {
        { 0, 1 },
        { 0, 1 },
        { 1, 0 }
    },
    
    --12. xo/xo/xo
    {
        { 1, 0 },
        { 1, 0 },
        { 0, 1 }
    },
    
    --13. xoo/oxx
    {
        { 1, 0, 0 },
        { 0, 1, 1 }
    },
        
    --14. oxx/xoo
    {
        { 0, 1, 1 },
        { 1, 0, 0 }
    },
    
    --15. ox/xo/xo
    {
        { 0, 1 },
        { 1, 0 },
        { 1, 0 }
    },
    
    --16. xo/ox/ox
    {
        { 1, 0 },
        { 0, 1 },
        { 0, 1 }
    }    
}

function findMatch(index, moves, gridState)
    
    local move = moves[index]
    
    for row = 1, 8 do
        for col = 1, 8 do
    
            -- Check the move bounds don't exceed the grid bounds.
            if col + #move <= 9 and row + #move[1] <= 9 then
                if checkMatchAtPosition(col, row, move, gridState) then
                    print("move " .. index .. " at " .. col .. ", " ..row)
                end
            end
            
        end
    end
end

function checkMatchAtPosition(col, row, move, gridState)
    
    local type = nil
    
    for i = 1, #move do
        for j = 1, #move[1] do
            
            -- IF the move contains "1" at this position we need to compare the other positions.
            if (move[i][j] == 1) then
                
                local currentType = gridState[col + i - 1][row + j - 1]
                
                if type == nil then
                    type = currentType       
                elseif currentType ~= type then
                    return false
                end
            end
        end
    end
    
    return true
end

local gridState = {
    { 1, 2, 3, 4, 5, 6, 7, 8 },
    { 2, 3, 4, 5, 6, 7, 8, 1 },
    { 3, 4, 5, 6, 7, 8, 1, 1 },
    { 4, 5, 6, 7, 8, 1, 2, 3 },
    { 5, 6, 7, 8, 1, 2, 3, 1 },
    { 6, 7, 8, 1, 2, 3, 4, 5 },
    { 7, 8, 1, 2, 3, 4, 5, 6 },
    { 8, 1, 2, 3, 4, 5, 6, 7 }
}

for index = 1, #moves do
   findMatch(index, moves, gridState) 
end