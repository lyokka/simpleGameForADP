function love.load()
    Object = require('classic')
    require('window')
    require('bird')
    require('pipe')
    
    -- window initalization
    W = 500 -- window size
    H = 600
    window = Window(W, H)
    
    -- bird initalization
    birdh = 20
    birdw = 20
    birdY = 300
    
    bird = Bird(birdw, birdh, birdY)
    
    -- pipe initalization 
    -- 3*(pipeW + pipeDist) = W
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
    bird:draw()    
    
    for i, v in ipairs(listOfPipes) do
        v:draw(dt)
    end
    
end

function love.keypressed(key)
    if key == 'left' then
        love.load()
    end
end
