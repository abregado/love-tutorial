local gs = require('hump-master/gamestate')
local lg = love.graphics
local td = require('tutorial_draw')
local tw = require('tween')

local t = {}
local defaultID = 1
local slides = {}
local pos = {x=0,y=0}
t.initialized = false
t.pulse = 1

t.tween = tw.new(1,t,{pulse=0.8},'outQuad')
--trigger func if 1 then set to 2 and prepare nextID to 0

--prepare func--if >1 then set to 0

--draw func--print name to screen

--1st level constructor (tutID, initial state/defaults to 2, nexttutID, "name descriptor")

function t.newBaseSlide(ID, nextID, desc, autoDisplay, draws)

    
    o={}
    
    --set unique ID string
    local unique = true
    for i,v in ipairs(slides) do
        if v.ID == ID then unique = false end
    end
    if unique then
        o.ID = ID
    else   
        o.ID = "Default"..tostring(defaultID)
        defaultID = defaultID+1
    end
    
    o.nextID = nextID or nil
    o.state = 2
    o.desc = desc or "Default Tutorial Slide"
    o.auto = autoDisplay
    o.draw = draws or td.drawCenterText
    
    
    return o
end

function t.resetTutorials()
    for i,v in ipairs(slides) do
        v.state = 2
    end
end

function t.addSlide(ID, nextID, desc, autoDisplay, draws)
    local newSlide = t.newBaseSlide(ID, nextID, desc, autoDisplay, draws)
    table.insert(slides, newSlide)
end

local function getSlide(ID)
    for i,v in ipairs(slides) do
        if v.ID == ID then return v end
    end
    return nil
end

local function checkActive()
    local result = false
    for i,v in ipairs(slides) do
        if v.state == 1 then
            result = true
        end
    end
    return result
end

function t.draw()
    if DEBUG_MODE then
        local y = 0
        for i,v in ipairs(slides) do
            if v.state == 0 then lg.setColor(0,0,255)
            elseif v.state == 1 then lg.setColor(0,255,0)
            else lg.setColor(255,0,0) end
            lg.print(v.desc, pos.x,pos.y+y)
            y = y + 20
        end
    end
    lg.setColor(255,255,255)
    for i,v in ipairs(slides) do
        if v.state == 1 then v:draw() end
    end
    if t.initialized then lg.circle("fill",600,20,20,20) end
end

function t.prepare(ID)
    
    local v = getSlide(ID)
    if v.state > 1 then 
        v.state = 0 
        if v.auto then
            t.display(ID)
        end
        return true
    end
    return false
end

function t.display(ID)
    if not checkActive() then
        local v = getSlide(ID)
        if v.state == 0 then v.state = 1 return true end
    end
    return false
end

function t.complete(ID)
    local v = getSlide(ID)
    if v.state == 1 then
        v.state = 2
        if v.nextID then t.prepare(v.nextID) end
        return true 
    end
    return false
end

function t.update(dt)
    
    local complete = t.tween:update(dt)
    if complete and t.pulse == 0.8 then
        t.tween = tw.new(1,t,{pulse=1},'inQuad')
    elseif complete and t.pulse == 1 then
        t.tween = tw.new(1,t,{pulse=0.8},'outQuad')
    end
end


t.td = {}
local font = lg.newFont(20)

local colors = {}
colors.bg = {30,30,30}
colors.text = {0,255,0}
colors.border = {60,225,60}
colors.circInd = {255,255,0}
colors.arrow = {255,0,0}

fontFile = nil


--prints text centered at the given x/y
function t.td.drawCenterText(text,x,y)
    local text = text or "Default text"
    local x = x or lg:getWidth()/2
    local y = y or lg:getHeight()/10*9
    lg.setFont(font)
    lg.setColor(colors.text[1],colors.text[2],colors.text[3],255*t.pulse)
    y = y - (font:getHeight(text) /2)
    x = x - (font:getWidth(text) /2)
    lg.print(text,x,y)
end

function t.td.circleIndicator(x,y,size,text)
    lg.setColor(colors.circInd)
    lg.setFont(font)
    lg.circle("line", x,y,size*t.pulse,40)
    lg.circle("line", x,y,size*0.9,40)
    local y = y - size - font:getHeight(text) - 10
    local x = x - (font:getWidth(text) /2)
    lg.print(text,x,y)
end

function t.td.arrowIndicator(x,y,h,w,bounce,up)
    lg.setColor(colors.arrow)
    local bmod = (t.pulse-0.8)*5
    if up then y = y+(bounce*bmod) else y = y-(bounce*bmod) end
    local verts = {x-(w/2),y-h,x+(w/2),y-h,x,y}
    if up then verts = {x-(w/2),y+h,x+(w/2),y+h,x,y} end
    lg.polygon("fill",verts)
end




--to set the bubble colors, supply table colorList which includes variables bg and/or text (of type love.Color)
function t.td.setColors(colorList)
    colors.bg = colorList.bg or {30,30,30}
    colors.text = colorList.text or {255,255,255}
    colors.border = colorList.border or {125,125,200}
    colors.circInd = colorList.circInd or {255,255,0}
    colors.arrow = colorList.arrow or {255,0,0}
end

--supply a File object to use a custom ttf font
function t.td.setFont(file)
    fontFile = file
end

