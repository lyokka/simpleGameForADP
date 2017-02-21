--! file: bird.lua
-- generate a bird object
Bird = Object:extend()

function Bird:new(w, h, Y)
    
    -- Y: bird initial position
    -- w: bird width
    -- h: bird height
    
    self.height = h
    self.width = w
    self.Y = Y
end

function Bird:update(dt)
    -- update bird position
    --x, self.Y = love.mouse.getPosition( )
    
    if listOfPipes[1].X > -75 - listOfPipes[1].W then
        love.graphics.print((bird.Y+bird.height/2 - listOfPipes[1].Y - listOfPipes[1].gap/2), 10, 20)
        self.Y = listOfPipes[1].Y + listOfPipes[1].gap/2 - self.height/2
    elseif (listOfPipes[1].X + listOfPipes[1].W < -75 and listOfPipes[1].X + listOfPipes[1].W > -150) then
        love.graphics.print((bird.Y+bird.height/2 - listOfPipes[2].Y - listOfPipes[2].gap/2), 10, 20)
        self.Y = listOfPipes[2].Y + listOfPipes[2].gap/2 - self.height/2
    end
    
end

function Bird:draw()
    -- draw bird
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle('fill', 0, self.Y, self.width, self.height)
    -- love.graphics.setColor(125, 125, 255)
    -- love.graphics.print(self.Y, 10, 20)
end

function Bird:checkCollision()
    --[[
    for i, v in ipairs(listOfPipes) do
        if v.X < self.width and
            (v.Y > self.Y or (self.Y+self.width > v.Y+ v.gap))then
            love.graphics.setColor(0, 0, 255, 255)    
            love.graphics.print('collision', 10, 20)    
        end
    end
    --]]
    
    v = listOfPipes[1]
    v2 = listOfPipes[2]
    
    if v.X + v.W > 0 then     
        if v.X < self.width and
            (v.Y > self.Y or (self.Y+self.width > v.Y+ v.gap))then
                love.graphics.setColor(0, 0, 255, 255)    
                love.graphics.print('collision', 10, 20)    
                -- love.load()
        end
    else
        if v2.X < self.width and
            (v2.Y > self.Y or (self.Y+self.width > v2.Y+ v2.gap)) then
                love.graphics.setColor(0, 0, 255, 255)    
                love.graphics.print('collision', 10, 20)
                -- love.load()
        end
    end
    
end