-- Initialize and return a tileset that maps terrain types to quads in an
-- atlas. The map keys are created by composing the terrain types of the four
-- corners of each map square.
local tileset = {}
tileset.tilesize = 16  -- the size of the tiles in the terrain map
tileset.tiles = {}

-- Map terrain types to height thresholds. Note that h ranges from [-1, 1]
local function getType(h)
  if     h < .2 then return 1  -- water
  elseif h < .3 then return 2  -- sand
  elseif h < .6 then return 3  -- grass
  elseif h < .8 then return 4  -- forest
  else               return 5  -- snow
  end
end

-- To find the correct tile we can index into a table by composing the four
-- corner values starting in the upper left (as the most significant digit)
-- and moving clockwise. Return the average tile type too in case we don't
-- have an appropriate transition tile.
-- TODO: these could be part of terrain.lua
function getTileIndex(x, y, map)
  local ul = getType(map[x][y])
  local ur = getType(map[x+1][y])
  local lr = getType(map[x+1][y+1])
  local ll = getType(map[x][y+1])
  local index = 1000 * ul + 100 * ur + 10 * lr + ll
  local avg = (ul + ur + lr + ll) / 4
  avg = math.floor(avg + 0.5)  -- round
  avg = 1000 * avg + 100 * avg + 10 * avg + avg
  return index, avg
end

-- Initialize the tileset
local tiles = tileset.tiles
local ts = tileset.tilesize
local land = love.graphics.newImage('textures/tileset_1.png')
local water = love.graphics.newImage('textures/water_1.png')
local function newQuad(x, y, tileset)
  local tx, ty = tileset:getDimensions()
  return love.graphics.newQuad(x*ts, y*ts, ts, ts, tx, ty)
end

-- Tiles store a reference to the texture atlas and the appropriate quad. We
-- could get away with just the quad if there were only a single atlas.
tiles[1111] = {water, newQuad(0, 0, water)}
tiles[2222] = {land, newQuad(4, 1, land)}
tiles[3333] = {land, newQuad(1, 1, land)}
tiles[4444] = {land, newQuad(4, 11, land)}
tiles[5555] = {land, newQuad(7, 1, land)}

return tileset
