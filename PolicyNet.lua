require 'torch'
require 'cutorch'
require 'cunn'
require 'nn'
require 'optim'
Qnet = Object:extend()
im_size = 48

function Qnet:new()
  
  self.net = nn.Sequential()
  self.criterion = nn.MSECriterion():cuda()
  self.batchSize = 32
  self.output = 1

end

function Qnet:build()
  
  self.net:add(nn.SpatialConvolution(4, 16, 5, 5)) -- 1 input image channel, 6 output channels, 5x5 convolution kernel
  self.net:add(nn.ReLU())                       -- non-linearity 
  self.net:add(nn.SpatialConvolution(16, 8, 5, 5))
  self.net:add(nn.ReLU())                       -- non-linearity
  self.net:add(nn.View(8*40*40))                    -- reshapes from a 3D tensor of 16x5x5 into 1D tensor of 16*5*5
  self.net:add(nn.Linear(8*40*40, 120))             -- fully connected layer (matrix multiplication between input and weights)
  self.net:add(nn.ReLU())                       -- non-linearity 
  self.net:add(nn.Linear(120, 84))
  self.net:add(nn.ReLU())                       -- non-linearity 
  self.net:add(nn.Linear(84, self.output))                   -- 10 is the number of outputs of the network (in this case, 10 digits)
  self.net = self.net:cuda();

end

function Qnet:run(qstate, qaction)
  
  qVec = self.net:forward(qstate)
  
  if qaction == -1 then
    q, indices = torch.max(qVec, 1)
    return q, indices[1]
  else
    q = qVec[qaction]
    return q
  end
  
end

function Qnet:update()
  Qparams, QgradParams = self.net:getParameters()
  optimState = {learningRate = 0.00001} -- sgd 0.000001
  
  Qbuffer = {}
  local p = io.popen('ls /home/ye/Desktop/simpleGameForADPSystem/sample_data/')
  for file in p:lines() do
    table.insert(Qbuffer, file)
  end
  
  if #Qbuffer < self.batchSize then
    self.batchSize = #Qbuffer
  else
    self.batchSize = 128
  end
  
  -- print(#Qbuffer)
  
  QbatchData = torch.zeros(self.batchSize, 4, im_size, im_size):cuda()
  QbatchLabels = torch.zeros(self.batchSize, self.output):cuda()
  
  for j = 1, self.batchSize do
    
    Qfname = "/home/ye/Desktop/simpleGameForADPSystem/sample_data/" .. Qbuffer[math.random(#Qbuffer)]
    Qsample = torch.load(Qfname)
    QbatchData[j] = Qsample.st
    QPred = self.net:forward(Qsample.st)
    QLabels = torch.CudaTensor(self.output):copy(QPred)

    if Qsample.done == 1 then
      lambda = 0
      q = 0
    else
      lambda = 0.999
      q = torch.max(self.net:forward(Qsample.st1), 1)[1]
    end

    QLabels[Qsample.at] = lambda*q + Qsample.rt
    QbatchLabels[j] = QLabels
        
  end
  
  if #Qbuffer > 10000 then
    for m = 1, #Qbuffer - 10000 do
      os.remove("/home/ye/Desktop/simpleGameForADPSystem/sample_data/" .. Qbuffer[math.random(#Qbuffer)])
    end
  end
  
  QbatchPred = self.net:forward(QbatchData)
  
  function feval(Qparams)
    
    QgradParams:zero()
    local Qloss = self.criterion:forward(QbatchPred, QbatchLabels)
    local Qdloss_doutputs = self.criterion:backward(QbatchPred, QbatchLabels)
    self.net:backward(QbatchData, Qdloss_doutputs)
    print( "Qloss -- " .. Qloss)
    return Qloss, QgradParams
  end

  optim.adam(feval, Qparams, optimState)
end
