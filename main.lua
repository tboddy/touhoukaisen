bitser = require 'bitser'
g = require '_globals'
controls = require 'controls'
background = require 'background'
graze = require 'graze'
stage = require 'stage'
player = require 'player'
chrome = require 'chrome'
start = require 'start'
explosion = require 'explosion'
sound = require 'sound'

local container
local tickRate = 1 / 60

function loadGame()
  background.load()
  player.load()
  graze.load()
  stage.load()
  explosion.load()
  chrome.load()
  g.loaded = true
  if not g.started then g.started = true end
end

local function loadScore()
  local scoreData = love.filesystem.read('score.lua')
  if scoreData then
    g.saveTable = bitser.loads(scoreData)
    if g.saveTable.score then g.highScore = g.saveTable.score end
    if g.saveTable.fullscreen and (g.saveTable.fullscreen == true or g.saveTable.fullscreen == 'true') then g.doFullscreen() end
  else g.saveTable = {} end
end

function love.load()
	math.randomseed(1419)
  love.window.setTitle('東方海星')
	container = love.graphics.newCanvas(g.width, g.height)
	container:setFilter('nearest', 'nearest')
	love.window.setMode(g.width * g.scale, g.height * g.scale, {vsync = false})
	love.graphics.setFont(g.font)
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  loadScore()
  controls.load()
  sound.load()
  if g.started then loadGame()
  else start.load() end
end

function love.update()
  if controls.quit() then love.event.quit()
  elseif controls.reload() then g.restart() end
  sound.update()
  if g.started then
    controls.update()
    background.update()
    player.update()
    stage.update()
    graze.update()
    explosion.update()
    chrome.update()
    g.clock = g.clock + 1
  else
    start.update()
  end
end

function love.draw()
  container:renderTo(love.graphics.clear)
  love.graphics.setCanvas({container, stencil = true})
  if g.started then
    background.draw()
    player.draw()
    stage.draw()
    graze.draw()
    explosion.draw()
    player.drawHitbox()
    chrome.draw()
  else
    start.draw()
  end
  love.graphics.setCanvas()
  local windowX, windowY = 0
  local fullscreenWidth, fullscreenHeight = love.window.getDesktopDimensions()
  if g.fullscreen then
    windowX = fullscreenWidth / 2 - g.width / 2 * g.scale
    windowY = fullscreenHeight / 2 - g.height / 2 * g.scale
  end
  love.graphics.draw(container, windowX, windowY, 0, g.scale, g.scale)
end

function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end
  local lag = 0.0
  return function()
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == 'quit' then if not love.quit or not love.quit() then return a or 0 end end
        love.handlers[name](a,b,c,d,e,f)
      end
    end
    if love.timer then lag = math.min(lag + love.timer.step(), tickRate * 25) end
    while lag >= tickRate do
      if love.update then love.update(tickRate) end
      lag = lag - tickRate
    end
    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      if love.draw then love.draw() end
      love.graphics.present()
    end
    if love.timer then love.timer.sleep(0.001) end
  end
end