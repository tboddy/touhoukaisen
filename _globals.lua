math.tau = math.pi * 2
math.phi = 1.618033988749895

local function colors()
  local colorsTable = {
    black = '0d080d',
    brownDark = '4f2b24',
    brown = '825b31',
    brownLight = 'c59154',
    yellowDark = 'f0bd77',
    yellow = 'fbdf9b',
    offWhite = 'fff9e4',
    gray = 'bebbb2',
    green = '7bb24e',
    blueLight = '74adbb',
    blue = '4180a0',
    blueDark = '32535f',
    purple = '2a2349',
    redDark = '7d3840',
    red = 'c16c5b',
    redLight = 'e89973',
    white = 'ffffff'
  }
  local output = {}
  for color, v in pairs(colorsTable) do
    local _, _, r, g, b, a = colorsTable[color]:find('(%x%x)(%x%x)(%x%x)')
    output[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
  return output
end

local function colorsLo()
  local colorsTable = {
    offWhite = 'f0f0dc',
    yellow = 'fac800',
    green = '10c840',
    blue = '00a0c8',
    red = 'd24040',
    brown = 'a0694b',
    gray = '736464',
    black = '101820',
    white = 'ffffff'
  }
  local output = {}
  for color, v in pairs(colorsTable) do
    local _, _, r, g, b, a = colorsTable[color]:find('(%x%x)(%x%x)(%x%x)')
    output[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
  return output
end

local function images(dir, files)
  local arr = {}
  for i = 1, #files do arr[files[i]] = love.graphics.newImage('img/' .. dir .. '/' .. files[i] .. '.png') end
  for img, file in pairs(arr) do arr[img]:setFilter('nearest', 'nearest') end
  return arr
end

local function processScore(input)
  local score = tostring(input)
  for i = 1, 5 - #score do score = '0' .. score end
  return score
end

local function getAngle(a, b)
  return math.atan2(b.y - a.y, b.x - a.x)
end

local function getDistance(a, b)
  return  math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
end

local function getIndex(arr)
  local index = 1
  local found = false
  for i = 1, #arr do
    if not arr[i].active and not found then
      found = true
      index = i
    end
  end
  return index
end

local function slowEntity(entity, limit, mod)
  if entity.speed > limit then entity.speed = entity.speed - mod
  elseif entity.speed < limit then entity.speed = limit end
end

local function doFullscreen()
  local fullscreenWidth, fullscreenHeight = love.window.getDesktopDimensions()
  g.scale = math.floor(fullscreenHeight / g.height)
  love.window.setMode(g.width * g.scale, g.height * g.scale, {vsync = false})
  love.window.setFullscreen(true, 'desktop')
  g.fullscreen = true
end

local function restart()
  if g.fullscreen then
    g.scale = 1
    love.window.setMode(g.width * g.scale, g.height * g.scale, {vsync = false})
    love.window.setFullscreen(false, 'desktop')
    g.fullscreen = false
    love.event.quit('restart')
  else love.event.quit('restart') end
end

return {
  scale = 2,
  width = 320,
  height = 240,
  gameWidth = 240,
  gameHeight = 240,
  loaded = false,
  gameOver = false,
  started = false,
  clock = 0,
  colors = colors(),
  colorsLo = colorsLo(),
  paused = false,
  processScore = processScore,
  getAngle = getAngle,
  getDistance = getDistance,
  getIndex = getIndex,
  limit = 1 / 60,
  score = 0,
  bobInterval = 60 * 4,
  highScore = 0,
  grid = 16,
  font = love.graphics.newFont('fonts/Gold Box 8x8 Monospaced.ttf', 8),
  -- font = love.graphics.newFont('fonts/jamma.ttf', 13),
  -- fontBig = love.graphics.newFont('fonts/jamma.ttf', 13 * 2),
  fontJapan = love.graphics.newFont('fonts/jackey.ttf', 12),
  -- fontJapanBig = love.graphics.newFont('fonts/jackey.ttf', 12 * 2),
  images = images,
  dualStick = true,
  slowEntity = slowEntity,
  animateInterval = 12,
  changingZones = true,
  pauseClock = 0,
  -- changingZoneClock = 60 * 3.5,
  changingZoneClock = 60 * .5,
  doFullscreen = doFullscreen,
  fullscreen = false,
  restart = restart
}
