--! file: pipe.lua
Pipe = Object:extend()

function Pipe:new(X, Y, W, G)
    self.X = X
    self.Y = Y
    self.W = W
    self.gap = G
end

function Pipe:update(dt)
    -- pipe moving speed
    self.X = self.X - 250*dt
    
    -- when pipe move out of window delete the first pipe in listOfPipes, then add a new pipe
    if self.X < -pipeDist then
        table.insert(listOfPipes, Pipe(listOfPipes[3].X+2*pipeDist, love.math.random(0, H - gap), pipeW, gap))
        table.remove(listOfPipes, 1)
    end
end

function Pipe:draw()
    -- draw pipe upper part and lower part
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', self.X, 0, self.W, self.Y)
    
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', self.X, self.Y+self.gap, self.W, H-self.Y-self.gap) 
end
