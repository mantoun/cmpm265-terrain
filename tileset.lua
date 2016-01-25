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
local function newQuad(x, y, tileset)
  local tx, ty = tileset:getDimensions()
  return love.graphics.newQuad(x*ts, y*ts, ts, ts, tx, ty)
end
local function newTile(x, y, tileset)
  return {tileset, newQuad(x, y, tileset)}
end
--[[ tileset_1.png
local land = love.graphics.newImage('textures/tileset_1.png')
local water = love.graphics.newImage('textures/water_1.png')
-- Tiles store a reference to the texture atlas and the appropriate quad. We
-- could get away with just the quad if there were only a single atlas.
tiles[1111] = {water, newQuad(0, 0, water)}
tiles[2222] = {land, newQuad(4, 1, land)}
tiles[3333] = {land, newQuad(1, 1, land)}
tiles[4444] = {land, newQuad(4, 11, land)}
tiles[5555] = {land, newQuad(7, 1, land)}

tiles[1122] = {land, newQuad(4, 0, land)}
tiles[1222] = {land, newQuad(3, 0, land)}

tiles[2112] = {land, newQuad(5, 1, land)}

tiles[3323] = {land, newQuad(9, 0, land)}
tiles[3322] = {land, newQuad(10, 0, land)}
tiles[3332] = {land, newQuad(11, 0, land)}
tiles[2332] = {land, newQuad(11, 1, land)}
tiles[2333] = {land, newQuad(11, 2, land)}
--]]

local sheet = love.graphics.newImage('textures/sheet.png')
tiles[1111] = newTile(4, 7, sheet)
tiles[2222] = newTile(4, 4, sheet)
tiles[3333] = newTile(6, 6, sheet)
-- TODO: pick
tiles[4444] = newTile(6, 2, sheet)
tiles[4444] = newTile(17, 11, sheet)
tiles[5555] = newTile(10, 2, sheet)  -- dark dirt

-- Water to dirt
tiles[1112] = newTile(9, 7, sheet)
tiles[1121] = newTile(8, 7, sheet)
tiles[2111] = newTile(9, 8, sheet)
tiles[1211] = newTile(8, 8, sheet)

tiles[1122] = newTile(11, 11, sheet)
tiles[2211] = newTile(8, 6, sheet)
tiles[2112] = newTile(7, 7, sheet)
tiles[1221] = newTile(12, 7, sheet)
tiles[1212] = newTile(9, 9, sheet)
tiles[2121] = newTile(8, 9, sheet)

tiles[2212] = newTile(7, 6, sheet)
tiles[2122] = newTile(7, 11, sheet)
tiles[2221] = newTile(12, 6, sheet)
tiles[1222] = newTile(12, 11, sheet)

-- Grass to dirt
tiles[3323] = newTile(0, 0, sheet)
tiles[2333] = newTile(5, 5, sheet)
tiles[3332] = newTile(5, 0, sheet)
tiles[3233] = newTile(0, 5, sheet)

tiles[3322] = newTile(1, 0, sheet)
tiles[2233] = newTile(1, 5, sheet)
tiles[3223] = newTile(0, 3, sheet)
tiles[2332] = newTile(5, 2, sheet)
tiles[2323] = newTile(2, 4, sheet)
tiles[3232] = newTile(3, 4, sheet)

tiles[2232] = newTile(1, 1, sheet)
tiles[2223] = newTile(2, 1, sheet)
tiles[3222] = newTile(2, 2, sheet)
tiles[2322] = newTile(1, 2, sheet)

--[[
local function generateTransitionTiles(t1, t2)
  -- Corners
  tiles[2232] = newTile(1, 1, sheet)
  tiles[2223] = newTile(2, 1, sheet)
  tiles[3222] = newTile(2, 2, sheet)
  tiles[2322] = newTile(1, 2, sheet)
end
--]]

return tileset
