-- drift - dust motes in flight
-- 
-- v0.0.1 @echophon
--
-- KEY2 randomizes


engine.name = 'PolyPerc'

local viewport   = { width = 128, height = 64 }
local frame = 0

local drift_amount = 2
local connect_distance = 24
local dot_count = 8
local dots  = {{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}
            ,{x=0,y=0,move_x=0,move_y=0,dirty={0,0,0,0,0,0,0,0}}}


function init() 
    randomize_dots()
end

function key(id,state)
    if id == 2 and state == 1 then
      randomize_dots()
    end
end

function randomize_dots()
    for i=1,dot_count do
        dots[i].x = math.random(viewport.width)
        dots[i].y = math.random(viewport.height)
        dots[i].move_x = (1.0 - math.random()) * drift_amount
        dots[i].move_y = (1.0 - math.random()) * drift_amount
    end
end





function draw_dots()
    for i=1, dot_count do
        draw_circle(dots[i].x, dots[i].y,1,13)
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


function redraw()
    screen.clear()
    draw_dots()
    draw_connections()
    play()
    screen.update()
end

re = metro.init()
re.time = 0.1
re.event = function()
    frame = frame + 1
    move_dots()

    redraw()
end
re:start()
