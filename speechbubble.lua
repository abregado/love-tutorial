--creates an object that has a pre-rendered canvas
--image of actor/speaker
--speech bubble based on size input
--speech bubble and actor can be left or right mounted
--speechbubble can also be internal monologe (thinking bubble)
--speechbubble can be actorless, centred and Actiony

local sb = {}

local lg = love.graphics
local bubbleFont = lg.newFont(40)

sb.colors = {}
sb.colors.bg = {225,225,255}
sb.colors.text = {0,0,0}
sb.colors.border = {125,125,200}
sb.fontFile = nil

--to set the bubble colors, supply table colorList which includes variables bg and/or text (of type love.Color)
function sb.setColors(colorList)
    sb.colors.bg = colorList.bg or {225,225,255}
    sb.colors.text = colorList.text or {0,0,0}
    sb.colors.border = colorList.border or {125,125,200}
end

--supply a File object to use a custom ttf font
function sb.setFont(file)
    sb.fontFile = file
end

--creates a canvas with a rounded rectangle rendered to it
function sb.roundedRectangle(r,w,h,side,border)
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
        black = sb.roundedRectangle(r1,w1,h1,side)
        r1,w1,h1 = r-1,w1-2,h1-2
        top = sb.roundedRectangle(r1,w1,h1,side)
    end
        
    
    lg.setCanvas(bubble)
    lg.setColor(sb.colors.bg)
    for i,v in ipairs(s) do
        lg.rectangle("fill",v.x,v.y,v.w,v.h)
    end
    for i,v in ipairs(c) do
        lg.circle("fill",v.x,v.y,r,30)
    end
    
    if border then
        lg.setColor(sb.colors.border)
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
function sb.adjustFontSize(text,width,maxLines,maxHeight)
    local maxWidth = width*maxLines
    local fontSize = 40
    local font = lg.newFont(fontSize)
    if sb.fontFile then
        font = lg.newFont(sb.fontFile,fontSize)
    end
    local textWidth = font:getWidth(text)
    local _,lines = font:getWrap(text,width)
    local textHeight = lines*font:getHeight()
    
    while textWidth > maxWidth or textHeight > maxHeight do
        fontSize = fontSize -1
        if sb.fontFile then
            font = lg.newFont(sb.fontFile,fontSize)
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

function sb.actionRectangle(w,h)
    local bubble = lg.newCanvas()
    local edge = w/80

    lg.setCanvas(bubble)
    lg.setColor(sb.colors.border)
    lg.rectangle("fill",0,0,w,h)
    lg.setColor(0,0,0)
    lg.rectangle("line",0,0,w,h)
    lg.setColor(sb.colors.bg)
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
function sb.drawBubble(r,tw,th,side,text,face,border)
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
    

    local background = sb.roundedRectangle(r,w,h,side,border)
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
    
    lg.setFont(sb.adjustFontSize(text,tw,3,txh))
    lg.setColor(sb.colors.text)
    sb.centreText(text,tx,ty,tw,txh,"center")
    
    
    lg.setCanvas()
    return bubble
end

function sb.centreText(text,x,y,w,h,align)
    local font = lg.getFont()
    lg.setColor(sb.colors.text)
    local actualWidth, lines = font:getWrap(text,w)
    local tox = actualWidth/2
    local lh = font:getHeight()/2*lines
    lg.printf(text,x,y+(h/2)-lh,w,align)
end

return sb


