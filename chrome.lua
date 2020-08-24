local images, rotations, flips, bossBarQuad, gameOverClock

local function load()
  images = g.images('chrome', {'frame', 'frametop', 'beachball', 'beachballshadow', 'heart', 'beware', 'bossbar'})
  images.bossbar:setWrap('repeat')
  bossBarQuad = love.graphics.newQuad(0, 0, 0, 0, images.bossbar:getDimensions())
  rotations = {}
  flips = {}
  local mod = math.pi / 25
  for i = 1, 64 do
    rotations[i] = -mod + mod * 2 * math.random()
    flips[i] = 1; if math.random() < .5 then flips[i] = -1 end
  end
  gameOverClock = 0
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
  local color = g.colors.offWhite
  local align = 'left'
  local limit = g.width
  local x = 0
  if opts.x then x = opts.x end
  if opts.color then color = g.colors[opts.color] end
  if opts.align then
    align = opts.align.type
    if opts.align.width then limit = opts.align.width end
  end
  love.graphics.setColor(g.colors.black)
  if opts.transparent then
    g.mask('half', function()
      love.graphics.printf(opts.input, x + 1, opts.y + 1, limit, align)
      love.graphics.setColor(color)
      love.graphics.printf(opts.input, x, opts.y, limit, align)
    end)
  else
    love.graphics.printf(opts.input, x + 1, opts.y + 1, limit, align)
    love.graphics.setColor(color)
    love.graphics.printf(opts.input, x, opts.y, limit, align)
  end
  love.graphics.setColor(g.colors.white)
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
  love.graphics.setColor(g.colors.black)
  love.graphics.draw(images.frame, 0, 0)
  love.graphics.setColor(g.colors.purple)
  love.graphics.draw(images.frametop, 0, 0)
  love.graphics.setColor(g.colors.white)
end

local function drawScore()
  local highScore = g.highScore; if g.score > g.highScore then highScore = g.score end
  local x, y = g.grid * 2 + g.gameWidth, g.grid
  drawLabel({input = 'HI SCORE   ' .. g.processScore(highScore), x = x, y = y})
  y = y + g.grid * 1.25
  drawLabel({input = 'SCORE      ' .. g.processScore(g.score), x = x, y = y})
  y = y + g.grid * 1.5
  drawLabel({input = 'EXTEND AT   +50000', x = x, y = y})
end

local function drawBoss()
  local x, y = g.grid * 2 + g.gameWidth, g.grid * 18.5 - 3 - 4
  local width, height = g.width - x - g.grid - 1, g.grid
  love.graphics.setColor(g.colors.black)
  love.graphics.rectangle('fill', x - 3, y - 3, width + 6, height + 6)
  love.graphics.setColor(g.colors.purple)
  love.graphics.rectangle('fill', x - 2, y - 2, width + 4, height + 4)
  love.graphics.setColor(g.colors.black)
  love.graphics.rectangle('fill', x - 1, y - 1, width + 2, height + 2)
  local barWidth = math.floor(stage.oni.health / stage.oniMax * width)
  love.graphics.setColor(g.colors.green)
  love.graphics.rectangle('fill', x, y, barWidth, height)
  bossBarQuad:setViewport(0, 0, barWidth, height)
  love.graphics.setColor(g.colors.yellow)
  love.graphics.draw(images.bossbar, bossBarQuad, x, y)
  love.graphics.setColor(g.colors.white)
  if stage.oni.active then
    x = x + 3
    y = y - images.beware:getHeight() - 12
    love.graphics.setColor(g.colors.black)
    love.graphics.draw(images.beware, x + 1, y + 1)
    love.graphics.setColor(g.colors.yellow)
    love.graphics.draw(images.beware, x, y)
    love.graphics.setColor(g.colors.green)
    g.mask('half', function() love.graphics.draw(images.beware, x, y) end)
    love.graphics.setColor(g.colors.white)
  end
end

local function drawMapEntities()
  local x, eSize = g.grid * 2 + g.gameWidth, 3
  local size = g.width - g.grid - x - 1
  local y = g.height - size - g.grid

  local function drawEntity(entity, type)
    local color = g.colors.blueLight
    if type == 'shell' then color = g.colors.yellowDark
    elseif type == 'bakebake' then color = g.colors.green
    elseif type == 'player' then color = g.colors.gray
    elseif type == 'oni' then
      color = g.colors.offWhite
      eSize = 5
    end
    love.graphics.setColor(color)
    local mod = size / (g.gameWidth * 3)
    local eX, eY = entity.x - player.cameraX + g.gameWidth, entity.y - player.cameraY + g.gameHeight
    eX = eX * mod + x - eSize / 2
    eY = eY * mod + y - eSize / 2
    if eX >= x - eSize / 2 and eX <= x + size - eSize / 2 and
      eY >= y - eSize / 2 and eY <= y + size - eSize / 2 then
      love.graphics.rectangle('fill', eX, eY, eSize, eSize)
    end
  end

  g.mask('half', function()
    for i = 1, #stage.faries do if stage.faries[i].active then drawEntity(stage.faries[i], 'fairy') end end
    for i = 1, #stage.shells do if stage.shells[i].active then drawEntity(stage.shells[i], 'shell') end end
    for i = 1, #stage.bakebakes do if stage.bakebakes[i].active then drawEntity(stage.bakebakes[i], 'bakebake') end end
    drawEntity(player, 'player')
    if stage.oni.active then drawEntity(stage.oni, 'oni') end
  end)

  love.graphics.setColor(g.colors.white)
