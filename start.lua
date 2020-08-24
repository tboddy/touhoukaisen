local images, currentMenu, movingMenu, menu, selecting, startedBgm, showingControls, showedControls, controlClock

local function load()
  images = g.images('start', {'bg', 'title', 'titletop', 'controller'})
  menu = {'1P START', 'CONTROLS', 'FULLSCREEN', 'QUIT'}
  currentMenu = 1
  sound.playBgm('startintro')
end

local function selectMenuItem()
  if not selecting then
    if currentMenu == 1 then
      loadGame()
      sound.stopBgm()
    elseif currentMenu == 2 then
      movingMenu = false
      controlClock = 0
      showedControls = false
      showingControls = true
    elseif currentMenu == 3 then
      if g.fullscreen then
        g.scale = 1
        love.window.setMode(g.width * g.scale, g.height * g.scale, {vsync = false})
        love.window.setFullscreen(false, 'desktop')
        g.fullscreen = false
        g.saveTable.fullscreen = false
        local saveStr = bitser.dumps(g.saveTable)
        love.filesystem.write('score.lua', saveStr)
      else
        g.doFullscreen()
        g.saveTable.fullscreen = true
        local saveStr = bitser.dumps(g.saveTable)
        love.filesystem.write('score.lua', saveStr)
      end
    elseif currentMenu == 4 then love.event.quit() end
  end
end

local function updateMenu()
  if (controls.up() or controls.w()) and not movingMenu then
    currentMenu = currentMenu - 1
    movingMenu = true
  elseif (controls.down() or controls.s()) and not movingMenu then
    currentMenu = currentMenu + 1
    movingMenu = true
  elseif not (controls.up() or controls.w()) and not controls.down() and not controls.s() then movingMenu = false end
  if currentMenu < 1 then currentMenu = #menu
  elseif currentMenu > #menu then currentMenu = 1 end
  if (controls.k() or controls.j() or controls.l() or controls.i() or controls.bomb() or controls.z()) and not selecting then
    selectMenuItem()
    selecting = true
  elseif not controls.k() and not controls.j() and not controls.l() and not controls.i() and not controls.bomb() then selecting = false end
end

local function update()
  if showingControls then
    -- lol
    if showedControls then
      if controls.k() or controls.j() or controls.l() or controls.i() or controls.bomb() and not selecting then
        showingControls = false
        selecting = true
      elseif not controls.k() and not controls.j() and not controls.l() and not controls.i() and not controls.bomb() then
        selecting = false
      end
    else
      -- WHAT IS GOING ON NO TIME!
      if controlClock >= 30 then showedControls = true end
      controlClock = controlClock + 1
    end
  else updateMenu() end
  if startedBgm and not sound.playingBgm then
    sound.playBgm('start')
  end
  startedBgm = true
end

local function drawTitle()
  local x, y = g.width / 2 - images.title:getWidth() / 2, g.grid * 5
  love.graphics.setColor(g.colors.black)
  love.graphics.draw(images.title, x + 1, y + 1)
  love.graphics.setColor(g.colors.green)
  love.graphics.draw(images.title, x, y)
  love.graphics.setColor(g.colors.yellow)
  love.graphics.draw(images.titletop, x, y)
  love.graphics.setColor(g.colors.white)
end

local function drawMenu()
  drawTitle()
  love.graphics.setFont(g.fontBig)
  local yOffset = g.grid * 2.5
  local y = g.grid * 12.75
  for i = 1, #menu do
    local labelObj = {input = menu[i], y = y, x = 0, align = {width = g.width, type = 'center'}}
    if i == currentMenu then labelObj.color = 'green' end
    chrome.drawLabel(labelObj)
    if i == currentMenu then
      labelObj.color = 'yellow'
      labelObj.transparent = true
      chrome.drawLabel(labelObj)
    end
    y = y + yOffset
  end
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'クレジット', x = 0, y = g.height - g.grid * 2 + 3, align = {type = 'right', width = g.width - g.grid * 6}})
  love.graphics.setFont(g.font)
  chrome.drawLabel({input = '2020 T.B.', x = 0, y = g.height - g.grid * 2, align = {type = 'right', width = g.width - g.grid}})
  love.graphics.setFont(g.fontBig)
  chrome.drawLabel({input = 'HIGH SCORE: ' .. g.processScore(g.highScore), y = g.height - g.grid * 5, align = {type = 'center'}})
  love.graphics.setFont(g.font)
