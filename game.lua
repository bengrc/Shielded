
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoMenu()
    composer.gotoScene( "menu" )
end
    

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local gemTable = {}
local astTable = {}
local gemCarried = {}
local isAtHome = false;
local factor = 0
local lives = 3

-- Background --

local background = display.newImageRect("assets/img/stars-background.png", 500, 600)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Shield --

local myCircle = display.newCircle( display.contentCenterX, display.contentCenterY, 30 )
myCircle:setFillColor( 8/255, 196/255, 208/255 )
myCircle:setStrokeColor(8/255, 196/255, 208/255)
myCircle.strokeWidth = 4
myCircle.stroke.effect = "filter.brightness"
myCircle.stroke.effect.intensity = 1
myCircle.myName = "shield"

myCircle.alpha = 0.8
physics.addBody(myCircle, "static", {radius=26, bounce=0})


-- Player --

local player = display.newCircle(display.contentCenterX, display.contentCenterY, 8)
player:setFillColor(1, 1, 1)
physics.addBody(player, "kinematic", {radius = 8, bounce= 0})
player.myName = "player"
player.gemNbr = 0

-- UI
local nbLives = display.newText(lives, 10, 10, native.systemFont, 10)
nbLives:setFillColor(1, 1, 1)

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

--local trans
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

local function createAst()
	local ast = display.newImageRect("assets/img/gem06green.png", 40, 40)
	table.insert(astTable, ast)
	physics.addBody(ast, "dynamic", {radius=12, bounce=0})
	ast.myName = "ast"
	
	local whereFrom = math.random(4)
    if ( whereFrom == 3 ) then
        -- From the left
        ast.x = -60
        ast.y = math.random( 500 )
        ast:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 4 ) then
        -- From the top
        ast.x = math.random( display.contentWidth )
        ast.y = -60
        ast:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 2 ) then
        -- From the right
        ast.x = display.contentWidth + 60
        ast.y = math.random( 500 )
        ast:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    elseif (whereFrom == 1) then
        ast.x = math.random(display.contentWidth)
        ast.y = -60
    end
    ast:applyTorque( math.random( -3,3 ) )
end

local function gemListener( event )
    createGem()
end

local function astListener( event )
    createAst()
end

local function gameLoop()
--[[     if (hasCollidedCircle(myCircle, player) == true) then
        if (isAtHome == false) then
            isAtHome = true;
            print("Player + shield")
        end
    else
        isAtHome = false; ]]
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
    for i = #astTable, 1, -1 do
		local thisAst = astTable[i]
		if ( thisAst.x < -100 or
			thisAst.x > display.contentWidth + 100 or
			thisAst.y < -100 or
			thisAst.y > display.contentHeight + 100 )
		then
			display.remove(thisAst)
			table.remove(astTable, i)
		end
	end
end

local function onCollision( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        -- Collision: Players and Gems
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

        -- Collision : shield and gems
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

        -- Collision : Player and Asteroids
		if ( ( obj1.myName == "player" and obj2.myName == "ast" ) or
                ( obj1.myName == "ast" and obj2.myName == "player" ) )
        then
            if (obj1.myName == "player" and obj2.myName == "ast")
            then
                display.remove(obj2)
                for i = #astTable, 1, -1 do
                    if ( astTable[i] == obj2 ) then
                        table.remove( astTable, i )
                        break
                    end
                end
            end
            if (obj1.myName == "ast" and obj2.myName == "player")
            then
                display.remove(obj1)
                for i = #astTable, 1, -1 do
                    if ( astTable[i] == obj1 ) then
                        table.remove( astTable, i )
                        break
                    end
                end
            end
            lives = lives -1
            nbLives.text = lives
        end

        -- Collision : shield and asteroids
		if ( ( obj1.myName == "shield" and obj2.myName == "ast" ) or
                ( obj1.myName == "ast" and obj2.myName == "shield" ) )
        then
            if (obj1.myName == "shield" and obj2.myName == "ast")
            then
                display.remove(obj2)
                for i = #astTable, 1, -1 do
                    if ( astTable[i] == obj2 ) then
                        table.remove( astTable, i )
                        break
                    end
                end
            end
            if (obj1.myName == "ast" and obj2.myName == "shield")
            then
                display.remove(obj1)
                for i = #astTable, 1, -1 do
                    if ( astTable[i] == obj1 ) then
                        table.remove( astTable, i )
                        break
                    end
                end
            end
        end        
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
    physics.pause()  -- Temporarily pause the physics engine
    -- Set up display groups
    backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
     
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
     
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

    local background = display.newImageRect(backGroup, "assets/img/stars-background.png", 500, 600)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    local myCircle = display.newCircle(mainGroup, display.contentCenterX, display.contentCenterY, 30 )
    --myCircle:setFillColor( 8/255, 196/255, 208/255 )
    myCircle:setStrokeColor(8/255, 196/255, 208/255)
    myCircle.strokeWidth = 8
    myCircle.alpha = 0.4
    
    local player = display.newCircle(mainGroup, display.contentCenterX, display.contentCenterY, 8)
    player:setFillColor(1, 1, 1)
    physics.addBody(player, "dynamic", {radius = 8, bounce= 0})

    background:addEventListener( "touch", dragPlayer )
    background:addEventListener("touch", followTap)
    timer.performWithDelay(500, gemListener, -1)
    timer.performWithDelay(500, astListener, -1)    
    Runtime:addEventListener( "collision", onCollision )

end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        physics.start()
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )


	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel(gameLoopTimer)

	elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        physics.pause()

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