end

local function drawMap()
  local x = g.grid * 2 + g.gameWidth
  local size = g.width - g.grid - x - 1
  local y = g.height - size - g.grid
  love.graphics.setColor(g.colors.black)
  love.graphics.rectangle('fill', x - 3, y - 3, size + 6, size + 6)
  love.graphics.setColor(g.colors.purple)
  love.graphics.rectangle('fill', x - 2, y - 2, size + 4, size + 4)
  love.graphics.setColor(g.colors.black)
  love.graphics.rectangle('fill', x - 1, y - 1, size + 2, size + 2)
  love.graphics.rectangle('fill', x, y, size, size)
  drawMapEntities()
  local gridSize = size / 3
  local offset = size / 2 - gridSize / 2
  -- offset = 0
  love.graphics.setColor(g.colors.purple)
  g.mask('half', function() love.graphics.rectangle('line', x + offset, y + offset, gridSize + 1, gridSize + 1) end)
end

local function drawLives()
  local x, y = g.grid * 2 + g.gameWidth + 8, g.grid * 6.25
  if player.lives > 0 then
    for i = 1, player.lives do
      love.graphics.setColor(g.colors.black)
      love.graphics.draw(images.heart, x + 1, y + 1, rotations[i], 1, 1, images.heart:getWidth() / 2, images.heart:getHeight() / 2)
      love.graphics.setColor(g.colors.redLight)
      love.graphics.draw(images.heart, x, y, rotations[i], 1, 1, images.heart:getWidth() / 2, images.heart:getHeight() / 2)
      x = x + g.grid * 1.25 + 1
    end
  end
  love.graphics.setColor(g.colors.white)
end

local function drawBeachballs()
  local startX, y = g.grid * 2 + g.gameWidth + 8, g.grid * 8 + 2
  local x = startX
  if player.bombs > 0 then
    for i = 1, player.bombs do
      love.graphics.draw(images.beachballshadow, x + 1, y + 1, rotations[i], flips[i], 1, images.beachball:getWidth() / 2, images.beachball:getHeight() / 2)
      love.graphics.draw(images.beachball, x, y, rotations[i], flips[i], 1, images.beachball:getWidth() / 2, images.beachball:getHeight() / 2)
      x = x + g.grid * 1.25 + 1
      if i % 7 == 0 then
        y = y + 20
        x = startX
      end
    end
  else
    x = g.grid * 2 + g.gameWidth
    drawLabel({input = 'NO BOMBS', x = x, y = y - 8})
  end
end

local function drawStatus()
  local x, y, width = g.grid, g.grid + g.gameHeight / 2 - 8, g.gameWidth
  if chrome.currentStatusSub then y = y - g.grid * 1.5 end
  love.graphics.setFont(g.fontBig)
  drawLabel({input = chrome.currentStatus, color = 'yellow', x = x, y = y, align = {type = 'center', width = width}})
  drawLabel({input = chrome.currentStatus, transparent = true, x = x, y = y, align = {type = 'center', width = width}})
  if chrome.currentStatusSub then
    y = y + g.grid * 2.5
    drawLabel({input = chrome.currentStatusSub, x = x, y = y, align = {type = 'center', width = width}})
  end
  love.graphics.setFont(g.font)
end

local function drawPaused()
  local x, y, width, interval, str = g.grid, g.grid + g.gameHeight / 2 - 8, g.gameWidth, 90, 'Paused'
  love.graphics.setFont(g.fontBig)
  if g.pauseClock % interval > interval / 2 then drawLabel({input = str, x = x, y = y, transparent = true, align = {type = 'center', width = width}})
  else drawLabel({input = str, x = x, y = y, align = {type = 'center', width = width}}) end
  love.graphics.setFont(g.font)
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
  if g.gameOver then -- dont mind me
    drawLabel({input = 'PRESS ANY BUTTON', y = math.floor(g.height / 3) * 2, x = g.grid, align = {type = 'center', width = g.gameWidth}})
    drawLabel({input = 'PRESS ANY BUTTON', y = math.floor(g.height / 3) * 2, x = g.grid, color = 'yellow', transparent = 'true', align = {type = 'center', width = g.gameWidth}})
  end
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update,
  currentStatus = false,
  currentStatusSub = false
}