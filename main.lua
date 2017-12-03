require "torch"
require "cutorch"
require "nn"
require "gnuplot"

gnuplot.figure(1)

Object = require('classic')
require('window')
require('bird')
require('pipe')
require('generator')
require('Qnet')
require('Vnet')

counter = 9900
ccc = 1
K = math.random()*0.1
im_size = 48
qnet = Qnet()
qnet.net = torch.load("model_hist/model_" .. counter .. ".t7")
-- qnet:build()

transList = {}
function love.load()
    -- window initalization

    W = 600 -- window size
    H = 600
    window = Window(W, H)

    -- bird initalization
    birdh = 30
    birdw = 30
    birdY = 300

    bird = Bird(birdw, birdh, birdY)
    generator = Generator()
    step = 0

    -- pipe initalization
    -- 2*pipeDist) = W
    gap = 200 -- pipe gap
    -- love.math.setRandomSeed(42)
    pipeY = love.math.random(0, H - gap) -- pipe starting position
    pipeX = W
    pipeW = 100
    pipeDist = 400
    listOfPipes = {}

    for i= 0, 3 do
        table.insert(listOfPipes, Pipe(pipeX + pipeDist*i, love.math.random(0, H - gap), pipeW, gap))
    end

    -- reset pipe, if pipe goes out of window
    function resetPipe()
        pipeX = w
        pipeY = love.math.random(0, H - gap)
    end

end

function love.update(dt)
    
    -- print(bird.DONE)
    if bird.DONE == 0 then
      bird:update(dt)
      step = step + 1

      for i, v in ipairs(listOfPipes) do
        v:update(dt)
      end
    end
    
    -- check if done
    if bird.DONE == 1 then
      bird:update(dt)
      -- lll = qnet:update()
      -- print(counter)
      qparams, qgradParams = qnet.net:getParameters()
      print(qparams[10])
      counter = counter + 1
      love.load()
    end
    

end

function love.draw()
    
    for i, v in ipairs(listOfPipes) do
        v:draw(dt)
    end

    -- draw optimal line
    -- love.graphics.line(listOfPipes[1].X-75, listOfPipes[1].Y+0.5*listOfPipes[1].gap, --A
    --                   listOfPipes[1].X+125, listOfPipes[1].Y+0.5*listOfPipes[1].gap,--B
    --                   listOfPipes[2].X-75, listOfPipes[2].Y+0.5*listOfPipes[2].gap, --C
    --                   listOfPipes[2].X+125, listOfPipes[2].Y+0.5*listOfPipes[2].gap,--D
    --                   listOfPipes[3].X-75, listOfPipes[3].Y+0.5*listOfPipes[3].gap, --E
    --                   listOfPipes[3].X+125, listOfPipes[3].Y+0.5*listOfPipes[3].gap)--F


    -- if listOfPipes[1].X + listOfPipes[1].W > -125 then
    --    love.graphics.print((bird.Y+bird.height/2 - listOfPipes[1].Y - listOfPipes[1].gap/2), 10, 20)
    -- elseif (listOfPipes[1].X + listOfPipes[1].W < -125 and listOfPipes[1].X + listOfPipes[1].W > -150) then
    --    love.graphics.print((bird.Y+bird.height/2 - listOfPipes[2].Y - listOfPipes[2].gap/2), 10, 20)
    -- end

    bird:draw()
    bird:checkCollision()
    -- local screenshot = love.graphics.newScreenshot();
    -- fname = count .. '.png'
    -- screenshot:encode(fname, 'png')
end

function love.keypressed(key)
    if key == 'left' then
        love.load()
    end
end
