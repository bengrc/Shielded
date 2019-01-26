-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

--[[ local background = display.newCircle(display.contentCenterX, display.contentCenterY, 500)
background:setFillColor(0,5, 0,6, 0,6) ]]


local gemTable = {}

local isAtHome = false;

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local background = display.newImageRect("space-1.png", 500, 600)
background.x = display.contentCenterX
background.y = display.contentCenterY

local myCircle = display.newCircle( display.contentCenterX, display.contentCenterY, 30 )
myCircle:setFillColor( 8/255, 196/255, 208/255 )
myCircle.alpha = 0.3
myCircle.myName = "shield"
physics.addBody(myCircle, "static", { radius = 26 , bounce=0 })

local player = display.newCircle(display.contentCenterX, display.contentCenterY, 8)
player:setFillColor(1, 1, 1)
physics.addBody(player, "kinematic", {radius = 8, bounce = 0})


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

local trans
local function followTap(event)
    local background = event.target
    local phase = event.phase
    --[[     if(trans)then
          transition.cancel(trans)
        end ]]
    if ("began" == phase) then
        player:setLinearVelocity(event.x -player.x, event.y-player.y)
    elseif ("ended" == phase or "cancelled" == phase) then
        player:setLinearVelocity(0,0)
    end
    --trans = transition.to(player,{time=200,x=event.x,y=event.y})  -- move to touch position
    return true
end
background:addEventListener("touch", followTap)

local function hasCollidedCircle( obj1, obj2 )

    if ( obj1 == nil ) then  -- Make sure the first object exists
        return false
    end
    if ( obj2 == nil ) then  -- Make sure the other object exists
        return false
    end

    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y

    local distance = math.sqrt( dx*dx + dy*dy )
    local objectSize = (obj2.contentWidth/2) + (obj1.contentWidth/2)

    if ( distance < objectSize ) then
        return true
    end
    return false
end

local function createGem()
    local gem = display.newImageRect("gem04purple.png", 40, 40)
    table.insert(gemTable, gem)
    physics.addBody(gem, "dynamic", { radius=12, bounce=0 } )
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
    gem:applyTorque( math.random( -3,3 ) )
end

local function gameLoop()
    createGem()
    if (hasCollidedCircle(myCircle, player) == true) then
        if (isAtHome == false) then
            isAtHome = true;
            print("Player + shield")
        end
    else
        isAtHome = false;
    end
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

local function onCollision( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "shield" and obj2.myName == "gem" ) or
                ( obj1.myName == "gem" and obj2.myName == "shield" ) )
        then
            if (obj1.myName == "shield" and obj2.myName == "gem")
            then
                display.remove(obj2)
                for i = #gemTable, 1, -1 do
                    if ( gemTable[i] == obj2 ) then
                        table.remove( gemTable, i )
                        break
                    end
                end
            end
            if (obj1.myName == "gem" and obj2.myName == "shield")
            then
                display.remove(obj1)
                for i = #gemTable, 1, -1 do
                    if ( gemTable[i] == obj1 ) then
                        table.remove( gemTable, i )
                        break
                    end
                end
            end
        end
    end
end

Runtime:addEventListener( "collision", onCollision )