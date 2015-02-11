local lg = love.graphics

local td = {}
local font = lg.newFont(20)

local colors = {}
colors.bg = {225,225,255}
colors.text = {255,255,255}
colors.border = {125,125,200}
colors.circInd = {255,255,0}
colors.arrow = {255,0,0}

function td.drawCenterText(text)
    local text = text or "Default text"
    lg.setFont(font)
    lg.setColor(colors.text[1],colors.text[2],colors.text[3],255*tut.pulse)
    local y = lg:getHeight() - font:getHeight(text) - 10
    local x = (lg:getWidth()/2) - (font:getWidth(text) /2)
    lg.print(text,x,y)
end

function td.circleIndicator(x,y,size,text)
    lg.setColor(colors.circInd)
    lg.setFont(font)
    lg.circle("line", x,y,size*tut.pulse,40)
    lg.circle("line", x,y,size*0.9,40)
    local y = y - size - font:getHeight(text) - 10
    local x = x - (font:getWidth(text) /2)
    lg.print(text,x,y)
end

function td.arrowIndicator(x,y,h,w,bounce,up)
    lg.setColor(colors.arrow)
    if up then y = y+(bounce*tut.pulse) else y = y-(bounce*tut.pulse) end
    local verts = {x-(w/2),y-h,x+(w/2),y-h,x,y}
    if up then verts = {x-(w/2),y+h,x+(w/2),y+h,x,y} end
    lg.polygon("fill",verts)
end


return td
