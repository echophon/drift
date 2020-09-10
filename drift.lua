-- drift - dust motes in flight
-- 
-- v0.1.0 @echophon
--
-- KEY2 randomizes
-- KEY3 cycles focus
-- ENC1 transpose
-- ENC2 motivate x-axis
-- ENC3 motivate y-axis


engine.name = 'PolyPerc'

local viewport   = { width = 128, height = 64 }
local frame = 0

local txt = 'hello'
local drift_amount = 4
local connect_distance = 24
local focus = 1
local dot_count = 8
local dots  = {{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}}

local useMidi    = 0
local channel    = 1
local m          = midi.connect()

params:add_number("useMidi","useMidi",0,1,0)
params:set_action("useMidi", function(x) useMidi = x end)

params:add_number("channel","channel",1,16,1)
params:set_action("channel", function(x) channel = x end)

params:add_number("drift_amount","drift_amount",1,20,12)
params:set_action("drift_amount", function(x) drift_amount = x end)

params:add_number("connect_distance","connect_distance",4,48,24)
params:set_action("connect_distance", function(x) connect_distance = x end)

function init() 
    randomize_dots()
end

function key(id,state)
    if id == 2 and state == 1 then
        randomize_dots()
        -- stop_dots()
    elseif id == 3 and state == 1 then
        focus = 1+(focus%dot_count)
    end
end

function enc(id,delta)
    if id == 2 then
      dots[focus].move_x = tonumber(string.format("%.2f", util.clamp(dots[focus].move_x + (delta*0.01),-drift_amount,drift_amount)))
    elseif id == 3 then
      dots[focus].move_y = tonumber(string.format("%.2f", util.clamp(dots[focus].move_y + (delta*0.01),-drift_amount,drift_amount)))
    elseif id == 1 then
      for i=1,dot_count do
        dots[i].x = tonumber(string.format("%.0f", util.clamp(dots[i].x + (delta*1),-1,viewport.width)))
      end
    end
    txt = dots[focus].move_x .. "," .. dots[focus].move_y
end

function randomize_dots()
    for i=1,dot_count do
        dots[i].x = math.random(viewport.width)
        dots[i].y = math.random(viewport.height)
        -- dots[i].move_x = (0.5 - math.random()) * drift_amount
        dots[i].move_x = 0
        dots[i].move_y = (1 - (math.random(100)* 0.01) ) * drift_amount
    end
end

function stop_dots()
    for i=1,dot_count do
        -- dots[i].x = viewport.width/2
        -- dots[i].y = viewport.height/2
        dots[i].move_x = 0
        dots[i].move_y = 0
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

function draw_text()
    screen.level(1)
    screen.move(2,6)
    screen.text(txt)
    screen.stroke()
  end

function move_dots()
    for i=1, dot_count do
        dots[i].x = (dots[i].x + dots[i].move_x) % viewport.width
        dots[i].y = (dots[i].y + dots[i].move_y) % viewport.height
        if dots[i].x < 0 then
            dots[i].x = viewport.width
        end
        if dots[i].y < 0 then
            dots[i].y = viewport.height
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


function redraw()
    screen.clear()
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
    if useMidi == 1 then
        play_midi()
    else
        play()
    end

    redraw()
end
re:start()
