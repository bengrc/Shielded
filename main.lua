-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

--[[ local background = display.newCircle(display.contentCenterX, display.contentCenterY, 500)
background:setFillColor(0,5, 0,6, 0,6) ]]


local gemTable = {}

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local background = display.newImageRect("space-1.png", 500, 600)
background.x = display.contentCenterX
background.y = display.contentCenterY

local myCircle = display.newCircle( display.contentCenterX, display.contentCenterY, 30 )
myCircle:setFillColor( 8/255, 196/255, 208/255 )
myCircle.alpha = 0.3

local player = display.newCircle(display.contentCenterX, display.contentCenterY, 8)
player:setFillColor(1, 1, 1)


local function dragPlayer(event)
    local background = event.target
    local phase = event.phase
    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( background )
        player.touchOffsetX = event.x - player.x
        player.touchOffsetY = event.y - player.y

    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        player.x = event.x - player.touchOffsetX    
        player.y = event.y - player.touchOffsetY
    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus( nil )
    end
    return true
end
background:addEventListener( "touch", dragPlayer )


local function createGem()
    local gem = display.newImageRect("gem04purple.png", 40, 40)
    table.insert(gemTable, gem)
    physics.addBody(gem, "dynamic", { radius=40, bounce=0.8 } )
    gem.myName = "gem"

    local whereFrom = math.random(4)
    if ( whereFrom == 1 ) then
        -- From the left
        gem.x = -60
        gem.y = math.random( 500 )
        gem:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        gem.x = math.random( display.contentWidth )
        gem.y = -60
        gem:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        gem.x = display.contentWidth + 60
        gem.y = math.random( 500 )
        gem:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    elseif (whereFrom == 4) then
        gem.x = math.random(display.contentWidth)
        gem.y = -60
    end
    gem:applyTorque( math.random( -6,6 ) )
end

local function gameLoop()
    createGem()
    for i = #gemTable, 1, -1 do
        local thisGem = gemTable[i] 
        if ( thisGem.x < -100 or
             thisGem.x > display.contentWidth + 100 or
             thisGem.y < -100 or
             thisGem.y > display.contentHeight + 100 )
        then
            display.remove( thisGem )
            table.remove( gemTable, i )
        end
    end
end
gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
