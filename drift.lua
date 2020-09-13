-- drift - dust motes in flight
-- 
-- v0.4 @echophon
--
-- KEY1 shift
-- KEY2 cycles param focus
-- KEY3 cycles focus
-- ENC1 transpose
-- ENC2 param 1
-- ENC3 param 2
-- shift + KEY2 randomizes all
-- shift + KEY3 randomizes focus


engine.name = 'PolyPerc'

local viewport   = { width = 128, height = 64 }
local frame = 0

local txt = 'hello'
local drift_max = 4
local connect_distance = 24
local focus = 1
local param_focus = 1
local param_count = 7
local param_txt = {"move", "pos", "xboundary", "yboundary", "connect distance", "boundary", "random"}
local shift = false
local dot_count = 8
local boundary_ops = 1
local boundary_count = 4
local boundary_txt = {"wrap", "wrap random", "bounce", "bounce random"}
local random_ops = 1
local random_count = 10
local random_txt = {"default", "xpos", "ypos", "xypos", "xmove", "ymove", "xymove", "xboundary", "yboundary", "xyboundary"}

local dots= {{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,x1_bound=1,x2_bound=viewport.width,y1_bound=1,y2_bound=viewport.height,dirty={0,0,0,0,0,0,0,0}}}

local useMidi    = 0
local channel    = 1
local m          = midi.connect()

params:add_number("useMidi","useMidi",0,1,0)
params:set_action("useMidi", function(x) useMidi = x end)

params:add_number("channel","channel",1,16,1)
params:set_action("channel", function(x) channel = x end)

params:add_number("drift_max","drift_max",1,40,12)
params:set_action("drift_max", function(x) drift_max = x end)

params:add_number("connect_distance","connect_distance",4,48,24)
params:set_action("connect_distance", function(x) connect_distance = x end)

params:add_option("boundary_ops","boundary_ops",{"wrap", "wrap random", "bounce", "bounce random"},1)
params:set_action("boundary_ops", function(x) boundary_ops = x end)

params:add_option("random_ops","random_ops",{"default", "xpos", "ypos", "xypos", "xmove", "ymove", "xymove", "xboundary", "yboundary", "xyboundary"},1)
params:set_action("random_ops", function(x) random_ops = x end)

params:add_trigger("randomize", "randomize")
params:set_action("randomize", function(x) randomize_dots() end)

params:add_trigger("reset", "reset")
params:set_action("reset", function(x) reset() end)

function init() 
    randomize_dots()
end

function key(id,state)
    if id == 1 then
        shift = not shift
    elseif id == 2 and state == 1 and shift == true then
        randomize_dots()
    elseif id == 3 and state == 1 and shift == true then
        randomize_dot()
    elseif id == 3 and state == 1 then
        focus = 1+(focus%dot_count)
    elseif id == 2 and state == 1 then
        param_focus = 1+(param_focus%param_count)
    end
end

function enc(id,delta)
    if id == 2 and param_focus == 1 then
      dots[focus].move_x = tonumber(string.format("%.2f", util.clamp(dots[focus].move_x + (delta*0.01),-drift_max,drift_max)))
    elseif id == 3 and param_focus == 1 then
      dots[focus].move_y = tonumber(string.format("%.2f", util.clamp(dots[focus].move_y + (delta*0.01),-drift_max,drift_max)))
    elseif id == 2 and param_focus == 2 then
      dots[focus].x = tonumber(string.format("%.1f", util.clamp(dots[focus].x + (delta*1),0,viewport.width)))
    elseif id == 3 and param_focus == 2 then
        dots[focus].y = tonumber(string.format("%.1f", util.clamp(dots[focus].y + (delta*1),0,viewport.height)))

    elseif id == 2 and param_focus == 3 then
        dots[focus].x1_bound = tonumber(string.format("%.1f", util.clamp(dots[focus].x1_bound + (delta*1),0,dots[focus].x2_bound)))
    elseif id == 3 and param_focus == 3 then
        dots[focus].x2_bound = tonumber(string.format("%.1f", util.clamp(dots[focus].x2_bound + (delta*1),dots[focus].x1_bound,viewport.width)))
    
    elseif id == 2 and param_focus == 4 then
        dots[focus].y1_bound = tonumber(string.format("%.1f", util.clamp(dots[focus].y1_bound + (delta*1),0,dots[focus].y2_bound)))
    elseif id == 3 and param_focus == 4 then
        dots[focus].y2_bound = tonumber(string.format("%.1f", util.clamp(dots[focus].y2_bound + (delta*1),dots[focus].y1_bound,viewport.height)))

    elseif id == 2 and param_focus == 5 then
        connect_distance = tonumber(string.format("%.1f", util.clamp(connect_distance + (delta*0.1),1,48)))
    elseif id == 2 and param_focus == 6 then
        boundary_ops = util.clamp(boundary_ops + (delta*1),1,boundary_count)
    elseif id == 2 and param_focus == 7 then
        random_ops = util.clamp(random_ops + (delta*1),1,random_count)

    elseif id == 1 then
      for i=1,dot_count do
        dots[i].x = tonumber(string.format("%.0f", util.clamp(dots[i].x + (delta*1),-20,viewport.width)))
      end
    end
