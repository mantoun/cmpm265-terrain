-- A utility function to copy tables
function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

-- Return a random float between min and max
function randf(min, max)
  return math.random() * (max - min) + min
end

-- Linear interpolation
function lerp(a, b, t)
  return (1 - t) * a + t * b
end

local function getAlpha(threshold, h, m)
  -- Compute an alpha value. The further h is from the threshold the lower the
  -- return value. m is a multiplier.
  m = m or 1.5
  return 255-255*(threshold-h)*m
end

-- Return a color for h values between -1 and 1
function getColor(h)
  local a = getAlpha
  if     h <= .2  then return {0,0,120,        a(.2, h,1)}  -- blue
  elseif h <= .25 then return {0xBD,0xB7,0x6B, a(.25,h,2)}  -- dark khaki
  elseif h <= .3  then return {0xFF,0xFF,0x00, a(.3, h,4)}  -- yellow
  elseif h <= .4  then return {0,80,0,         a(.4, h)}    -- green
  elseif h <= .55 then return {0x00,0x64,0x00, a(.55,h,1)}  -- darkgreen
  elseif h <= .65 then return {0x30,0x50,0x30, a(.65,h,2)}  -- darker green
  elseif h <= .7  then return {0x6D,0x85,0x3F, a(.7, h,1)}  -- peru
  elseif h <= .8  then return {107,71,36,      a(.8, h)}    -- brown
  elseif h <= .9  then return {0x6D,0x6D,0x6D, a(.9, h)}    -- grey
  else return {0xFF,0xFF,0xFF}                              -- white
  end
end

--[[
-- Draw a colored square based on height instead of tiles
love.graphics.setColor(getColor(map[y][x]))
love.graphics.rectangle("fill", xpos, ypos, tilesize, tilesize)
]]
