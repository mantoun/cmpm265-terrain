-- Noise-based terrain generation for Love 0.10.0
local tileset = require 'tileset'
local terrain = {}
terrain.map = {}
terrain.age = 0
terrain.width = 64
terrain.height = 64
terrain.tilesize = 16  -- the apparent tilesize
terrain.scale = 1      -- must be smaller for small w and h for good xitions
terrain.octaves = 6
terrain.persistence = .5
terrain.seed = os.time()
terrain.offset = {0, 0}
terrain.debug = false

local canvas = love.graphics.newCanvas()

function terrain.createMap()
  math.randomseed(terrain.seed)
  local origin = {math.random(512), math.random(512)}
  local age = terrain.age
  local map = terrain.map
  local offsetx, offsety = terrain.offset[1], terrain.offset[2]
  local width, height = terrain.width+1, terrain.height+1
  local contrast = 1.5  -- Increase the range of the noise
  -- Instead of sampling a height for each tile, we'll sample the heights at
  -- the four vertices, so our map structure is a series of corner points.
  for y=1,height do
    map[y] = {}
    for x=1,width do
      map[y][x] = 0
    end
  end

  for octave=1,terrain.octaves do
    -- Define the size of the area in noise space from which to draw points.
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
        -- changing of values for some points. Converting to and from [-1, 1]?
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

  -- Print min and max height values
  if terrain.debug then
    local min, max = 100, 0
    for y=1,height do
      for x=1,width do
        if map[y][x] < min then min = map[y][x] end
        if map[y][x] > max then max = map[y][x] end
      end
    end
    print(min, max)
  end

  renderMap()
end

function renderMap()
  local map = terrain.map
  local tilesize = terrain.tilesize
  local w = terrain.width * tilesize
  local h = terrain.height * tilesize
  canvas = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(canvas)

  -- Scale the 16x16 tiles to terrain.tilesize
  local sx, sy = tilesize / tileset.tilesize

  local function drawTile(x, y, index, avg)
    -- Given a position on screen, draw the tile specified by index. If such a
    -- tile isn't present, use the avg tile height to pick the tile.
    local tile = tileset.tiles[index] or tileset.tiles[avg]
    love.graphics.draw(tile[1], tile[2], x, y, 0, sx, sy)
  end

  local map = terrain.map
  local xpos, ypos = 0, 0
  for y=1,terrain.height do
    xpos = 0
    for x=1,terrain.width do
      -- TODO: a pass to randomly place alternate tiles
      -- TODO: a pass to use the 4x4 and 2x2 tree tiles in the forest
      -- TODO: remove? a hack for tileset: draw grass under everything so we
      -- can use the transparent tree graphic for forest tiles
      drawTile(xpos, ypos, 3333)  -- Draw grass under all
      drawTile(xpos, ypos, getTileIndex(x, y, map))
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