end

function drift_calc()
    return (0.5 - (math.random(100)* 0.01) ) * drift_max
end

function reset()
    for i=1,dot_count do
        dots[i].move_x = 0
        dots[i].move_y = 0
        dots[i].y = viewport.height/2
        dots[i].x = ((viewport.width/8)*i)-8
    end
end

function randomize_dot()
    if random_ops == 1 then
        dots[focus].x = math.random(viewport.width)
        dots[focus].y = math.random(viewport.height)
        dots[focus].move_x = 0
        dots[focus].move_y = drift_calc()
    elseif random_ops == 2 then
        dots[focus].x = math.random(viewport.width)
    elseif random_ops == 3 then
        dots[focus].y = math.random(viewport.height)
    elseif random_ops == 4 then
        dots[focus].x = math.random(viewport.width)
        dots[focus].y = math.random(viewport.height)
    elseif random_ops == 5 then
        dots[focus].move_x = drift_calc()
    elseif random_ops == 6 then
        dots[focus].move_y = drift_calc()
    elseif random_ops == 7 then
        dots[focus].move_x = drift_calc()
        dots[focus].move_y = drift_calc()
    elseif random_ops == 8 then
        dots[focus].x1_bound = math.random(viewport.width)
        dots[focus].x2_bound = math.random(dots[focus].x1_bound, viewport.width)
    elseif random_ops == 9 then
        dots[focus].y1_bound = math.random(viewport.height)
        dots[focus].y2_bound = math.random(dots[focus].y1_bound, viewport.height)
    elseif random_ops == 10 then
        dots[focus].x1_bound = math.random(viewport.width)
        dots[focus].x2_bound = math.random(dots[focus].x1_bound, viewport.width)
        dots[focus].y1_bound = math.random(viewport.height)
        dots[focus].y2_bound = math.random(dots[focus].y1_bound, viewport.height)
    end
end

function randomize_dots()
    for i=1,dot_count do
        if random_ops == 1 then
            dots[i].x = math.random(viewport.width)
            dots[i].y = math.random(viewport.height)
            dots[i].move_x = 0
            dots[i].move_y = drift_calc()
        elseif random_ops == 2 then
            dots[i].x = math.random(viewport.width)
        elseif random_ops == 3 then
            dots[i].y = math.random(viewport.height)
        elseif random_ops == 4 then
            dots[i].x = math.random(viewport.width)
            dots[i].y = math.random(viewport.height)
        elseif random_ops == 5 then
            dots[i].move_x = drift_calc()
        elseif random_ops == 6 then
            dots[i].move_y = drift_calc()
        elseif random_ops == 7 then
            dots[i].move_x = drift_calc()
            dots[i].move_y = drift_calc()
        elseif random_ops == 8 then
            dots[i].x1_bound = math.random(viewport.width)
            dots[i].x2_bound = math.random(dots[i].x1_bound, viewport.width)
        elseif random_ops == 9 then
            dots[i].y1_bound = math.random(viewport.height)
            dots[i].y2_bound = math.random(dots[i].y1_bound, viewport.height)
        elseif random_ops == 10 then
            dots[i].x1_bound = math.random(viewport.width)
            dots[i].x2_bound = math.random(dots[i].x1_bound, viewport.width)
            dots[i].y1_bound = math.random(viewport.height)
            dots[i].y2_bound = math.random(dots[i].y1_bound, viewport.height)
        end
    end
