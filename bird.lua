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
    x, self.Y = love.mouse.getPosition( )
end

function Bird:draw()
    -- draw bird
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle('fill', 0, self.Y, self.width, self.height)
end
