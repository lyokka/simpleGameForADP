require "gnuplot"
require "sys"
-- generate a bird object
Bird = Object:extend()

function Bird:new(w, h, Y)
    
    -- Y: bird initial position
    -- w: bird width
    -- h: bird height
    
    self.X = 0
    self.height = h
    self.width = w
    self.Y = Y
    self.DONE = 0
    
end

function Bird:update(dt)
  
    -- update bird position
    -- x, self.Y = love.mouse.getPosition( )


    -- generate state
    generator:screenShot()
    generator:genState()
    
    s_t1 = generator.state
    
    -- get Q(st, at)
    if step > 1 then
      QQ = qnet.net:forward(s_t1)      
      gnuplot.plot(QQ, '|')
      gnuplot.axis({0, 50, -5, 50})
      gnuplot.plotflush()
    end
        
    -- get Q(st1, at1)
    Qat1, a_t1 = qnet:run(s_t1, -1)
    
    -- epsilon greedy
    th = 1 - 0.0001*counter
    
    
    if (math.random() < 0) and (step > 1) then
      
      softMax = torch.exp(QQ)/torch.sum(torch.exp(QQ))
      a_t1 = torch.multinomial(softMax, 1)[1]
      
    end
    
    target_pos = 580/47*a_t1 - 580/47
    x = target_pos - self.Y
    
    u = 0.095*x
    
    -- if step > 1 then
    --   transLow = {u = u, x = x, target = target_pos, y=self.Y}
    --   torch.save("sample_low/sample_low_" .. ccc .. ".t7", transLow)
    --   ccc = ccc + 1    
    -- end
    
    self.Y = self.Y + u
    
    
    if self.Y > 590 then
      self.Y = 590
    end
    
    if self.Y < 0 then
      self.Y = 0
    end
    
    -- save transition
    if step > 1 then
      trans = {st = s_t, at = a_t, rt = 1, st1=s_t1, done = self.DONE}
      torch.save("sample_data/sample" .. counter .. "-" .. step-1 .. ".t7", trans)
    end
    
    -- update 

    s_t = s_t1:clone()
    a_t = a_t1
    
    -- save model
    if (counter % 300 == 0) and (step == 1) then
      torch.save("model_hist/model_" .. counter .. ".t7", qnet.net)
    end
    
    
    --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    -- if listOfPipes[1].X > -75 - listOfPipes[1].W then
    --  love.graphics.print((bird.Y+bird.height/2 - listOfPipes[1].Y - listOfPipes[1].gap/2), 10, 20)
    --  self.Y = listOfPipes[1].Y + listOfPipes[1].gap/2 - self.height/2
    --elseif (listOfPipes[1].X + listOfPipes[1].W < -75 and listOfPipes[1].X + listOfPipes[1].W > -150) then
    --  love.graphics.print((bird.Y+bird.height/2 - listOfPipes[2].Y - listOfPipes[2].gap/2), 10, 20)
    --  self.Y = listOfPipes[2].Y + listOfPipes[2].gap/2 - self.height/2
    --end
    
end

function Bird:draw()
    -- draw bird
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle('fill', self.X, self.Y, self.width, self.height)

end

function Bird:checkCollision()

    love.graphics.setColor(0, 0, 255, 255)    
    love.graphics.print(step, 20, 20)
    love.graphics.print(counter, 20, 30)
    
    v = listOfPipes[1]
    v2 = listOfPipes[2]
    
    if v.X + v.W > 0 then     
        if v.X < self.width and
            (v.Y > self.Y or (self.Y+self.width > v.Y+ v.gap))then
                love.graphics.setColor(0, 0, 255, 255)    
                love.graphics.print('collision', 10, 20)  
                self.DONE = 1
        end
    else
        if v2.X < self.width and
            (v2.Y > self.Y or (self.Y+self.width > v2.Y+ v2.gap)) then
                love.graphics.setColor(0, 0, 255, 255)    
                love.graphics.print('collision', 10, 20)
                self.DONE = 1
        end
    end
end