end

function move_dots()
    for i=1, dot_count do
        dots[i].x = (dots[i].x + dots[i].move_x) 
        dots[i].y = (dots[i].y + dots[i].move_y) 
    end
end


function move_dots_wrap()
    for i=1, dot_count do

        if dots[i].x > viewport.width or dots[i].x > dots[i].x2_bound then
            dots[i].x = dots[i].x1_bound
        end
        if dots[i].y > viewport.height or dots[i].y > dots[i].y2_bound then
            dots[i].y = dots[i].y1_bound
        end
        if dots[i].x < 0 or dots[i].x < dots[i].x1_bound then
            dots[i].x = dots[i].x2_bound
        end
        if dots[i].y < 0 or dots[i].y < dots[i].y1_bound then
            dots[i].y = dots[i].y2_bound
        end
    end
end

-- TODO no longer needed
function move_dots_wrap_perc(n,m)
    for i=1, dot_count do
        if dots[i].x > viewport.width then 
            dots[i].x = ((viewport.width*n) + dots[i].move_x)
        end
        if dots[i].y > viewport.height then 
            dots[i].y = ((viewport.height*m) + dots[i].move_y)
        end
        if dots[i].x < 0 then
            dots[i].x = ((viewport.width*n) + dots[i].move_x)
        end
        if dots[i].y < 0 then
            dots[i].y = ((viewport.height*m) + dots[i].move_y)
        end
    end
end

function move_dots_bounce()
    for i=1, dot_count do
        if dots[i].x < dots[i].x1_bound then
            dots[i].x = dots[i].x1_bound 
            dots[i].move_x = -dots[i].move_x
        end
        if dots[i].x > dots[i].x2_bound then
            dots[i].x = dots[i].x2_bound 
            dots[i].move_x = -dots[i].move_x
        end
        if dots[i].y < dots[i].y1_bound then
            dots[i].y = dots[i].y1_bound 
            dots[i].move_y = -dots[i].move_y
        end
        if dots[i].y > dots[i].y2_bound then
            dots[i].y = dots[i].y2_bound 
            dots[i].move_y = -dots[i].move_y
        end
    end
end

function move_dots_random()
    for i=1, dot_count do
        if dots[i].x < dots[i].x1_bound or dots[i].x > dots[i].x2_bound then
            dots[i].x = math.random(dots[i].x1_bound,dots[i].x1_bound)
        end
        if dots[i].y < dots[i].y1_bound or dots[i].y > dots[i].y2_bound then
            dots[i].y = math.random(dots[i].y1_bound,dots[i].y2_bound)
        end
    end
end

function move_dots_random_bounce()
    for i=1, dot_count do
        if dots[i].x < dots[i].x1_bound or dots[i].x > dots[i].x2_bound then
            dots[i].x = math.random(dots[i].x1_bound,dots[i].x2_bound)
            dots[i].move_x = -dots[i].move_x
        end
        if dots[i].y < dots[i].y1_bound or dots[i].y > dots[i].y2_bound then
            dots[i].y = math.random(dots[i].y1_bound,dots[i].y2_bound)
            dots[i].move_y = -dots[i].move_y
        end
    end
end

function distance( x1, y1, x2, y2 )
	return math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
end

function midi_to_hz(note)
    local hz = (440 / 32) * (2 ^ ((note - 9) / 12))
    return hz
  end

