function love.load()
    Object = require('classic')
    require('window')
    require('bird')
    require('pipe')
    
    -- window initalization
    W = 400 -- window size
    H = 600
    window = Window(W, H)
    
    -- bird initalization
    birdh = 20
    birdw = 20
    birdY = 300
    
    bird = Bird(birdw, birdh, birdY)
    
    -- pipe initalization 
    -- 2*pipeDist) = W
    gap = 200 -- pipe gap
    pipeY = love.math.random(0, H - gap) -- pipe starting position
    pipeX = W
    pipeW = 50
    pipeDist = 200
    listOfPipes = {}
    for i= 0, 2 do
        table.insert(listOfPipes, Pipe(pipeX + pipeDist*i, love.math.random(0, H - gap), pipeW, gap))
    end
    
    -- reset pipe, if pipe goes out of window
    function resetPipe()
        pipeX = w
        pipeY = love.math.random(0, H - gap)
    end
    
end

function love.update(dt)
    bird:update(dt)
    
    for i, v in ipairs(listOfPipes) do
        v:update(dt)
    end
    
end

function love.draw()
    
    for i, v in ipairs(listOfPipes) do
        v:draw(dt)
    end
    
    -- draw optimal line
    love.graphics.line(listOfPipes[1].X-75, listOfPipes[1].Y+0.5*listOfPipes[1].gap, --A
                       listOfPipes[1].X+125, listOfPipes[1].Y+0.5*listOfPipes[1].gap,--B
                       listOfPipes[2].X-75, listOfPipes[2].Y+0.5*listOfPipes[2].gap, --C
                       listOfPipes[2].X+125, listOfPipes[2].Y+0.5*listOfPipes[2].gap,--D
                       listOfPipes[3].X-75, listOfPipes[3].Y+0.5*listOfPipes[3].gap, --E
                       listOfPipes[3].X+125, listOfPipes[3].Y+0.5*listOfPipes[3].gap)--F
                
    
    if listOfPipes[1].X + listOfPipes[1].W > -125 then
        love.graphics.print((bird.Y+bird.height/2 - listOfPipes[1].Y - listOfPipes[1].gap/2), 10, 20)
    elseif (listOfPipes[1].X + listOfPipes[1].W < -125 and listOfPipes[1].X + listOfPipes[1].W > -150) then
        love.graphics.print((bird.Y+bird.height/2 - listOfPipes[2].Y - listOfPipes[2].gap/2), 10, 20)
    end
    
    
    
    bird:draw()    
    bird:checkCollision()
end

function love.keypressed(key)
    if key == 'left' then
        love.load()
    end
end