--creates a canvas with a rounded rectangle rendered to it
function t.td.roundedRectangle(r,w,h,side,border)
    local bubble = lg.newCanvas()
    lg.setColor(255,255,255)

    local s = {}
    s[1] = {x=r,y=r,w=w-(r*2),h=h-(r*2)}
    s[2] = {x=0,y=r,w=r,h=h-(r*2)}
    s[3] = {x=w-r,y=r,w=r,h=h-(r*2)}
    s[4] = {x=r,y=0,w=w-(r*2),h=r}
    s[5] = {x=r,y=h-r,w=w-(r*2),h=r}

    local c = {}
    c[1] = {x=r,y=r}
    c[2] = {x=w-r,y=r}
    c[3] = {x=r,y=h-r}
    c[4] = {x=w-r,y=h-r}
    
    local edge = h/20
    local black = nil
    local top = nil
    if border then
        local r1,w1,h1 = r-1,w-(edge*2),h-(edge*2)
        black = t.td.roundedRectangle(r1,w1,h1,side)
        r1,w1,h1 = r-1,w1-2,h1-2
        top = t.td.roundedRectangle(r1,w1,h1,side)
    end
        
    
    lg.setCanvas(bubble)
    lg.setColor(colors.bg)
    for i,v in ipairs(s) do
        lg.rectangle("fill",v.x,v.y,v.w,v.h)
    end
    for i,v in ipairs(c) do
        lg.circle("fill",v.x,v.y,r,30)
    end
    
    if border then
        lg.setColor(colors.border)
        for i,v in ipairs(s) do
            lg.rectangle("fill",v.x,v.y,v.w,v.h)
        end
        for i,v in ipairs(c) do
            lg.circle("fill",v.x,v.y,r,30)
        end
        lg.setColor(0,0,0)
        lg.draw(black,edge,edge)
        lg.setColor(255,255,255)
        lg.draw(top,edge+1,edge+1)
    end

    lg.setColor(255,255,255)
    lg.setCanvas()
    return bubble
end

--iterates over font sizes until it finds one that makes the text fit the rectangle
function t.td.adjustFontSize(text,width,maxLines,maxHeight)
    local maxWidth = width*maxLines
    local fontSize = 40
    local font = lg.newFont(fontSize)
    if fontFile then
        font = lg.newFont(fontFile,fontSize)
    end
    local textWidth = font:getWidth(text)
    local _,lines = font:getWrap(text,width)
    local textHeight = lines*font:getHeight()
    
    while textWidth > maxWidth or textHeight > maxHeight do
        fontSize = fontSize -1
        if fontFile then
            font = lg.newFont(fontFile,fontSize)
        else
            font = lg.newFont(fontSize)
        end
        textWidth = font:getWidth(text)
        _,lines = font:getWrap(text,width)
        textHeight = lines*font:getHeight()
        if fontSize == 1 then
            break
        end
    end
    return font
end

function t.td.actionRectangle(w,h)
    local bubble = lg.newCanvas()
    local edge = w/80

    lg.setCanvas(bubble)
    lg.setColor(colors.border)
    lg.rectangle("fill",0,0,w,h)
    lg.setColor(0,0,0)
    lg.rectangle("line",0,0,w,h)
    lg.setColor(colors.bg)
    lg.rectangle("fill",edge,edge,w-(edge*2),h-(edge*2))
    lg.setColor(0,0,0)
    lg.rectangle("line",edge,edge,w-(edge*2),h-(edge*2))
    

    lg.setColor(255,255,255)
    lg.setCanvas()
    return bubble
end

--creates a bubble with actor portrait that fits into the rectangle provided
--r,tw,th (pixels), side ("left","right","center"), text (string), face (image), border (bool)
-- if not face given, bubble will be larger
function t.td.drawBubble(r,tw,th,side,text,face,border)
    local bubble = lg.newCanvas(tw,th)
    lg.setColor(255,255,255)
    
    local h = th*0.6
    local oy = th/3
    if not face then oy = 0 h = th end
    local ox = tw/20
    local w = tw*0.95
    
    if side == "right" then
        ox = 0
    elseif side == "center" then
        ox = 0
        w = tw
    end
    

    local background = t.td.roundedRectangle(r,w,h,side,border)
    lg.setCanvas(bubble)
    lg.draw(background,ox,oy)

    
    
    
    if face then
        lg.setColor(255,255,255)
        local actor = face
        local scale = th/actor:getHeight()
        if side == "left" then
            lg.draw(actor,0,0,0,scale,scale)
        elseif side == "right" then
            lg.draw(actor,tw,0,0,scale*-1,scale)
        end
    end
    
    
    local ml = w/20
    local mr = w/20
    local mt = w/80
    local mb = w/80
    local align = "left"
    local img = th
    
    if side == "right" then
        mr = img
        align = "right"
    elseif side == "left" then
        ml = img
    elseif side == "center" then
        align = "center"
    end
        
    local tx = ml
    local ty = oy+mt
    local txh = h-mt-mb
    local tw = tw-ml-mr
    
    if DEBUG_MODE then lg.setColor(0,255,0) lg.rectangle("line",tx,ty,tw,txh) lg.rectangle("line",0,0,bubble:getWidth(),bubble:getHeight()) end
    
    lg.setFont(t.td.adjustFontSize(text,tw,3,txh))
    lg.setColor(colors.text)
    t.td.centreText(text,tx,ty,tw,txh,"center")
    
    
    lg.setCanvas()
    return bubble
end

function t.td.centreText(text,x,y,w,h,align)
    local font = lg.getFont()
    lg.setColor(colors.text)
    local actualWidth, lines = font:getWrap(text,w)
    local tox = actualWidth/2
    local lh = font:getHeight()/2*lines
    lg.printf(text,x,y+(h/2)-lh,w,align)
end

return t
