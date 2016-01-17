local terrain = require 'terrain'

-- Keyboard and mouse controls and debug text
local controls, stats, controlsStr, statsStr
local debugStr = ""
local debugText = true       -- Whether to draw the controls on the screen
local debugInterval = 1/10   -- Time between updates
local debugTimer = 0
local conf = {}
conf.width = 128
conf.height = 128

function love.load()
  -- Initialize controls
  controls = {{
    key="m",
    description="new map",
    control=function() terrain.createMap(conf.width, conf.height) end
  }, {
    key="x",
    description="show debug text",
    control=function() debugText = not debugText end
  }, {
    key="o",
    description="decrease age",
    control=function()
      terrain.age = terrain.age - .2
      terrain.createMap(conf.width, conf.height)
    end
  }, {
    key="p",
    description="increase age",
    control=function()
      terrain.age = terrain.age + .2
      terrain.createMap(conf.width, conf.height)
    end
  }, {
    key="q",
    description="quit",
    control=function() love.event.push("quit") end
  }}
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
    -- TODO: do the control descriptions need to be updated every frame?
    -- Regenerate the controls list to reflect current config values
    local controlsList = {}
    for i,v in ipairs(controls) do
      local d = v.description
      --if v.key == "x" then
      --  d = ("%s [%s]":format(d, tostring(debugText))
      --end
      table.insert(controlsList, ("%s %s"):format(v.key, d))
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
