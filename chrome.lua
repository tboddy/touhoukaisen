local images, rotations, flips, gameOverClock, sideWidth, sideX, sideY

local function load()
  images = g.images('chrome', {'beachball', 'heart'})
  rotations = {}
  flips = {}
  local mod = math.pi / 20
  for i = 1, 64 do
    rotations[i] = -mod + mod * 2 * math.random()
    flips[i] = 1; if math.random() < .5 then flips[i] = -1 end
  end
  gameOverClock = 0
  sideWidth = g.width - g.gameWidth
  sideX = g.gameWidth + 9
  sideY = 8
end

local savedScore, gotHigh = false, false
local function saveScore()
  g.saveTable.score = g.score
  local saveStr = bitser.dumps(g.saveTable)
  love.filesystem.write('score.lua', saveStr)
  savedScore = true
  print('saved hi score')
end

local function drawLabel(opts)
  local color = g.colorsLo.offWhite
  local align = 'left'
  local limit = g.width
  local x = 0
  if opts.x then x = opts.x end
  if opts.color then color = g.colorsLo[opts.color] end
  if opts.align then
    align = opts.align.type
    if opts.align.width then limit = opts.align.width end
  end
  love.graphics.setColor(g.colorsLo.black)
  love.graphics.printf(opts.input, x + 1, opts.y + 1, limit, align)
  love.graphics.setColor(color)
  love.graphics.printf(opts.input, x, opts.y, limit, align)
  love.graphics.setColor(g.colorsLo.white)
end

local function update()
  if g.gameOver then
    if not savedScore and g.score > g.highScore then
      saveScore()
      gotHigh = true
    end
    chrome.currentStatus = 'GAME OVER'
    if gotHigh then chrome.currentStatusSub = 'NEW  HIGH ' .. g.processScore(g.score) else
    chrome.currentStatusSub = 'SCORE ' .. g.processScore(g.score) end

    if gameOverClock >= 60 and (controls.up() or controls.down() or controls.left() or controls.right() or controls.w() or controls.a() or controls.s() or controls.d() or controls.i() or controls.j() or controls.k() or controls.l() or controls.bomb()) or
      controls.reload() or controls.pause() then
      g.restart()
    end
    gameOverClock = gameOverClock + 1
  end
end

local function drawFrame()
  love.graphics.setColor(g.colorsLo.black)
  love.graphics.rectangle('fill', g.gameWidth, 0, sideWidth, g.height)
  love.graphics.setColor(g.colorsLo.offWhite)
  love.graphics.rectangle('fill', g.gameWidth + 1, 0, 1, g.height)
  love.graphics.setColor(g.colorsLo.white)
end

local function drawScore()
  local highScore = g.highScore; if g.score > g.highScore then highScore = g.score end
  local y = sideY
  drawLabel({input = 'HI ' .. g.processScore(highScore), x = sideX, y = y})
  y = y + 12
  drawLabel({input = 'SC ' .. g.processScore(g.score), x = sideX, y = y})
  -- drawLabel({input = 'EXTEND AT   +50000', x = x, y = y})
end

local function drawBoss()
  local x, y = sideX + 2, g.grid * 9.5
  local width, height = sideWidth - g.grid - 4, 12 - 4
  love.graphics.setColor(g.colorsLo.black)
  love.graphics.rectangle('fill', x - 1, y - 1, width + 2, height + 2)
  love.graphics.setColor(g.colorsLo.red)
  love.graphics.rectangle('fill', x, y, stage.oni.health / stage.oniMax * width, height)
  love.graphics.setColor(g.colorsLo.offWhite)
  love.graphics.rectangle('line', x - 1, y - 1, width + 3, height + 3)
  love.graphics.setColor(g.colorsLo.white)
  if stage.oni.active then
    x = sideX
    y = g.grid * 8.5 + 2
    width = width + 4
    drawLabel({input = '-BEWARE-', x = x, y = y, color = 'red', align = {type = 'center', width = width}})
  end
end

