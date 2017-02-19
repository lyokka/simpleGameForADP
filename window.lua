--! file: window.lua
-- to generate a window object, with width w, and height h
Window = Object:extend()

function Window:new(w, h)
    
    -- w: window width
    -- h: window height
    
    love.window.setMode(w, h,
        {resizable=false, vsync=false, minwidth=400, minheight=300})

end