-- Noise-based terrain generation for Love 0.10.0
-- TODO: biomes
local terrain = {}
terrain.map = {width=0, height=0}
terrain.age = 0
terrain.scale = 8

function terrain.createMap(width, height, tileset)
  local age = terrain.age
  local map = terrain.map
  map.width = width
  map.height = height
  -- TODO: if no tileset just use color
  -- TODO: if tileset, check for {path="", size=16}
  -- TODO: use seed if provided
  --math.randomseed(os.time())
  math.randomseed(123)

  -- Find the region in noise-space from which to sample
  -- Generate sample points by dividing a bounding rectangle
  -- TODO: use a scale
  local xscale = terrain.scale  -- How large an area in noise space to cover
  local yscale = xscale / (width / height)  -- Don't squash the map
  local origin = {math.random(256), math.random(256)}
  local nx, ny = origin[1], origin[2]
  local dx = xscale / width
  local dy = yscale / height

  for y=1,height do
    map[y] = {}
    nx = origin[1]
    for x=1,width do
      -- TODO: put noise on the original range of [-1, 1] to better support
      -- adding octaves
      map[y][x] = love.math.noise(nx, ny, age)
      nx = nx + dx
    end
    ny = ny + dy
  end

  -- Debug print
  --[[
  for i=1,height do
    local s = (" %s\t"):format(i)
    for j=1,width do
      v = map[i][j] or "."
      s = ("%s%.2f\t"):format(s, v)
    end print(s.."\n")
  end
  --]]
end

function terrain.draw()
  -- TODO: tile size
  -- TODO: center the map
  local tilesize = 8
  local map = terrain.map
  local xpos, ypos = 0, 0
  for y=1,map.height do
    xpos = 0
    for x=1,map.width do
      -- Interpret height as alpha
      local color = {255, 255, 255, map[y][x] * 255}
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', xpos, ypos, tilesize, tilesize)
      xpos = xpos + tilesize
    end
    ypos = ypos + tilesize
  end
end

return terrain
