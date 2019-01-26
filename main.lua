-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

--[[ local background = display.newCircle(display.contentCenterX, display.contentCenterY, 500)
background:setFillColor(0,5, 0,6, 0,6) ]]


local gemTable = {}
local gemCarried = {}

local isAtHome = false;
local factor = 0;

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local background = display.newImageRect("assets/img/space-1.png", 500, 600)
background.x = display.contentCenterX
background.y = display.contentCenterY

local myCircle = display.newCircle( display.contentCenterX, display.contentCenterY, 30 )
myCircle:setFillColor( 8/255, 196/255, 208/255 )
myCircle.alpha = 0.3
myCircle.myName = "shield"
physics.addBody(myCircle, "static", { radius = physicsRadius , bounce=0 })

local player = display.newCircle(display.contentCenterX, display.contentCenterY, 8)
player:setFillColor(1, 1, 1)
physics.addBody(player, "kinematic", {radius = 8, bounce = 0})
player.myName = "player"
player.gemNbr = 0

-- Music & Sounds --

-- Get a gem
local getGem = audio.loadSound("assets/effects/get_gem.wav");
-- When gems are carried to the safe zone
local dropGem = audio.loadSound("assets/effects/drop_gem.wav");
-- When the player hits an asteroïd
local hit;
-- Menu
local menuMusic;
-- Pause
local pauseMusic;


-- Function that decrease the shield zone by a factor
local function decreaseShield()
    factor = -3 * player.gemNbr;
    myCircle.path.radius = myCircle.path.radius + factor
end

-- Function that increase the shield zone by a factor
local function inscreaseShield()
    factor = 3 * player.gemNbr;
    myCircle.path.radius = myCircle.path.radius + factor
    physics.removeBody(myCircle) 
    physics.addBody(myCircle, "static", { radius = (myCircle.path.radius - 4) , bounce=0 })
end

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
    local gem = display.newImageRect("assets/img/gem04purple.png", 40, 40)
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
    if (hasCollidedCircle(myCircle, player) == true) then            
        if ((isAtHome == false) and (player.gemNbr ~= 0)) then
            audio.play(dropGem)
            inscreaseShield()
            isAtHome = true
            player.gemNbr = 0
        end 
        for i = #gemTable, 1, -1 do
            table.remove(gemCarried, i)
        end 
    else
        isAtHome = false
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
gameLoopTimer = timer.performWithDelay( 1, gameLoop, 0 )

local function onCollision( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        print(obj1.myName, obj2.myName)
        
        
        -- Check collision between Player & gems
        if ( (obj1.myName == "player" and obj2.myName == "gem") or (obj1.myName == "gem" and obj2.myName == "player")) then
            if (obj1.myName == "player") then
                display.remove(obj2)
                for i = #gemTable, 1, -1 do
                    if (gemTable[i] == obj2) then
                        audio.play(getGem)
                        player.gemNbr = player.gemNbr + 1 
                        table.insert(gemCarried, obj2)
                        table.remove(gemTable, i)
                        break
                    end
                end
            end
            else if (obj2.myName == "player") then
                display.remove(obj1)
                for i = #gemTable, 1, -1 do
                    if (gemTable[i] == obj1) then
                        audio.play(getGem)
                        player.gemNbr = player.gemNbr + 1                                              
                        table.insert(gemCarried, obj1)                        
                        table.remove(gemTable, i)
                        break
                    end
                end
            end
            print(#gemCarried)
        end

        -- Check collision between Player & shield        
        if ((obj1.myName == "player" and obj2.myName == "shield") or (obj1.myName == "shield" and obj2.myName == "player")) then
            audio.play(dropGem)
            player.gemCarried = 0            
            print(player.gemCarried)
        end

        -- Check collision between Shield & gems        
        if ((obj1.myName == "shield" and obj2.myName == "gem") or
                (obj1.myName == "gem" and obj2.myName == "shield"))
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

local function listener( event )
    createGem()
end

timer.performWithDelay(500, listener, -1)