end

local function drawControls()
  love.graphics.setColor(g.colors.black)
  g.mask('most', function() love.graphics.rectangle('fill', 0, 0, g.width, g.height) end)
  love.graphics.setColor(g.colors.white)
  local function str(eStr, jStr, sX, sY)
    love.graphics.setFont(g.font)
    if jStr then eStr = eStr .. ' /' end
    chrome.drawLabel({input = eStr, x = sX - g.width, y = sY, align = {type = 'right', width = g.width}})
    if jStr then
      love.graphics.setFont(g.fontJapan)
      chrome.drawLabel({input = jStr, x = sX + 6, y = sY + 4})
    end
  end

  local y = g.grid * 12.5
  love.graphics.draw(images.controller, g.width / 2, y, 0, 1, 1, images.controller:getWidth() / 2)
  y = y - g.grid * 2
  local offset = g.grid * 8
  local jOffset = 3
  -- str('Left Bumper', false, g.grid * 6.5 + offset, y)
  -- str('Right Bumper', false, g.width - g.grid * 6.5 - offset, y)

  chrome.drawLabel({input = 'L BUMPER', x = offset, y = y})
  chrome.drawLabel({input = 'L BUMPER', x = offset, y = y, transparent = 'true', color = 'yellow'})
  chrome.drawLabel({input = 'R BUMPER', x = 0, y = y, align = {type = 'right', width = g.width - offset}})
  chrome.drawLabel({input = 'R BUMPER', x = 0, y = y, transparent = 'true', color = 'yellow', align = {type = 'right', width = g.width - offset}})
  
  y = y + g.grid + 2
  chrome.drawLabel({input = 'Bomb/', x = offset, y = y})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'ボム', x = offset + g.grid * 2.5 + 2, y = y + jOffset})
  love.graphics.setFont(g.font)
  chrome.drawLabel({input = 'Bomb/', x = -g.grid * 1.5, y = y, align = {type = 'right', width = g.width - offset}})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'ボム', x = 0, y = y + jOffset, align = {type = 'right', width = g.width - offset + 1}})
  love.graphics.setFont(g.font)

  y = y - 10
  offset = g.grid * 14.25
  chrome.drawLabel({input = 'SELECT', x = offset, y = y})
  chrome.drawLabel({input = 'SELECT', x = offset, y = y, transparent = 'true', color = 'yellow'})
  chrome.drawLabel({input = 'START', y = y, align = {type = 'right', width = g.width - offset}})
  chrome.drawLabel({input = 'START', y = y, transparent = 'true', color = 'yellow', align = {type = 'right', width = g.width - offset}})

  y = y + g.grid + 2
  chrome.drawLabel({input = 'Retry/', x = offset, y = y})
  chrome.drawLabel({input = 'Pause/', y = y, align = {type = 'right', width = g.width - offset - g.grid * 2.25}})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'リトライ', x = offset + g.grid * 3.25, y = y + jOffset})
  chrome.drawLabel({input = 'ポーズ', y = y + jOffset, align = {type = 'right', width = g.width - offset + 1}})
  love.graphics.setFont(g.font)

  offset = g.grid * 4
  y = g.grid * 16.75
  chrome.drawLabel({input = 'D-PAD', x = offset, y = y})
  chrome.drawLabel({input = 'D-PAD', x = offset, y = y, transparent = 'true', color = 'yellow'})
  chrome.drawLabel({input = 'A/B/X/Y', y = y, align = {type = 'right', width = g.width - offset}})
  chrome.drawLabel({input = 'A/B/X/Y', y = y, transparent = 'true', color = 'yellow', align = {type = 'right', width = g.width - offset}})

  y = y + g.grid + 2
  chrome.drawLabel({input = 'Move/', x = offset, y = y})
  chrome.drawLabel({input = 'Shoot/', y = y, align = {type = 'right', width = g.width - offset - g.grid * 2.25}})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'リトライ', x = offset + g.grid * 2.5 + 2, y = y + jOffset})
  chrome.drawLabel({input = 'ショット', y = y + jOffset, align = {type = 'right', width = g.width - offset + 1}})
  love.graphics.setFont(g.font)

  y = g.grid * 26
  offset = g.grid * 14.25
  chrome.drawLabel({input = 'L STICK', x = offset, y = y})
  chrome.drawLabel({input = 'R STICK', y = y, align = {type = 'right', width = g.width - offset}})

  y = y + g.grid + 2
  chrome.drawLabel({input = 'Move/', x = offset, y = y})
  chrome.drawLabel({input = 'Shoot/', y = y, align = {type = 'right', width = g.width - offset - g.grid * 2.25}})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'リトライ', x = offset + g.grid * 2.5 + 2, y = y + jOffset})
  chrome.drawLabel({input = 'ショット', y = y + jOffset, align = {type = 'right', width = g.width - offset + 1}})
  love.graphics.setFont(g.font)

  local x = g.grid * 2
  y = g.grid * 2

  chrome.drawLabel({input = 'W, A, S, D: Move/', x = x, y = y})
  chrome.drawLabel({input = 'W, A, S, D:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'リトライ', x = x + g.grid * 8.75, y = y + jOffset})
  love.graphics.setFont(g.font)
  y = y + g.grid + 2
  chrome.drawLabel({input = 'I, J, K, L: Shoot/', x = x, y = y})
  chrome.drawLabel({input = 'I, J, K, L:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'ショット', x = x + g.grid * 9.25, y = y + jOffset})
  love.graphics.setFont(g.font)
  y = y + g.grid + 2
  chrome.drawLabel({input = 'SPACE: Bomb/', x = x, y = y})
  chrome.drawLabel({input = 'SPACE:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'ボム', x = x + g.grid * 6.25, y = y + jOffset})
  love.graphics.setFont(g.font)
  y = y + g.grid + 2
  chrome.drawLabel({input = 'P: Pause/', x = x, y = y})
  chrome.drawLabel({input = 'P:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'ポーズ', x = x + g.grid * 4.75, y = y + jOffset})
  love.graphics.setFont(g.font)
  y = y + g.grid + 2
  chrome.drawLabel({input = 'Q: Retry/', x = x, y = y})
  chrome.drawLabel({input = 'Q:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = 'リトライ', x = x + g.grid * 4.75, y = y + jOffset})
  love.graphics.setFont(g.font)
  y = y + g.grid + 2
  chrome.drawLabel({input = 'ESC: Quit/', x = x, y = y})
  chrome.drawLabel({input = 'ESC:', x = x, y = y, color = 'yellow', transparent = true})
  love.graphics.setFont(g.fontJapan)
  chrome.drawLabel({input = '終了/ゲーム中断', x = x + g.grid * 5.25, y = y + jOffset})
  love.graphics.setFont(g.font)

  y = g.grid * 2
  x = g.grid * 2

  chrome.drawLabel({input = 'Press shoot or bomb to return to menu', y = y, align = {type = 'right', width = g.width - x}})
  chrome.drawLabel({input = 'Press shoot or bomb to return to menu', y = y, color = 'yellow', transparent = true, align = {type = 'right', width = g.width - x}})
  y = y + g.grid * 1.5
  love.graphics.setFont(g.fontJapanBig)
  chrome.drawLabel({input = 'ショット: タイトルへ', y = y, align = {type = 'right', width = g.width - x}})
  chrome.drawLabel({input = 'ショット: タイトルへ', y = y, color = 'yellow', transparent = true, align = {type = 'right', width = g.width - x}})
  love.graphics.setFont(g.font)
end

local function draw()
  love.graphics.draw(images.bg, 0, 0)
  if showingControls then drawControls()
  else drawMenu() end
end

return {
  load = load,
  update = update,
  draw = draw
}