local function drawMapEntities()
  local x, eSize = sideX + 1, 1
  local size = g.width - 8 - x
  local y = g.height - size - 8

  local function drawEntity(entity, type)
    local color = g.colorsLo.green
    if type == 'shell' then color = g.colorsLo.yellow
    elseif type == 'bakebake' then color = g.colorsLo.offWhite
    elseif type == 'player' then
      color = g.colorsLo.blue
      eSize = 2
    elseif type == 'oni' then
      color = g.colorsLo.offWhite
      eSize = 3
    end
    love.graphics.setColor(color)
    local mod = size / (g.gameWidth * 3)
    local eX, eY = entity.x - player.cameraX + g.gameWidth, entity.y - player.cameraY + g.gameHeight
    eX = eX * mod + x
    eY = eY * mod + y
    if eX >= x - eSize / 2 and eX <= x + size + eSize / 2 and
      eY >= y - eSize / 2 and eY <= y + size + eSize / 2 then
      love.graphics.circle('fill', eX, eY, eSize)
    end
  end

  for i = 1, #stage.faries do if stage.faries[i].active then drawEntity(stage.faries[i], 'fairy') end end
  for i = 1, #stage.shells do if stage.shells[i].active then drawEntity(stage.shells[i], 'shell') end end
  for i = 1, #stage.bakebakes do if stage.bakebakes[i].active then drawEntity(stage.bakebakes[i], 'bakebake') end end
  drawEntity(player, 'player')
  if stage.oni.active then drawEntity(stage.oni, 'oni') end
  love.graphics.setColor(g.colorsLo.white)
end

local function drawMap()
  local x = sideX + 1
  local size = g.width - 8 - x
  local y = g.height - size - 8
  love.graphics.setColor(g.colorsLo.black)
  love.graphics.rectangle('fill', x, y, size, size)
  if not g.changingZones then drawMapEntities() end
  love.graphics.setColor(g.colorsLo.offWhite)
  love.graphics.rectangle('line', x, y, size + 1, size + 1)
  local gridSize = size / 3
  local offset = size / 2 - gridSize / 2
  if not g.changingZones then
    love.graphics.setColor(g.colorsLo.gray)
    love.graphics.rectangle('line', x + offset, y + offset, gridSize + 1, gridSize + 1)
  end
  love.graphics.setColor(g.colorsLo.white)
end

local function drawLives()
  local x, y = sideX + 4, sideY + g.grid * 2
  if player.lives > 0 then
    for i = 1, 3 do
      love.graphics.setColor(g.colorsLo.red)
      love.graphics.draw(images.heart, x, y, rotations[i], flips[i], 1, images.heart:getWidth() / 2, images.heart:getHeight() / 2)
      x = x + 11
    end
  end
  love.graphics.setColor(g.colorsLo.white)
end

local function drawBeachballs()
  local startX, y = sideX + 4, sideY + g.grid * 3 - 1
  local x = startX
  if player.bombs > 0 then
    for i = 1, player.bombs do
      love.graphics.setColor(g.colorsLo.white)
      love.graphics.draw(images.beachball, x, y, rotations[i], flips[i], 1, images.beachball:getWidth() / 2, images.beachball:getHeight() / 2)
      x = x + 11
      if i % 6 == 0 then
        y = y + 12
        x = startX
      end
    end
  else drawLabel({input = 'NO BOMBS', x = x - 4, y = y - 4}) end
end

local function drawStatus()
  local x, y, width = g.grid, g.grid + g.gameHeight / 2 - 8, g.gameWidth
  if chrome.currentStatusSub then y = y - g.grid * 1.5 end
  drawLabel({input = chrome.currentStatus, color = 'yellow', x = 0, y = y, align = {type = 'center', width = g.gameWidth}})
  if chrome.currentStatusSub then
    y = y + g.grid
    drawLabel({input = chrome.currentStatusSub, x = 0, y = y, align = {type = 'center', width = g.gameWidth}})
  end
  if g.gameOver then drawLabel({input = 'PRESS ANY BUTTON', y = math.floor(g.height / 3) * 2, x = 0, align = {type = 'center', width = g.gameWidth}}) end
end

local function drawPaused()
  local x, y, width, interval, str = g.grid, g.grid + g.gameHeight / 2 - 8, g.gameWidth, 90, 'Paused'
  if g.pauseClock % interval > interval / 2 then drawLabel({input = str, x = x, y = y, transparent = true, align = {type = 'center', width = width}})
  else drawLabel({input = str, x = x, y = y, align = {type = 'center', width = width}}) end
end

local function draw()
  drawFrame()
  drawScore()
  drawBoss()
  drawMap()
  drawLives()
  drawBeachballs()
  if chrome.currentStatus then drawStatus() end
  if g.paused then drawPaused() end
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update,
  currentStatus = false,
  currentStatusSub = false
}