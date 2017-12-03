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
  self.output = 48

end

function Qnet:build()
  
  self.net:add(nn.SpatialConvolution(4, 8, 5, 5, 2, 2)) -- 1 input image channel, 6 output channels, 5x5 convolution kernel
  self.net:add(nn.ReLU())                       -- non-linearity 
  self.net:add(nn.SpatialConvolution(8, 16, 5, 5, 2, 2))
  self.net:add(nn.ReLU())                       -- non-linearity
  self.net:add(nn.SpatialConvolution(16, 16, 5, 5, 2, 2))
  self.net:add(nn.ReLU())                       -- non-linearity
  self.net:add(nn.View(16*3*3))                    -- reshapes from a 3D tensor of 16x5x5 into 1D tensor of 16*5*5
  self.net:add(nn.Linear(16*3*3, 64))             -- fully connected layer (matrix multiplication between input and weights)
  self.net:add(nn.ReLU())                       -- non-linearity 
  self.net:add(nn.Linear(64, self.output))                   -- 10 is the number of outputs of the network (in this case, 10 digits)
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
  optimState = {learningRate = 0.1} -- sgd 0.000001
  
  Qbuffer = {}
  local p = io.popen('ls /home/ye/Desktop/simpleGameForADPSystem/sample_data/')
  for file in p:lines() do
    table.insert(Qbuffer, file)
  end
  
  if #Qbuffer < self.batchSize then
    self.batchSize = #Qbuffer
  else
    self.batchSize = 256
  end
  
  QbatchData = torch.zeros(self.batchSize, 4, im_size, im_size):cuda()
  QbatchLabels = torch.zeros(self.batchSize, self.output):cuda()
  
  for j = 1, self.batchSize do
    
    Qfname = "/home/ye/Desktop/simpleGameForADPSystem/sample_data/" .. Qbuffer[math.random(#Qbuffer)]
    Qsample = torch.load(Qfname)
    QbatchData[j] = Qsample.st
    QPred = self.net:forward(Qsample.st)
    QLabels = torch.CudaTensor(self.output):copy(QPred)

    if Qsample.done == 1 then
      QLabels[Qsample.at] = -2
      -- print("QLabels[Qsample.at]")
      -- print(QLabels[Qsample.at])
    else
      lambda = 0.95
      q = torch.max(self.net:forward(Qsample.st1), 1)[1]
      QLabels[Qsample.at] = lambda*q + Qsample.rt
    end

    
    QbatchLabels[j] = QLabels
    -- print("----------------------")
    -- print("action : ")
    -- print(Qsample.at)
    -- print("label : ")
    
    -- print("pred : ")
    -- print(QPred[Qsample.at])
    -- print("----------------------")
  
  end
  print(QLabels[Qsample.at])
  if #Qbuffer > 10000 then
    for m = 1, #Qbuffer - 10000 do
      os.remove("/home/ye/Desktop/simpleGameForADPSystem/sample_data/" .. Qbuffer[math.random(#Qbuffer)])
    end
  end
  
  QbatchPred = self.net:forward(QbatchData)
  
  ll = 0
  
  function feval(Qparams)
    
    QgradParams:zero()
    local Qloss = self.criterion:forward(QbatchPred, QbatchLabels)
    local Qdloss_doutputs = self.criterion:backward(QbatchPred, QbatchLabels)
    self.net:backward(QbatchData, Qdloss_doutputs)
    ll = Qloss
    print( "Qloss -- " .. Qloss)
    return Qloss, QgradParams
  end

  optim.adadelta(feval, Qparams, optimState)
  
  return ll
end
