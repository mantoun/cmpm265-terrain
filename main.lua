local terrain = require 'terrain'

-- Keyboard and mouse controls and debug text
local controls, stats, controlsStr, statsStr
local debugStr = ""
local debugText = true       -- Whether to draw the controls on the screen
local debugInterval = 1/10   -- Time between updates
local debugTimer = 0

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
    key="k",
    description="scale -",
    control=function()
      terrain.scale = terrain.scale - .5
      terrain.createMap()
    end
  }, {
    key="l",
    description="scale +",
    control=function()
      terrain.scale = terrain.scale + .5
      terrain.createMap()
    end
  }, {
    key="o",
    description="age -",
    control=function()
      terrain.age = terrain.age - .1
      terrain.createMap()
    end
  }, {
    key="p",
    description="age +",
    control=function()
      terrain.age = terrain.age + .1
      terrain.createMap()
    end
  }, {
    key="n",
    description="octaves -",
    control=function()
      terrain.octaves = math.max(terrain.octaves - 1, 1)
      terrain.createMap()
    end
  }, {
    key="m",
    description="octaves +",
    control=function()
      terrain.octaves = terrain.octaves + 1
      terrain.createMap()
    end
  }, {
    key=",",
    description="persistence -",
    control=function()
      terrain.persistence = math.max(terrain.persistence - .1, 0)
      terrain.createMap()
    end
  }, {
    key=".",
    description="persistence +",
    control=function()
      terrain.persistence = terrain.persistence + .1
      terrain.createMap()
    end
  }, {
    key="q",
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
      if v.key == "k" then
        d = ("%s [%s]"):format(d, terrain.scale)
      elseif v.key == "n" then
        d = ("%s [%s]"):format(d, terrain.octaves)
      elseif v.key == "," then
        d = ("%s [%s]"):format(d, terrain.persistence)
      end
      table.insert(controlsList, ("%s\t%s"):format(v.key, d))
    end
    controlsStr = table.concat(controlsList, '\n')
    debugStr = ("%s\n\n%s"):format(statsStr, controlsStr)
    debugTimer = 0
  end
end

function love.draw()
  -- Draw debug text
  if debugText then
    love.graphics.setColor({255, 255, 255})
    love.graphics.print(debugStr, 20, 20)
  end
  terrain.draw()
end

function love.keypressed(key, unicode)
  -- Handle keystrokes
  for i,v in ipairs(controls) do
    if key == v.key then v.control() end
  end
end
