-- Noise-based terrain generation for Love 0.10.0
-- TODO: biomes
local terrain = {}
terrain.map = {}
terrain.age = 0
terrain.width = 64
terrain.height = 64
terrain.tilesize = 32  -- the apparent tilesize
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
  local contrast = 1.5  -- Increase the range of the noise
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
        -- Find the point in noise space from which to sample. Include the
        -- offset so we can move the map. TODO: there's still some very subtle
        -- changing of values for some points.
        local posx = nx + (offsetx * freq)
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
  local tilesize = terrain.tilesize
  local w = terrain.width * tilesize
  local h = terrain.height * tilesize
  canvas = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(canvas)

  -- Initialize the tileset
  local tileset = love.graphics.newImage('textures/tileset_1.png')
  local tx, ty = tileset:getDimensions()
  local ts = 16  -- the size of the tiles in the terrain map
  local tiles = {}
  tiles.grass = love.graphics.newQuad(16, 16, ts, ts, tx, ty)
  tiles.sand = love.graphics.newQuad(64, 16, ts, ts, tx, ty)
  tiles.hill = love.graphics.newQuad(16, 176, ts, ts, tx, ty)
  tiles.snow = love.graphics.newQuad(112, 16, ts, ts, tx, ty)
  tiles.forest = love.graphics.newQuad(64, 176, ts, ts, tx, ty)
  tiles.snowforest = love.graphics.newQuad(112, 176, ts, ts, tx, ty)
  local water = love.graphics.newImage('textures/water_1.png')
  tx, ty = water:getDimensions()
  tiles.water = love.graphics.newQuad(0, 0, ts, ts, tx, ty)
  -- Scale the 16x16 tiles to terrain.tilesize
  local sx, sy = terrain.tilesize / ts

  local function drawTile(h, x, y, sx, sy)
    -- Given a height value between [0, 1], a position on screen, and a scale
    -- factor, draw the appropriate tile.
    -- TODO: accept coords and check neighbors for transitions
    if h < .3 then
      love.graphics.draw(water, tiles.water, x, y, 0, sx, sy)
    elseif h < .4 then
      love.graphics.draw(tileset, tiles.sand, x, y, 0, sx, sy)
    elseif h < .6 then
      love.graphics.draw(tileset, tiles.grass, x, y, 0, sx, sy)
    elseif h < .7 then
      love.graphics.draw(tileset, tiles.hill, x, y, 0, sx, sy)
    elseif h < .8 then
      love.graphics.draw(tileset, tiles.forest, x, y, 0, sx, sy)
    else
      love.graphics.draw(tileset, tiles.snow, x, y, 0, sx, sy)
    end
  end

  local map = terrain.map
  local xpos, ypos = 0, 0
  local img, quad
  for y=1,terrain.height do
    xpos = 0
    for x=1,terrain.width do
      -- Get a height value between 0 and 1
      local height = map[y][x] / 2 + .5
      height = math.min(1, math.max(height, 0))
      drawTile(height, xpos, ypos, sx, sy)
      xpos = xpos + tilesize
    end
    ypos = ypos + tilesize
  end
  love.graphics.setCanvas()
end

function terrain.draw()
  local hwx = love.graphics.getWidth() / 2  -- Half of window width
  local hwy = love.graphics.getHeight() / 2
  local hcx = canvas:getWidth() / 2
  local hcy = canvas:getHeight() / 2
  love.graphics.draw(canvas, hwx-hcx, hwy-hcy)
end

return terrain
