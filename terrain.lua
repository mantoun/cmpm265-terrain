-- Noise-based terrain generation for Love 0.10.0
-- TODO: biomes
local terrain = {}
terrain.map = {}
terrain.age = 0
terrain.width = 256
terrain.height = 256
terrain.tilesize = 4
terrain.scale = 2.5
terrain.octaves = 6
terrain.persistence = .5
terrain.seed = os.time()
terrain.offset = {0, 0}

local canvas = love.graphics.newCanvas()

-- TODO: textures -- wood / bumps
-- TODO: octaves layers moving at different speeds when moving origin
-- need to add the increment to each sample point instead of the origin since
-- there are multiplicative effects
function terrain.createMap()
  math.randomseed(terrain.seed)
  local origin = {math.random(512), math.random(512)}
  local age = terrain.age
  local map = terrain.map
  local offsetx, offsety = terrain.offset[1], terrain.offset[2]
  local width, height = terrain.width, terrain.height
  local contrast = 2  -- Increase the range of the noise
  for y=1,height do
    map[y] = {}
    for x=1,width do
      map[y][x] = 0
    end
  end

  for octave=1,terrain.octaves do
    -- Scale defines the size of the area in noise space from which to draw
    -- points.
    local xscale = terrain.scale * 2^(octave-1)
    local yscale = xscale / (width / height)  -- Don't squash the map
    local nx, ny = origin[1], origin[2]
    local dx = xscale / width
    local dy = yscale / height

    for y=1,height do
      nx = origin[1]
      for x=1,width do
        local noise = love.math.noise(nx, ny, age)  -- Returns values on [0, 1]
        noise = noise * 2 - 1                       -- Put value on [-1, 1]
        -- Reduce amplitude per octave and multiply by a contrast factor.
        -- Contrast is used because Love's 3d noise is a bit flat. Contrast
        -- makes it more likely we'll see the extremes of -1 and 1.
        noise = noise * terrain.persistence^(octave-1) * contrast
        map[y][x] = map[y][x] + noise
        nx = nx + dx
      end
      ny = ny + dy
    end
  end

  -- TODO: rm
  local min, max = 100, 0
  for y=1,height do
    for x=1,width do
      if map[y][x] < min then min = map[y][x] end
      if map[y][x] > max then max = map[y][x] end
    end
  end
  print(min, max)
  renderMap()
end

function renderMap()
  canvas = love.graphics.newCanvas()
  love.graphics.setCanvas(canvas)
  -- TODO: need this? canvas seems to be dark
  love.graphics.clear()

  -- TODO: tile size
  -- TODO: center the map
  local tilesize = terrain.tilesize
  local map = terrain.map
  local xpos, ypos = 0, 0
  for y=1,terrain.height do
    xpos = 0
    for x=1,terrain.width do
      -- Get a height value between 0 and 1
      local height = map[y][x] / 2 + .5
      height = math.min(1, math.max(height, 0))
      -- Interpret height as alpha
      local alpha = height * 255
      local color = getColor(height)
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', xpos, ypos, tilesize, tilesize)
      xpos = xpos + tilesize
    end
    ypos = ypos + tilesize
  end
  love.graphics.setCanvas()
end

function terrain.draw()
  love.graphics.draw(canvas)
end

local function get_alpha(threshold, h, m)
  -- Compute an alpha value. The further h is from the threshold the lower the
  -- return value. m is a multiplier.
  m = m or 1.5
  return 255-255*(threshold-h)*m
end

function getColor(h)
  -- Return a color for h values between 0 and 1
  -- TODO: water maybe up to .4
  local a = get_alpha
  if     h <= .2  then return {0,0,120,        a(.2, h,2)}  -- blue
  elseif h <= .25 then return {0xBD,0xB7,0x6B, a(.25,h,2)}  -- darkkhaki
  elseif h <= .3  then return {0xFF,0xFF,0x00, a(.3, h,4)}  -- yellow
  elseif h <= .4  then return {0,80,0,         a(.4, h)}    -- green
  elseif h <= .55 then return {0x00,0x64,0x00, a(.55,h,1)}  -- darkgreen
  elseif h <= .65 then return {0x30,0x50,0x30, a(.65,h,2)}  -- darker green
  elseif h <= .7  then return {0x6D,0x85,0x3F, a(.7, h,1)}  -- peru
  elseif h <= .8  then return {107,71,36,      a(.8, h)}    -- brown
  elseif h <= .9  then return {0x6D,0x6D,0x6D, a(.9, h)}    -- grey
  elseif h <= 1   then return {0xFF,0xFF,0xFF}              -- white
  else return {0, 0, 0}
  end
end

return terrain
