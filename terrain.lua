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
  local contrast = 1.75  -- Increase the range of the noise
  for y=1,height do
    map[y] = {}
    for x=1,width do
      map[y][x] = 0
    end
  end

  for octave=1,terrain.octaves do
    -- Scale defines the size of the area in noise space from which to draw
    -- points.
    local freq = 2^(octave-1)
    local xscale = terrain.scale * freq
    local yscale = xscale / (width / height)  -- Don't squash the map
    local nx, ny = origin[1], origin[2]
    local dx = xscale / width
    local dy = yscale / height

    for y=1,height do
      nx = origin[1]
      for x=1,width do
        local posx = nx + (offsetx * freq)   -- Sample point includes offset
        local posy = ny + (offsety * freq)
        local noise = love.math.noise(posx, posy, age)  -- Returns [0, 1]
        noise = noise * 2 - 1                           -- Put on [-1, 1]
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
      --TODO: rm
      --local color = getColor(height)
      local color = {255, 255, 255, alpha}
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', xpos, ypos, tilesize, tilesize)
      xpos = xpos + tilesize
    end
    ypos = ypos + tilesize
  end
  love.graphics.setCanvas()
end

function terrain.draw()
  -- TODO: center the map
  love.graphics.draw(canvas)
end

return terrain
