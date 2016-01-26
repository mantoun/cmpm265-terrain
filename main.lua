local terrain = require 'terrain'

-- Keyboard and mouse controls and debug text
local controls, stats, controlsStr, statsStr
local debugStr = ""
local debugText = true       -- Whether to draw the controls on the screen
local debugInterval = 1/10   -- Time between updates
local debugTimer = 0

local timestep = .01    -- how much to age the map each keypress

function love.load()
  love.keyboard.setKeyRepeat(true)
  -- Initialize controls
  controls = {{
  -- TODO: supply seed
  --  key="m",
  --  description="regenerate map",
  --  control=function() terrain.createMap() end
  --}, {
    key="x",
    description="show debug text",
    control=function() debugText = not debugText end
  }, {
    key="z",
    description="regenerate map",
    control=function()
      terrain.origin = {math.random(512), math.random(512)}
      terrain.seed = os.time()
      terrain.createMap()
    end
  }, {
    key="q",
    description="scale +",
    control=function()
      terrain.scale = terrain.scale + .25
      terrain.createMap()
    end
  }, {
    key="a",
    description="scale -",
    control=function()
      terrain.scale = terrain.scale - .25
      terrain.createMap()
    end
  }, {
    key="w",
    description="octaves +",
    control=function()
      terrain.octaves = terrain.octaves + 1
      terrain.createMap()
    end
  }, {
    key="s",
    description="octaves -",
    control=function()
      terrain.octaves = math.max(terrain.octaves - 1, 1)
      terrain.createMap()
    end
  }, {
    key="e",
    description="persistence +",
    control=function()
      terrain.persistence = terrain.persistence + .02
      terrain.createMap()
    end
  }, {
    key="d",
    description="persistence -",
    control=function()
      terrain.persistence = math.max(terrain.persistence - .02, 0)
      terrain.createMap()
    end
  }, {
    key="r",
    description="age +",
    control=function()
      terrain.age = terrain.age + timestep
      terrain.createMap()
    end
  }, {
    key="f",
    description="age -",
    control=function()
      terrain.age = terrain.age - timestep
      terrain.createMap()
    end
  }, {
    key="t",
    description="timestep +",
    control=function() timestep = timestep + .01 end
  }, {
    key="g",
    description="timestep -\n",
    control=function() timestep = timestep - .01 end
  }, {
    key="up",
    description="move map",
    control=function()
      terrain.offset[1] = terrain.offset[1] - .1
      terrain.createMap()
    end
  }, {
    key="down",
    description="",
    control=function()
      terrain.offset[1] = terrain.offset[1] + .1
      terrain.createMap()
    end
  }, {
    key="left",
    description="",
    control=function()
      terrain.offset[2] = terrain.offset[2] - .1
      terrain.createMap()
    end
  }, {
    key="right",
    description="\n",
    control=function()
      terrain.offset[2] = terrain.offset[2] + .1
      terrain.createMap()
    end
  }, {
    key="escape",
    description="quit",
    control=function() love.event.push("quit") end
  }}
  -- Generate an initial map
  terrain.createMap()
end

function love.update(dt)
  -- Update debug text if it's time
  debugTimer = debugTimer + dt
  if debugText and debugTimer > debugInterval then
    -- TODO: don't need fps
    stats = {
      ('fps %s'):format(love.timer.getFPS()),
    }
    statsStr = table.concat(stats, '\n')
    -- Regenerate the controls list to reflect current config values
    local controlsList = {}
    for i,v in ipairs(controls) do
      local d = v.description
      if v.key == "q" then
        d = ("%s [%s]"):format(d, terrain.scale)
      elseif v.key == "w" then
        d = ("%s [%s]"):format(d, terrain.octaves)
      elseif v.key == "e" then
        d = ("%s [%s]"):format(d, terrain.persistence)
      elseif v.key == "t" then
        d = ("%s [%s]"):format(d, timestep)
      end
      table.insert(controlsList, ("%s\t%s"):format(v.key, d))
    end
    controlsStr = table.concat(controlsList, '\n')
    debugStr = ("%s\n\n%s"):format(statsStr, controlsStr)
    debugTimer = 0
  end
end

function love.draw()
  terrain.draw()
  -- Draw debug text
  if debugText then
    love.graphics.setColor({255, 255, 255})
    love.graphics.print(debugStr, 20, 20)
  end
end

function love.keypressed(key, unicode)
  -- Handle keystrokes
  for i,v in ipairs(controls) do
    if key == v.key then v.control() end
  end
end
