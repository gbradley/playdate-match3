
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

local potentialMatch3s = {
    
    --1. xoxx
    { 
        pattern = { { 1, 0, 1, 1 } },
        from = { 1, 1 },
        to = { 1, 2 }
    },
    
    --2. xxox
    { 
        pattern = { { 1, 1, 0, 1 } },
        from = { 1, 4 },
        to = { 1, 3 }
    },
    
    --3. x/o/x/x
    {
        pattern = {
            { 1 },
            { 0 },
            { 1 },
            { 1 }
        },
        from = { 1, 1 },
        to = { 2, 1 }
    },
    
    --4. x/x/o/x
    {
        pattern = {
            { 1 },
            { 1 },
            { 0 },
            { 1 }
        },
        from = { 4, 1 },
        to = { 3, 1 }
    },
    
    --5. ox/xo/ox
    {
        pattern = {
            { 0, 1 },
            { 1, 0 },
            { 0, 1 }
        },
        from = { 2, 1 },
        to = { 2, 2 }
    },
    
    --6. xo/ox/xo
    {
        pattern = {
            { 1, 0 },
            { 0, 1 },
            { 1, 0 }
        },
        from = { 2, 2 },
        to = { 2, 1 }
    },
    
    --7.oxo/xox
    {
        pattern = {
            { 0, 1, 0 },
            { 1, 0, 1 }
        },
        from = { 1, 2 },
        to = { 2, 2 }
    },
    
    --8. xox/oxo
    {
        pattern = {
            { 1, 0, 1 },
            { 0, 1, 0 }
        },
        from = { 2, 2 },
        to = { 2, 1 }
    },
    
    --9. xxo/oox
    {
        pattern = {
            { 1, 1, 0 },
            { 0, 0, 1 }
        },
        from = { 2, 3 },
        to = { 1, 3 }
    },
    
    --10. oox/xxo
    {
        pattern = {
            { 0, 0, 1 },
            { 1, 1, 0 }
        },
        from = { 1, 3 },
        to = { 1, 3 }
    },
    
    --11. ox/ox/xo
    {
        pattern = {
            { 0, 1 },
            { 0, 1 },
            { 1, 0 }
        },
        from = { 3, 1 },
        to = { 3, 2 }
    },
    
    --12. xo/xo/xo
    {
        pattern = {
            { 1, 0 },
            { 1, 0 },
            { 0, 1 }
        },
        from = { 3, 2 },
        to = { 3, 1 }
    },
    
    --13. xoo/oxx
    {
        pattern = {
            { 1, 0, 0 },
            { 0, 1, 1 }
        },
        from = { 1, 1 },
        to = { 2, 1 }
    },
        
    --14. oxx/xoo
    {
        pattern = {
            { 0, 1, 1 },
            { 1, 0, 0 }
        },
        from = { 2, 1 },
        to = { 1, 1 }
    },
    
    --15. ox/xo/xo
    {
        pattern = {
            { 0, 1 },
            { 1, 0 },
            { 1, 0 }
        },
        from = { 1, 2 },
        to = { 1, 1 }
    },
    
    --16. xo/ox/ox
    {
        pattern = {
            { 1, 0 },
            { 0, 1 },
            { 0, 1 }
        },
        from = { 1, 1 },
        to = { 1, 2 }
    }
}