function play()
    for i=1, dot_count do
        for j=1, dot_count do
            if distance(dots[i].x, dots[i].y, dots[j].x, dots[j].y) < connect_distance and dots[j].dirty[i] == 0 then
                engine.hz(midi_to_hz( util.clamp(dots[j].x,10,viewport.width)))
                engine.cutoff( util.clamp(dots[j].y,2,viewport.height)*20)
                dots[j].dirty[i]=1
            end
            if distance(dots[i].x, dots[i].y, dots[j].x, dots[j].y) > connect_distance and dots[j].dirty[i] == 1 then
                dots[j].dirty[i]=0
            end       
        end
    end            
end

function play_midi()
    for i=1, dot_count do
        for j=1, dot_count do
            if distance(dots[i].x, dots[i].y, dots[j].x, dots[j].y) < connect_distance and dots[j].dirty[i] == 0 then
                dots[j].note = math.floor(dots[j].x)
                m:note_on(dots[j].note,math.floor(dots[j].y),channel)
                dots[j].dirty[i]=1
            end
            if distance(dots[i].x, dots[i].y, dots[j].x, dots[j].y) > connect_distance and dots[j].dirty[i] == 1 then
                m:note_off(dots[j].note,0,channel)
                dots[j].dirty[i]=0
            end       
        end
    end            
end

function draw_dots()
    for i=1, dot_count do
        if i == focus then
            draw_circle(dots[i].x, dots[i].y,2,13)
        else
            draw_circle(dots[i].x, dots[i].y,1,5)
        end
    end
end

function draw_connections()
    for i=1, dot_count do
        for j=1, dot_count do
            if distance(dots[i].x, dots[i].y, dots[j].x, dots[j].y) < connect_distance then
                draw_line(dots[i].x, dots[i].y, dots[j].x, dots[j].y, 13)
            end     
        end
    end            
end

function draw_circle(x, y, r, l)
    screen.level(l)
    screen.circle(x,y,r)
    screen.stroke()
end

function draw_line(x1, y1, x2, y2, l)
    screen.level(l)
    screen.move(x1,y1)
    screen.line(x2,y2)
    screen.stroke()
end

function draw_bounds()
    screen.level(1)
    screen.rect(dots[focus].x1_bound, dots[focus].y1_bound, dots[focus].x2_bound - dots[focus].x1_bound, dots[focus].y2_bound - dots[focus].y1_bound)
    screen.stroke()
  end

function draw_text()
    if param_focus == 1 then
        txt = param_txt[param_focus] .. focus .. ":" .. string.format("%.2f",dots[focus].move_x) .. "," .. string.format("%.2f",dots[focus].move_y)
    elseif param_focus == 2 then
        txt = param_txt[param_focus] .. focus .. ":" .. string.format("%.2f",dots[focus].x) .. "," .. string.format("%.2f",dots[focus].y)
    elseif param_focus == 3 then
        txt = param_txt[param_focus] .. focus .. ":" .. string.format("%.1f",dots[focus].x1_bound) .. "," .. string.format("%.1f",dots[focus].x2_bound)
    elseif param_focus == 4 then
        txt = param_txt[param_focus] .. focus .. ":" .. string.format("%.1f",dots[focus].y1_bound) .. "," .. string.format("%.1f",dots[focus].y2_bound)
    elseif param_focus == 5 then
        txt = param_txt[param_focus] ..  ":" .. string.format("%.1f",connect_distance) 
    elseif param_focus == 6 then
        txt = param_txt[param_focus] ..  ":" .. boundary_txt[boundary_ops] 
    elseif param_focus == 7 then
        txt = param_txt[param_focus] ..  ":" .. random_txt[random_ops] 
    end
    screen.level(1)
    screen.move(2,6)
    screen.text(txt)
    screen.stroke()
end

function redraw()
    screen.clear()
    draw_bounds()
    draw_dots()
    draw_connections()
    draw_text()

    screen.update()
end

re = metro.init()
re.time = 0.1
re.event = function()
    frame = frame + 1
    move_dots()
    if boundary_ops == 1 then
        move_dots_wrap()
    elseif boundary_ops == 2 then
        move_dots_random()
    elseif boundary_ops == 3 then
        move_dots_bounce()
    elseif boundary_ops == 4 then
        move_dots_random_bounce()
    end

    if useMidi == 1 then
        play_midi()
    else
        play()
    end

    redraw()
end
re:start()
