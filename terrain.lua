-- Noise-based terrain generation for Love 0.10.0
-- TODO: biomes
local terrain = {}
terrain.map = {width=0, height=0}
terrain.age = 0
terrain.width = 256
terrain.height = 256
terrain.scale = 2
terrain.octaves = 1
terrain.persistence = .5

function terrain.createMap()
  local age = terrain.age
  local map = terrain.map
  local width = terrain.width
  local height = terrain.height
  for y=1,height do
    map[y] = {}
    for x=1,width do
      map[y][x] = 0
    end
  end
  -- TODO: if no tileset just use color
  -- TODO: if tileset, check for {path="", size=16}
  -- TODO: use seed if provided
  --math.randomseed(os.time())
  math.randomseed(123)

  for octave=1,terrain.octaves do
    -- Scale defines the size of the area in noise space from which to draw
    -- points.
    local xscale = terrain.scale * octave
    local yscale = xscale / (width / height)  -- Don't squash the map
    -- The origin in noise space
    local origin = {math.random(256), math.random(256)}
    local nx, ny = origin[1], origin[2]
    local dx = xscale / width
    local dy = yscale / height

    for y=1,height do
      nx = origin[1]
      for x=1,width do
        local noise = love.math.noise(nx, ny, age)  -- Returns values on [0, 1]
        noise = noise * 2 - 1                       -- Put value on [-1, 1]
        -- Reduce amplitude per octave
        local amplitude = terrain.persistence^(octave-1)
        noise = noise * amplitude
        map[y][x] = map[y][x] + noise
        nx = nx + dx
      end
      ny = ny + dy
    end
  end
end

function terrain.draw()
  -- TODO: tile size
  -- TODO: center the map
  local tilesize = 4
  local map = terrain.map
  local xpos, ypos = 0, 0
  for y=1,terrain.height do
    xpos = 0
    for x=1,terrain.width do
      -- Interpret height as alpha
      local alpha = (map[y][x] / 2 + .5) * 255
      local color = {255, 255, 255, alpha}
      love.graphics.setColor(color)
      love.graphics.rectangle('fill', xpos, ypos, tilesize, tilesize)
      xpos = xpos + tilesize
    end
    ypos = ypos + tilesize
  end
end

return terrain
