-- shot.lua (in your scripts directory)
require 'torch'
require 'image'
require 'cutorch'
require 'lfs'

Generator = Object:extend()

function Generator:new()
  
    self.counter = 1                                                    -- screenShot counter
    self.vidLen = 4                                                     -- st length
    self.state = torch.zeros(self.vidLen, im_size, im_size):cuda()      -- st shell
    self.img = torch.zeros(1, im_size, im_size):cuda()                  -- xt shell
                                                                        
end

function Generator:screenShot()
  
  if self.counter == 1 then
    
    pp = io.popen('ls /home/ye/.local/share/love/simpleGameForADPSystem/')
    
    for filep in pp:lines() do
      os.remove("/home/ye/.local/share/love/simpleGameForADPSystem/" .. filep)
    end
    
  end
  
  screenshot = love.graphics.newScreenshot();                                         -- take screen shot(xt)
  fname = self.counter .. '.png'                                                      -- image(xt) name
  screenshot:encode(fname, 'png')                                                     -- save to image
  img = image.loadPNG("/home/ye/.local/share/love/simpleGameForADPSystem/".. fname)   -- load image(xt)
  img = img[1]:type('torch.ByteTensor')                                               -- convert to tensor
  img = image.scale(img, im_size, im_size)                                                      -- reshape to 28 * 28
  self.img = img                                                                      -- assign to xt
  self.counter = self.counter + 1                                                     -- screenShot counter update
  
end

function Generator:genState()

  if self.counter < self.vidLen then                                                  -- if counter < vidLen, directly stack img
    self.state[self.counter] = self.img
  else
    for i = 1, self.vidLen do                                                         -- achieve queue s[1] = s[2], s[2]=s[3], s[3]=s[4], s[4] = s_new
      if i < self.vidLen then
        self.state[i] = self.state[i+1]
      else
        self.state[i] = self.img
      end
    end
  end

end