local potentialMatch4s = {
    --1. xxox/ooxo
    {
        pattern = {
            { 1, 1, 0, 1 },
            { 0, 0, 1, 0 }
        },
        from = { 2, 3 },
        to = { 1, 3 }
    },
    
    --2. ox/ox/xo/ox
    {
        pattern = {
            { 0, 1 },
            { 0, 1 },
            { 1, 0 },
            { 0, 1 }
        },
        from = { 3, 1 },
        to = { 3, 2 }
    },
    
    --3. xxox/ooxo
    {
        pattern = {
            { 0, 1, 0, 0 },
            { 1, 0, 1, 1 }
        },
        from = { 1, 2 },
        to = { 2, 2 }
    },
        
    --4. xo/ox/xo/xo
    {
        pattern = {
            { 1, 0 },
            { 0, 1 },
            { 1, 0 },
            { 1, 0 }
        },
        from = { 2, 2 },
        to = { 2, 1 }
    },
    
    --5. xxox/ooxo
    {
        pattern = {
            { 0, 0, 1, 0 },
            { 1, 1, 0, 1 }
        },
        from = { 1, 3 },
        to = { 2, 3 }
    },
    
    --6. xo/xo/ox/xo
    {
        pattern = {
            { 1, 0 },
            { 1, 0 },
            { 0, 1 },
            { 1, 0 }
        },
        from = { 3, 2 },
        to = { 3, 1 }
    },
    
    --7. xxox/ooxo
    {
        pattern = {
            { 1, 0, 1, 1 },
            { 0, 1, 0, 0 }
        },
        from = { 2, 2 },
        to = { 1, 2 }
    },
        
    --8. ox/xo/ox/ox
    {
        pattern = {
            { 0, 1 },
            { 1, 0 },
            { 0, 1 },
            { 0, 1 }
        },
        from = { 2, 1 },
        to = { 2, 2 }
    }
}

function findMatch(index, moves, gridState)
    
    local move = moves[index]
    
    for row = 1, 8 do
        for col = 1, 8 do
    
            -- Check the move bounds don't exceed the grid bounds.
            if col + #move.pattern <= 9 and row + #move.pattern[1] <= 9 then
                if checkMatchAtPosition(col, row, move, gridState) then
                    --print("move " .. index .. " at " .. col .. ", " ..row)
                    
                    -- Translate the local from/to into grid indeces.
                    local from = { col + move.from[1] - 1, row + move.from[2] - 1 }
                    local to = { col + move.to[1] - 1, row + move.to[2] - 1 }
                    
                    -- Get the type at the "from" position
                    local tile = gridState[from[1]][from[2]]
                
                    -- For now all tiles have an equal score
                    local score = 1
                
                    return from, to, tile, score
                end
            end
        end
    end
end

function checkMatchAtPosition(col, row, move, gridState)
    
    local type = nil
    
    for i = 1, #move.pattern do
        for j = 1, #move.pattern[1] do
            
            -- If the move contains "1" at this position we need to compare the other positions.
            if (move.pattern[i][j] == 1) then
                
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

function findBestMove(potentialMoves, tileCapacity, gridState)
    
local possibleMoves = {}
    
for index = 1, #potentialMatch4s do
    local from, to, tile, score = findMatch(index, potentialMoves, gridState) 
    if from then
        possibleMoves[#possibleMoves + 1] = {from = from, to = to, tile = tile, score = score }
    end
end

table.sort(possibleMoves, function(a, b)
    if tileCapacity[a.tile] > tileCapacity[b.tile] then return 1 end
    if tileCapacity[a.tile] < tileCapacity[b.tile] then return -1 end
    return 0
end)

printTable(possibleMoves)

end



local gridState = {
    { 1, 2, 3, 4, 5, 6, 7, 8 },
    { 2, 3, 4, 5, 6, 7, 8, 1 },
    { 3, 4, 5, 6, 7, 8, 4, 1 },
    { 4, 5, 6, 7, 8, 5, 1, 3 },
    { 5, 1, 6, 8, 1, 2, 3, 1 },
    { 6, 6, 8, 6, 2, 3, 4, 5 },
    { 7, 8, 1, 2, 3, 8, 5, 6 },
    { 8, 1, 2, 3, 8, 5, 8, 8 }
}

local tiles = {
    circle = 1,
    square = 2,
    triangle = 3,
    hexagon = 4,
    moon = 5,
    arrow = 6,
    cross = 7,
    skull = 8   
}

-- How many tiles of each kind the opponent team need. We arbitrarily set skulls to a large number to always prioritize them.
local tileCapacity = {
    [tiles.circle] = 4,
    [tiles.square] = 0,
    [tiles.triangle] = 0,
    [tiles.hexagon] = 2,
    [tiles.moon] = 5,
    [tiles.arrow] = 10,
    [tiles.cross] = 0,
    [tiles.skull] = 10000
}


findBestMove(potentialMatch4s, tileCapacity, gridState)
