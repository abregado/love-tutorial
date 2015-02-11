DEBUG_MODE = false
gs = require('hump-master/gamestate') 

lg = love.graphics
lm = love.mouse
tut = require('tutorial')
td = tut.td
game = require('state_game')
vl= require('hump-master/vector-light')
local font = lg.newFont()
local tutTimer = 0
local squarePos = {x=0,y=300,speed=100}
local targetPos = {x=300,y=200,r=40}
local bubble = td.drawBubble(20,600,100,"center","Welcome to the tutorial library demo, press A to continue",nil,true)
local mbub = td.drawBubble(5,200,100,"center","This text will follow the mouse until you click the left mouse button",nil,false)
local rap = lg.newImage('raptordude.png')
local rbub = td.drawBubble(40,640,150,"right","Spaceraptor says press any key (except Escape) again",rap,true)


function love.load()
    gs.registerEvents()
    gs.switch(game)
    tut.addSlide("tut1","tut2","1",true,
        function(self) lg.draw(bubble,20,lg.getHeight()-120) end)
    tut.addSlide("tut2","tut3","2",true,
        function(self) td.drawCenterText("Press the B key to continue") end)
    tut.addSlide("tut3","tut4","3",true,
        function(self) td.drawCenterText("Press the C key to continue") end)
    tut.addSlide("tut4","tut5","4",true,
        function(self) td.drawCenterText("Press the left mouse button anywhere in the black area") end)
    tut.addSlide("tut5","tut6","5",true,
        function(self) td.drawCenterText("Press the right mouse button and wait") end)
    tut.addSlide("tut6","tut7","wait",false,
        function(self) td.drawCenterText("Press the right mouse button again") end)
    tut.addSlide("tut7","tut8","7",true,
        function(self) td.drawCenterText("Press any key except 'Escape'") end)
    tut.addSlide("tut8","tut9","8",true,
        function(self) lg.draw(rbub,0,lg.getHeight()-150) end)
    tut.addSlide("tut9","tut10","box1",true,
        function(self) td.drawCenterText("Click inside the box") lg.rectangle("line",100,100,100,100) end)
    tut.addSlide("tut10","tut11","box2",true,
        function(self) td.drawCenterText("Try it with a moving box") lg.rectangle("line",squarePos.x,squarePos.y,100,100) end)
    tut.addSlide("tut11","tut12","circle1",true,
        function(self) td.drawCenterText("Click this target") td.circleIndicator(targetPos.x,targetPos.y,targetPos.r,"dist: "..tostring(math.floor(vl.dist(lm.getX(),lm.getY(),targetPos.x,targetPos.y)))) end)
    tut.addSlide("tut12","tut13","arrow1",true,
        function(self) td.drawCenterText("This is an arrow indicator. Press spacebar") td.arrowIndicator(100,100,30,20,10,false) lg.circle("line",100,100,3,20) end)
    tut.addSlide("tut13","tut2","mousebox",true,
        function(self) lg.draw(mbub,lm.getX(),lm.getY()) end)   

    tut.prepare("tut1")
end

function love.quit()
end


function love.update(dt)
    tutTimer = tutTimer + dt
    if tutTimer > 2 then
        tutTimer = 0
        tut.display("tut6")
    end
    squarePos.x = squarePos.x+(dt*squarePos.speed)
    if squarePos.x>lg:getWidth() then squarePos.x=-100 end
    
    tut.update(dt)
end

function love.draw()
    lg.setFont(font)
    tut.draw()
end

function love.keypressed(key)
    tut.complete("tut8")
    tut.complete("tut7")
    if key == 'a' then
        tut.complete("tut1")
    elseif key == 'b' then
        tut.complete("tut2")
    elseif key == 'c' then
        tut.complete("tut3")
    elseif key == 'escape' then
        tut.resetTutorials()
        tut.prepare("tut1")
    elseif key == ' ' then
        tut.complete("tut12")
    end
    
end

function love.mousepressed(x,y,button)
    if button == 'l' then
        if vl.dist(x,y,targetPos.x,targetPos.y) < targetPos.r then
            tut.complete("tut11")
        end
        if x>squarePos.x and x<(squarePos.x+100) and y>squarePos.y and y<(squarePos.y+100) then
            tut.complete("tut10")
        end
        if x>100 and x<200 and y>100 and y<200 then
            tut.complete("tut9")
        end
        tut.complete("tut13")
        tut.complete("tut4")
        
    elseif button == 'r' then
        tutTimer = 0
        tut.complete("tut6")
        tut.complete("tut5")
    end
end

function love.graphics.ellipse(mode, x, y, a, b, phi, points)
  phi = phi or 0
  points = points or 10
  if points <= 0 then points = 1 end

  local two_pi = math.pi*2
  local angle_shift = two_pi/points
  local theta = 0
  local sin_phi = math.sin(phi)
  local cos_phi = math.cos(phi)

  local coords = {}
  for i = 1, points do
    theta = theta + angle_shift
    coords[2*i-1] = x + a * math.cos(theta) * cos_phi 
                      - b * math.sin(theta) * sin_phi
    coords[2*i] = y + a * math.cos(theta) * sin_phi 
                    + b * math.sin(theta) * cos_phi
  end

  coords[2*points+1] = coords[1]
  coords[2*points+2] = coords[2]

  love.graphics.polygon(mode, coords)
end


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
