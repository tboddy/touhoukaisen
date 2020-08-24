local size, types, images, explosions

local function load()
  size = 32
  types = {'blue', 'red', 'gray'}
  images = {}
  explosions = {}
  for i = 1, 256 do explosions[i] = {} end
  for i = 1, #types do
    images[types[i]] = {}
    for j = 0, 4 do images[types[i]][j] = love.graphics.newImage('img/explosion/' .. types[i] .. tostring(j) .. '.png') end
  for img, file in pairs(images[types[i]]) do images[types[i]][img]:setFilter('nearest', 'nearest') end
  end
end

local function spawn(opts)
  if (opts.enemy and stage.killBulletClock == 0) or not opts.enemy then
  	local exp = explosions[g.getIndex(explosions)]
    exp.active = true
    exp.x = opts.x
    exp.y = opts.y
    exp.current = 0
    exp.clock = 0
    if opts.type then exp.type = opts.type else exp.type = 'blue' end
    if opts.shadow then exp.shadow = true else exp.shadow = false end
    if opts.big then
      exp.xScale = 2
      exp.yScale = 2
    else
      exp.xScale = 1
      exp.yScale = 1
    end
    if opts.random then
      local randomMod = g.grid * 2
      exp.x = exp.x - randomMod + randomMod * 2 * math.random()
      exp.y = exp.y - randomMod + randomMod * 2 * math.random()
    end
    if math.random() < .5 then exp.xScale = exp.xScale * -1 end
    if math.random() < .5 then exp.yScale = exp.yScale * -1 end
  end
end

local function updateExplosion(exp)
  local interval = 4
  if exp.clock == interval then exp.current = 1
  elseif exp.clock == interval * 2 then exp.current = 2
  elseif exp.clock == interval * 3 then exp.current = 3
  elseif exp.clock == interval * 4 then exp.current = 4
  elseif exp.clock == interval * 5 then exp.active = false end
  exp.clock = exp.clock + 1
end

local function update()
  if not g.paused then
    for i = 1, #explosions do if explosions[i].active then updateExplosion(explosions[i]) end end
  end
end

local function drawExplosion(exp)
  local x, y = exp.x + g.grid - player.cameraX, exp.y + g.grid - player.cameraY
  if exp.shadow then
    local sSize = size
    if exp.current == 0 then sSize = size / 2
    elseif exp.current == 1 or exp.current == 3 then sSize = size / 4 * 3
    elseif exp.current == 4 then sSize = size / 4 end
    if exp.type == 'red' then love.graphics.setColor(g.colors.redLight)
    else love.graphics.setColor(g.colors.blueLight) end
    g.mask('quarter', function() love.graphics.circle('fill', x, y, sSize / 4 * 3) end)
    g.mask('half', function() love.graphics.circle('fill', x, y, sSize / 2) end)
    love.graphics.setColor(g.colors.white)
  end
  love.graphics.draw(images[exp.type][exp.current], x, y, 0, exp.xScale, exp.yScale, size / 2, size / 2)
end

local function draw()
  for i = 1, #explosions do if explosions[i].active and explosions[i].big then drawExplosion(explosions[i]) end end
  for i = 1, #explosions do if explosions[i].active and not explosions[i].big then drawExplosion(explosions[i]) end end
end

return {
  load = load,
  update = update,
  spawn = spawn,
  draw = draw
}
