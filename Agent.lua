Agent = Object:extend()

function Agent:new()
  self.qnet = Qnet()
  self.action = 14
end

function Agent:decision()
  generator:screenShot()
  generator:genState()
  self.st1 = generator.state
  
  -- get Q(st, at)
  if step > 1 then
    Qat = self.qnet:run(st, at)
    QQ = self.qnet.net:forward(st)
    print("******************************")
    print(QQ)
    gnuplot.plot(QQ, '|')
    gnuplot.axis({-2, 30, -1, 2})
    qqparams, qqgradParams = self.qnet.net:getParameters()
    print("------------------------------")
    print(qqparams[1])
  end
  
  -- get Q(st1, at1)
  Qat1, at1 = self.qnet:run(st1, -1)
  
  -- epsilon greedy
  if (counter < 1000) then
    th = 0.3
  elseif (counter < 2000) then
    th = 0.2
  elseif (counter < 3000) then
    th = 0.1
  elseif (counter < 5000) then
    th = 0.05
  else
    th = 0.01
  end
    
  if math.random() < th then
    -- softMax = torch.exp(QQ)/torch.sum(torch.exp(QQ))
    --print(softMax)
    -- at1 = torch.multinomial(softMax, 1)[1]
    at1 = math.random(28)
  end
  
  return at1
end


