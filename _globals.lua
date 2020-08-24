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

local function images(dir, files)
  local arr = {}
  for i = 1, #files do arr[files[i]] = love.graphics.newImage('img/' .. dir .. '/' .. files[i] .. '.png') end
  for img, file in pairs(arr) do arr[img]:setFilter('nearest', 'nearest') end
  return arr
end

local function processScore(input)
  local score = tostring(input)
  for i = 1, 7 - #score do score = '0' .. score end
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

local masks = {
  half = love.graphics.newImage('img/masks/half.png'),
  quarter = love.graphics.newImage('img/masks/quarter.png'),
  blob = love.graphics.newImage('img/masks/blob.png'),
  most = love.graphics.newImage('img/masks/most.png')
}

local maskShader = love.graphics.newShader([[vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){ if(Texel(texture, texture_coords).rgb == vec3(0.0)) {discard;} return vec4(1.0); }]])
local function doMask(mask, callback)
  love.graphics.stencil(function()
    love.graphics.setShader(maskShader)
    love.graphics.draw(masks[mask], 0, 0)
    return love.graphics.setShader()
  end, 'replace', 1)
  love.graphics.setStencilTest('greater', 0)
  callback()
  love.graphics.setStencilTest()
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
  scale = 1,
  width = 640,
  height = 480,
  gameWidth = 448,
  gameHeight = 448,
  loaded = false,
  gameOver = false,
  started = false,
  clock = 0,
  colors = colors(),
  paused = false,
  processScore = processScore,
  getAngle = getAngle,
  getDistance = getDistance,
  getIndex = getIndex,
  limit = 1 / 60,
  score = 0,
  highScore = 0,
  grid = 16,
  maskShader = maskShader,
  mask = doMask,
  font = love.graphics.newFont('fonts/jamma.ttf', 13),
  fontBig = love.graphics.newFont('fonts/jamma.ttf', 13 * 2),
  fontJapan = love.graphics.newFont('fonts/jackey.ttf', 12),
  fontJapanBig = love.graphics.newFont('fonts/jackey.ttf', 12 * 2),
  images = images,
  dualStick = true,
  slowEntity = slowEntity,
  animateInterval = 12,
  changingZones = true,
  pauseClock = 0,
  changingZoneClock = 60 * 3.5,
  doFullscreen = doFullscreen,
  fullscreen = false,
  restart = restart
}
