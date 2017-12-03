Object = require('classic')
require('window')
require('bird')
require('pipe')
require('generator')
require('Qnet')
require('Vnet')
require 'torch'
require 'cutorch'
require 'cunn'
require 'nn'
require 'optim'
require "gnuplot"
qnet = Qnet()
qnet.net = torch.load("model_hist/model_150.t7")
-- qnet:build()
lossHist = torch.Tensor(1000)

for i=1, 300 do
  print("i : " .. i)
  L = qnet:update()
  lossHist[i] = L
  -- qparams, qgradParams = qnet.net:getParameters()
  -- print(qparams[10])
end

torch.save("model_hist/offline_1.t7", qnet.net)
gnuplot.plot(lossHist)