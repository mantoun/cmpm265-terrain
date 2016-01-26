-- Initialize and return a tileset that maps terrain types to quads in an
-- atlas. The map keys are created by composing the terrain types of the four
-- corners of each map square.
local tileset = {}
tileset.tilesize = 16  -- the size of the tiles in the terrain map
tileset.tiles = {}

-- Map terrain types to height thresholds. Note that h ranges from [-1, 1]
local function getType(h)
  if     h < .2 then return 1  -- water
  elseif h < .3 then return 2  -- dirt
  elseif h < .6 then return 3  -- grass
  elseif h < .8 then return 4  -- forest
  else               return 5  -- dark forest
  end
end

-- To find the correct tile we can index into a table by composing the four
-- corner values starting in the upper left (as the most significant digit)
-- and moving clockwise. Return the average tile type too in case we don't
-- have an appropriate transition tile.
-- TODO: these could be part of terrain.lua
-- TODO: should have been map[y][x]...
function getTileIndex(x, y, map)
  local ul = getType(map[x][y])
  local ur = getType(map[x+1][y])
  local lr = getType(map[x+1][y+1])
  local ll = getType(map[x][y+1])
  local index = tonumber(ul .. ur .. lr .. ll)
  local avg = (ul + ur + lr + ll) / 4
  avg = math.floor(avg + 0.5)  -- round
  avg = tonumber(avg .. avg .. avg .. avg)
  return index, avg
end

-- Initialize the tileset
local tiles = tileset.tiles
local ts = tileset.tilesize
local function newQuad(x, y, tileset)
  local tx, ty = tileset:getDimensions()
  return love.graphics.newQuad(x*ts, y*ts, ts, ts, tx, ty)
end
local function newTile(x, y, tileset)
  return {tileset, newQuad(x, y, tileset)}
end

local sheet = love.graphics.newImage('textures/sheet.png')

-- Define base tiles
tiles[1111] = newTile(4, 7, sheet)
tiles[2222] = newTile(4, 4, sheet)
tiles[3333] = newTile(6, 6, sheet)
tiles[4444] = newTile(17, 11, sheet)
tiles[5555] = newTile(18, 11, sheet)  -- pink tree

local function generateTransitionTiles(a, b, x, y)
  -- Generate transition tiles given tiletypes a and b and the x, y index in
  -- the tileset of the upper left corner of the transition block.
  -- Type b in the corners
  local ul = tonumber(b .. a .. a .. a)
  local ur = tonumber(a .. b .. a .. a)
  local lr = tonumber(a .. a .. b .. a)
  local ll = tonumber(a .. a .. a .. b)
  tiles[ul] = newTile(x+5, y+5, sheet)
  tiles[ur] = newTile(x, y+5, sheet)
  tiles[lr] = newTile(x, y, sheet)
  tiles[ll] = newTile(x+5, y, sheet)

  -- Type a in the corners
  ul = tonumber(a .. b .. b .. b)
  ur = tonumber(b .. a .. b .. b)
  lr = tonumber(b .. b .. a .. b)
  ll = tonumber(b .. b .. b .. a)
  tiles[ul] = newTile(x+2, y+2, sheet)
  tiles[ur] = newTile(x+1, y+2, sheet)
  tiles[lr] = newTile(x+1, y+1, sheet)
  tiles[ll] = newTile(x+2, y+1, sheet)

  -- Half and Half
  local q = tonumber(b .. a .. a .. b)
  local r = tonumber(a .. b .. b .. a)
  local s = tonumber(a .. a .. b .. b)
  local t = tonumber(b .. b .. a .. a)
  tiles[q] = newTile(x+5, y+1, sheet)
  tiles[r] = newTile(x, y+1, sheet)
  tiles[s] = newTile(x+1, y, sheet)
  tiles[t] = newTile(x+1, y+5, sheet)

  -- Saddles
  q = tonumber(a .. b .. a .. b)
  r = tonumber(b .. a .. b .. a)
  tiles[q] = newTile(x+1, y+3, sheet)
  tiles[r] = newTile(x+2, y+3, sheet)
end

generateTransitionTiles(2, 1, 7, 6)  -- Dirt to water transitions
generateTransitionTiles(3, 2, 0, 0)  -- Grass to dirt
generateTransitionTiles(3, 1, 0, 6)  -- Grass to water
--generateTransitionTiles(3, 4, 13, 0) -- Dark dirt to grass

return tileset
