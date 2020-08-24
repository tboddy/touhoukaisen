local images, wingScale, bullets, killBulletClock, killBulletLimit, bulletAnimateInterval, bulletAnimateMax, bossOutroPlaying, pausing

local function loadZones()
  stage.zones = {
    {name = 'FAIRIE'},
    {name = 'BAKEBAKE'},
    {name = 'SEASHELL'},
    {name = 'VOID'}
  }
end

local function load()
  images = g.images('stage', {'onibottom', 'onishadow', 'onishadow2', 'onihead', 'onilines', 'onilinesshadow', 'fairydown', 'fairydownwing', 'bakebake', 'bakebakeover', 'shell1', 'shell1over', 'shell2', 'shell2over',
    'shell3', 'shell3over', 'shell1outline', 'shell2outline', 'shell3outline'})
  wingScale = 1
  for i = 1, stage.sectionCount * stage.sectionCount * 2 do
    stage.faries[i] = {}
    stage.shells[i] = {}
    stage.bakebakes[i] = {}
  end
  bullets = {}
  local types = {'small', 'big', 'bolt', 'arrow', 'pill'}
  for i = 1, 640 do bullets[i] = {} end
  for i = 1, #types do
    for j = 1, 4 do
      images[types[i] .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. j .. '.png')
      images[types[i] .. j]:setFilter('nearest')
    end
  end
  killBulletClock = 0
  killBulletLimit = 90
  bulletAnimateInterval = 8
  bulletAnimateMax = bulletAnimateInterval * 4
  loadZones()
  pausing = false
end

local function randomX(x)
  return x + math.floor(math.random() * g.gameWidth)
end

local function randomY(y)
  return y + math.floor(math.random() * g.gameHeight)
end

local offsetDistance = g.gameWidth * 2
local function getOffsetAngle()
  local angle = math.tau * math.random()
  local x, y = player.x + math.cos(angle) * offsetDistance, player.y + math.sin(angle) * offsetDistance
  local offset = g.gameWidth / 2
  if x >= player.x - offset and x <= player.x + offset and y >= player.y - offset and y <= player.y + offset then
    return getOffsetAngle()
  else return angle end
end

local function spawnFairy(x, y)
  local fairy = stage.faries[g.getIndex(stage.faries)]
  fairy.active = true
  fairy.health = 8
  fairy.clock = 0
  fairy.flags = {}
  fairy.hit = false
  fairy.seen = false
  fairy.initSpeed = .75
  fairy.speed = fairy.initSpeed
  fairy.x = randomX(x)
  fairy.y = randomY(y)
  fairy.idleAngle = math.tau * math.random()
  fairy.mineClock = 0
end

local function spawnNewFairy(fairy)
  local offsetAngle = getOffsetAngle()
  fairy.x = player.x + math.cos(offsetAngle) * offsetDistance
  fairy.y = player.y + math.sin(offsetAngle) * offsetDistance
  fairy.active = true
  fairy.health = 8
  fairy.clock = 0
  fairy.flags = {}
  fairy.hit = false
  fairy.seen = false
  fairy.speed = fairy.initSpeed
  fairy.mineClock = 0
end

local function spawnBakebake(x, y)
  local bakebake = stage.bakebakes[g.getIndex(stage.bakebakes)]
  bakebake.active = true
  bakebake.health = 16
  bakebake.clock = math.floor(math.random() * (60 * 2))
  bakebake.flags = {}
  bakebake.hit = false
  bakebake.seen = false
  bakebake.initSpeed = .5
  bakebake.speed = bakebake.initSpeed
  bakebake.x = randomX(x)
  bakebake.y = randomY(y)
  bakebake.startPattern = math.floor(math.random() * 3) + 1
end

local function spawnNewBakebake(bakebake)
  local offsetAngle = getOffsetAngle()
  bakebake.x = player.x + math.cos(offsetAngle) * offsetDistance
  bakebake.y = player.y + math.sin(offsetAngle) * offsetDistance
  bakebake.active = true
  bakebake.health = 16
  bakebake.clock = math.floor(math.random() * (60 * 2))
  bakebake.flags = {}
  bakebake.hit = false
  bakebake.seen = false
  bakebake.speed = bakebake.initSpeed
  bakebake.startPattern = math.floor(math.random() * 3) + 1
end

local function spawnShell(x, y)
  local shell = stage.shells[g.getIndex(stage.shells)]
  shell.active = true
  shell.health = 6
  shell.clock = 0
  shell.hit = false
  shell.seen = false
  shell.x = randomX(x)
  shell.y = randomY(y)
  shell.rotation = math.tau * math.random()
  local rand = math.random()
  shell.img = 1; if rand >= 1 / 3 and rand < 1 / 3 * 2 then shell.img = 2 elseif rand >= 1 / 3 * 2 then shell.img = 3 end
  shell.flipped = false; if math.random() < .5 then shell.flipped = true end
end

local function spawnNewShell(shell)
  local offsetAngle = getOffsetAngle()
  shell.x = player.x + math.cos(offsetAngle) * offsetDistance
  shell.y = player.y + math.sin(offsetAngle) * offsetDistance
  shell.active = true
  shell.health = 6
  shell.clock = 0
  shell.hit = false
  shell.seen = false
  shell.rotation = math.tau * math.random()
  local rand = math.random()
  shell.img = 1; if rand >= 1 / 3 and rand < 1 / 3 * 2 then shell.img = 2 elseif rand >= 1 / 3 * 2 then shell.img = 3 end
  shell.flipped = false; if math.random() < .5 then shell.flipped = true end
end

local function spawnBullet(initFunc, updateFunc)
  if killBulletClock == 0 then
    local bullet = bullets[g.getIndex(bullets)]
    bullet.active = true
    bullet.rotation = 0
    bullet.top = false
    bullet.clock = 0
    bullet.grazed = false
    bullet.flags = {}
    bullet.speed = 0
    bullet.angle = 0
    initFunc(bullet)
    bullet.width = images[bullet.type .. '1']:getWidth()
    bullet.height = images[bullet.type .. '1']:getHeight()
    -- bullet.width = bullet.width * 2
    -- bullet.height = bullet.height * 2
    if updateFunc then bullet.updateFunc = updateFunc else bullet.updateFunc = false end
  end
end

local function updateSeen(entity, isOni)
  entity.seen = false
  local mod = g.gameWidth / 2 + g.grid * 2
  if isOni then mod = g.gameWidth / 2 + images.onibottom:getHeight() / 2 end
  if entity.x >= player.x - mod and entity.x <= player.x + mod and entity.y >= player.y - mod and entity.y <= player.y + mod then
    entity.seen = true
  end
end

local function spawnOni()
  stage.oni.active = true
  stage.oni.seen = false
  stage.oni.ready = false
  stage.oni.dead = false
  stage.oni.clock = 0
  stage.oni.currentPattern = math.floor(math.random() * 3) + 1
  stage.oni.flags = {}
  sound.playBgm('bossintro')
end

local function killOni()
  stage.killBullets = true
  stage.oni.health = 0
  stage.oni.active = false
  sound.playBgm('bossoutro')
  bossOutroPlaying = true
  g.changingZones = true
  stage.currentZone = stage.currentZone + 1
  if stage.currentZone > #stage.zones then stage.currentZone = 1 end
  g.score = g.score + 5000
end

local oniPatterns = {

  function()
    local function rings(opposite)
      local count = 19
      local angleLimit = math.pi / 5 * 3
      local angle = stage.oni.flags.bulletAngle - angleLimit
      if opposite then
        angle = angle + math.pi / count
        -- count = count - 1
      end
      explosion.spawn({x = stage.oni.flags.bulletPos.x, y = stage.oni.flags.bulletPos.y, big = true, type = 'red'})
      sound.playSfx('bullet1')
      for i = 0, count do
        if angle <= stage.oni.flags.bulletAngle + angleLimit then
          spawnBullet(function(bullet)
            bullet.x = stage.oni.flags.bulletPos.x
            bullet.y = stage.oni.flags.bulletPos.y
            bullet.angle = angle
            bullet.speed = 6
            bullet.type = 'arrow'
          end, function(bullet)
            if bullet.flags.flipped and bullet.speed < 3.5 then
              bullet.speed = bullet.speed + .1
            elseif not bullet.flags.flipped then
              g.slowEntity(bullet, 0, .2)
              if bullet.speed <= 0 then bullet.flags.flipped = true end
            end
          end)
        end
        angle = angle + math.tau / count
      end
      local speed = 25
      stage.oni.flags.bulletPos.x = stage.oni.flags.bulletPos.x + math.cos(stage.oni.flags.bulletAngle) * speed
      stage.oni.flags.bulletPos.y = stage.oni.flags.bulletPos.y + math.sin(stage.oni.flags.bulletAngle) * speed
    end
    local function burst()
      sound.playSfx('bullet2')
      for i = 1, 13 do
        spawnBullet(function(bullet)
          bullet.x = stage.oni.x
          bullet.y = stage.oni.y
          bullet.top = true
          local mod = math.pi / 3
          bullet.angle = g.getAngle(stage.oni, player) - mod + mod * 2 * math.random()
          bullet.speed = 3 + math.random()
          if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
          bullet.flags.minSpeed = bullet.speed - 1
        end, function(bullet)
          g.slowEntity(bullet, bullet.flags.minSpeed, .1)
        end)
      end
    end
    local interval = 30
    local limit = interval * 2
    local max = limit * 3
    local top = interval * 3.5
    if stage.oni.clock % max == 0 then
      stage.oni.flags.bulletPos = {x = stage.oni.x, y = stage.oni.y}
      stage.oni.flags.bulletAngle = g.getAngle(stage.oni, player)
    end
    if stage.oni.clock % interval == 0 and stage.oni.clock % max < limit then rings(stage.oni.clock % (interval * 2) == 0) end
    if stage.oni.clock % max == top then burst() end
  end,

  function()
    local interval = 10
    local limit = interval * 2
    local max = limit * 2
    local function bulletsA()
      if stage.oni.clock % max == 0 then
        stage.oni.flags.bulletAngleA = math.tau * math.random()
        stage.oni.flags.bulletAngleB = math.tau * math.random()
        stage.oni.flags.bulletTargetAngle = g.getAngle(stage.oni, player)
      end
      local function spawnBullets(opposite)
        sound.playSfx('bullet3')
        local count = 7
        local angle = stage.oni.flags.bulletAngleA
        local diff, diffAngle, diffMod = g.grid * 9, stage.oni.flags.bulletTargetAngle, math.pi / 2
        local x = stage.oni.x
        local y = stage.oni.y
        if opposite then
          diffMod = -diffMod
          angle = stage.oni.flags.bulletAngleB
        end
        x = x + math.cos(stage.oni.flags.bulletTargetAngle + diffMod) * diff
        y = y + math.sin(stage.oni.flags.bulletTargetAngle + diffMod) * diff
        explosion.spawn({x = x, y = y, big = true, type = 'red'})
        for i = 1, count do
          spawnBullet(function(bullet)
            bullet.x = x
            bullet.y = y
            bullet.angle = angle
            bullet.speed = 3.5
            bullet.type = 'big'
          end)
          angle = angle + math.tau / count
        end
        local mod = .05
        stage.oni.flags.bulletAngleB = stage.oni.flags.bulletAngleB + mod
        stage.oni.flags.bulletAngleA = stage.oni.flags.bulletAngleA - mod
      end
      if stage.oni.clock % interval == 0 and stage.oni.clock % max < limit then spawnBullets(stage.oni.clock % (max * 2) >= max) end
    end
    local function bulletsB()
      if stage.oni.clock % max == limit then
        stage.oni.flags.bulletAngleC = math.tau * math.random()
        stage.oni.flags.bulletAngleD = math.tau * math.random()
        stage.oni.flags.bulletTargetAngleB = g.getAngle(stage.oni, player)
      end
      local function spawnBullets(opposite)
        sound.playSfx('bullet2')
        local count = 9
        local angle = stage.oni.flags.bulletAngleC

        local diff, diffAngle, diffMod = g.grid * 5, stage.oni.flags.bulletTargetAngleB, math.pi / 2
        local x = stage.oni.x
        local y = stage.oni.y
        if opposite then
          diffMod = -diffMod
          angle = stage.oni.flags.bulletAngleB
        end

        x = x + math.cos(stage.oni.flags.bulletTargetAngle + diffMod) * diff
        y = y + math.sin(stage.oni.flags.bulletTargetAngle + diffMod) * diff

        explosion.spawn({x = x, y = y, big = true, type = 'red'})
        for i = 1, count do
          spawnBullet(function(bullet)
            bullet.x = x
            bullet.y = stage.oni.y
            bullet.angle = angle
            bullet.speed = 3
            bullet.type = 'arrow'
            bullet.top = true
          end)
          angle = angle + math.tau / count
        end
        local mod = math.phi * 2
        stage.oni.flags.bulletAngleC = stage.oni.flags.bulletAngleC + mod
        stage.oni.flags.bulletAngleD = stage.oni.flags.bulletAngleD - mod
      end
      if stage.oni.clock % interval == 0 and stage.oni.clock % max >= max / 2 + interval and stage.oni.clock % max < max + limit + interval then spawnBullets(stage.oni.clock % (max * 2) >= limit + max) end
    end
    bulletsA()
    bulletsB()
  end,

  function()
    local function ring()
      local function spawnBullets(opposite)
        local angle = stage.oni.flags.ringAngle
        local count = 13
        local mod = 2
        sound.playSfx('bullet1')
        for i = 1, count do
          local diff = math.cos(angle * mod)
          if opposite then diff = math.cos((angle + math.pi / 2) * mod) end
          diff = diff / 2
          spawnBullet(function(bullet)
            bullet.x = stage.oni.x
            bullet.y = stage.oni.y
            bullet.angle = angle
            bullet.speed = 3.5 - diff
            bullet.type = 'big'
          end)
          angle = angle + math.tau / count
        end
        stage.oni.flags.ringAngle = stage.oni.flags.ringAngle + math.phi
      end
      local interval = 45
      if stage.oni.clock % interval == 0 then
        if not stage.oni.flags.ringAngle then stage.oni.flags.ringAngle = 0 end
        spawnBullets(stage.oni.clock % (interval * 2) == 0)
      end
    end
    local function arrows()
      local function spawnBullets()
        local count = 3
        local diff = math.pi / 20
        local angle = stage.oni.arrowAngle - diff * math.floor(count / 2)
        local speed = 2.75
        sound.playSfx('bullet3')
        for i = 1, count do
          spawnBullet(function(bullet)
            bullet.x = stage.oni.x
            bullet.y = stage.oni.y
            bullet.angle = angle
            bullet.speed = speed
            bullet.type = 'arrow'
            bullet.top = true
          end)
          angle = angle + diff
          local mod = .5
          if i > math.floor(count / 2) then speed = speed - mod
          else speed = speed + mod end
        end
        stage.oni.arrowAngle = stage.oni.arrowAngle - math.pi / 4
      end
      local interval = 15
      local limit = interval * 4
      local max = limit * 1.5
      if stage.oni.clock % interval == 0 and stage.oni.clock % max < limit then 
        if stage.oni.clock % max == 0 then
          stage.oni.arrowAngle = g.getAngle(stage.oni, player) + (math.pi / 4) * 1.5
        end
        spawnBullets()
      end
    end
    ring()
    arrows()
  end

}

local function updateOni()
  local function move()
    local angle
    if stage.oni.active then
      angle = g.getAngle(stage.oni, player)
      local speed, distance = 6, g.getDistance(stage.oni, player)
      if distance <= g.grid * 22 then speed = 3.5 end
      if distance <= g.grid * 13 then
        speed = 2
        stage.oni.ready = true
      end
      if distance <= g.grid * 11 then speed = 0 end
      stage.oni.x = stage.oni.x + math.cos(angle) * speed
      stage.oni.y = stage.oni.y + math.sin(angle) * speed
    else
      local distanceMod = g.gameWidth * 10
      stage.oni.x = player.x + math.cos(stage.oni.spawnAngle) * distanceMod
      stage.oni.y = player.y + math.cos(stage.oni.spawnAngle) * distanceMod
    end
  end
  local function shot()
    local max, limit = 60 * 6, 60 * 4.5
    if stage.oni.clock % max == 0 and stage.oni.clock > 0 then
      stage.oni.currentPattern = stage.oni.currentPattern + 1
      if stage.oni.currentPattern > #oniPatterns then stage.oni.currentPattern = 1 end
    end
    if stage.oni.clock % max < limit then oniPatterns[stage.oni.currentPattern]() end
    stage.oni.clock = stage.oni.clock + 1
  end
  if stage.oni.active and stage.oni.ready then shot() end
  move()
  if stage.oni.active then
    updateSeen(stage.oni, true)
    if stage.oni.dead then killOni() end
    if not sound.playingBgm then
      sound.playBgm('boss')
    end
  end
end

local function getFairyTarget(fairy)
  local target, distance
  for i = 1, #stage.shells do if stage.shells[i].active then
    local cDistance = g.getDistance(fairy, stage.shells[i])
    if (target and cDistance < distance) or not target then
      target = stage.shells[i]
      distance = cDistance
    end
  end end
  return target
end

local function updateFairy(fairy)
  local killed = false
  updateSeen(fairy)
  local target, angle = getFairyTarget(fairy), fairy.idleAngle
  if target and not stage.oni.active then
    local distance, targetAngle = g.getDistance(fairy, target), g.getAngle(fairy, target)
    local limit, slowLimit = g.grid * 6, g.grid * 4
    if distance >= slowLimit then
      fairy.speed = fairy.initSpeed / 2
      if distance >= limit then fairy.speed = fairy.initSpeed end
      angle = targetAngle
    else
      fairy.speed = 0
      if fairy.mineClock % 15 == 0 then
        local eX, eY = fairy.x + math.cos(targetAngle) * (distance / 2), fairy.y + math.sin(targetAngle) * (distance / 2)
        explosion.spawn({x = eX, y = eY})
        target.hit = true
      end
      fairy.mineClock = fairy.mineClock + 1
    end
  elseif not target or stage.oni.active then
    fairy.speed = fairy.initSpeed / 2
  end
  if fairy.seen then
    for i = 1, #player.bullets do if player.bullets[i].active and player.bullets[i].seen and not player.bullets[i].bomb then
      local bullet = player.bullets[i]
      local size = 32 / 2
      if math.sqrt((bullet.x - fairy.x) * (bullet.x - fairy.x) + (bullet.y - fairy.y) * (bullet.y - fairy.y)) < size + images.fairydown:getHeight() / 2 then
        fairy.health = fairy.health - 1
        if fairy.seen then
          explosion.spawn({x = bullet.x, y = bullet.y})
          sound.playSfx('explosion1')
        end
        bullet.active = false
        if fairy.health <= 0 then killed = true end
      end
    end end
  end
  fairy.x = fairy.x + math.cos(angle) * fairy.speed
  fairy.y = fairy.y + math.sin(angle) * fairy.speed
  if killed then
    explosion.spawn({x = fairy.x, y = fairy.y, big = 'true'})
    if fairy.seen then sound.playSfx('explosion2') end
    g.score = g.score + 500
    spawnNewFairy(fairy)
  elseif not fairy.seen then
    local pDistance = g.getDistance(fairy, player)
    if(pDistance / g.gameWidth) > 2 then spawnNewFairy(fairy) end
  end
end

local function updateBakebake(bakebake)
  local killed = false
  updateSeen(bakebake)
  local function move()
    local distance = g.getDistance(bakebake, player)
    if distance > g.grid * 5 then
      local speed, angle = bakebake.speed, g.getAngle(bakebake, player)
      bakebake.x = bakebake.x + math.cos(angle) * speed
      bakebake.y = bakebake.y + math.sin(angle) * speed
    end
  end
  local function shot()
    local patterns = {
      function()
        local count, angle = 7, g.getAngle(bakebake, player)
        for i = 1, count do
          spawnBullet(function(bullet)
            bullet.x = bakebake.x
            bullet.y = bakebake.y
            bullet.angle = angle
            bullet.speed = 2.5
            bullet.type = 'big'
          end)
          angle = angle + math.tau / count
        end
      end,
      function()
        local function spawnBullets(opposite)
          local count, angle = 5, g.getAngle(bakebake, player)
          for i = 1, count do
            spawnBullet(function(bullet)
              bullet.x = bakebake.x
              bullet.y = bakebake.y
              bullet.angle = angle
              bullet.speed = 2.5
              bullet.type = 'small'
              if opposite then
                bullet.angle = bullet.angle + math.tau / count / 2
                bullet.speed = 1.5
              end
            end)
            angle = angle + math.tau / count
          end
          sound.playSfx('bullet3')
        end
        spawnBullets()
        spawnBullets(true)
      end,
      function()
        local mod = math.pi / 20
        local angle = g.getAngle(bakebake, player) - mod
        for i = 1, 3 do
          spawnBullet(function(bullet)
            bullet.x = bakebake.x
            bullet.y = bakebake.y
            bullet.angle = angle
            bullet.speed = 2
            bullet.type = 'arrow'
            if i == 2 then bullet.speed = 2.5 end
          end)
          angle = angle + mod
        end
      end
    }
    local interval = 120
    if bakebake.clock % interval == interval / 2 and bakebake.clock > 0 then
      patterns[bakebake.startPattern]()
      sound.playSfx('bullet3')
      bakebake.startPattern = bakebake.startPattern + 1
      if bakebake.startPattern > 3 then bakebake.startPattern = 1 end
    end
  end
  move()
  if bakebake.seen then
    shot()
    for i = 1, #player.bullets do if player.bullets[i].active and player.bullets[i].seen and not player.bullets[i].bomb then
      local bullet = player.bullets[i]
      local size = 32 / 2
      if math.sqrt((bullet.x - bakebake.x) * (bullet.x - bakebake.x) + (bullet.y - bakebake.y) * (bullet.y - bakebake.y)) < size + images.fairydown:getHeight() / 2 then
        bakebake.health = bakebake.health - 1
        if bakebake.seen then
          explosion.spawn({x = bullet.x, y = bullet.y})
          sound.playSfx('explosion1')
        end
        bullet.active = false
        if bakebake.health <= 0 then killed = true end
      end
    end end
  end
  bakebake.clock = bakebake.clock + 1
  if killed then
    g.score = g.score + 2000
    explosion.spawn({x = bakebake.x, y = bakebake.y, big = 'true'})
    if bakebake.seen then sound.playSfx('explosion2') end
    spawnNewBakebake(bakebake)
  elseif not bakebake.seen then
    local pDistance = g.getDistance(bakebake, player)
    if(pDistance / g.gameWidth) > 2 then spawnNewBakebake(bakebake) end
  end
end

local function updateShell(shell)
  local killedByPlayer = false
  updateSeen(shell)
  if shell.hit then
    shell.health = shell.health - 1
    shell.hit = false
    if shell.seen then
      sound.playSfx('explosion1')
    end
  end
  if shell.seen then
    for i = 1, #player.bullets do if player.bullets[i].active and player.bullets[i].seen and not player.bullets[i].bomb then
      local bullet = player.bullets[i]
      local size = 32 / 2
      if math.sqrt((bullet.x - shell.x) * (bullet.x - shell.x) + (bullet.y - shell.y) * (bullet.y - shell.y)) < size + images['shell' .. shell.img]:getHeight() / 2 then
        shell.health = shell.health - 1
        if shell.seen then
          explosion.spawn({x = bullet.x, y = bullet.y})
          sound.playSfx('explosion1')
        end
        bullet.active = false
        if shell.health <= 0 then killedByPlayer = true end
      end
    end end
  else
    local pDistance = g.getDistance(shell, player)
    if(pDistance / g.gameWidth) > 2 then spawnNewShell(shell) end
  end
  if shell.health <= 0 then
    if shell.seen then sound.playSfx('explosion2') end
    if killedByPlayer then
      g.score = g.score + 150
      player.bombs = player.bombs + 1
    elseif not stage.oni.active then
      if stage.oni.health < stage.oniMax then stage.oni.health = stage.oni.health + 1 end
      if stage.oni.health >= stage.oniMax then spawnOni() end
    end
    explosion.spawn({x = shell.x, y = shell.y, big = 'true'})
    -- explosion.spawn({x = shell.x, y = shell.y, big = 'true', random = true, wait = 1})
    spawnNewShell(shell)
  end
end

local function updateBullet(bullet)
  if bullet.updateFunc then bullet.updateFunc(bullet) end
  bullet.x = bullet.x + math.cos(bullet.angle) * bullet.speed
  bullet.y = bullet.y + math.sin(bullet.angle) * bullet.speed
  if bullet.clock % bulletAnimateMax < bulletAnimateInterval then bullet.animateIndex = 1
  elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval and bullet.clock % bulletAnimateMax < bulletAnimateInterval * 2 then bullet.animateIndex = 2
  elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval * 2 and bullet.clock % bulletAnimateMax < bulletAnimateInterval * 3 then bullet.animateIndex = 3
  elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval * 3 then bullet.animateIndex = 4 end
  if string.find(bullet.type, 'bolt') or string.find(bullet.type, 'arrow') or string.find(bullet.type, 'pill') then bullet.rotation = bullet.angle end
  if killBulletClock > 0 then
    explosion.spawn({x = bullet.x, y = bullet.y, type = 'red'})
    bullet.active = false
  end
  if g.getDistance(bullet, player) >= 1200 then bullet.active = false end
  if bullet.active and player.invulnerableClock == 0 and not g.gameOver and not g.changingZones and not g.paused then
    local didGraze = false
    local size = bullet.height * 1.25
    if math.sqrt((player.x - bullet.x) * (player.x - bullet.x) + (player.y - bullet.y) * (player.y - bullet.y)) < size then
      if not bullet.grazed then didGraze = {x = bullet.x, y = bullet.y} end
      bullet.grazed = true
      size = bullet.height / 3
      if math.sqrt((player.x - bullet.x) * (player.x - bullet.x) + (player.y - bullet.y) * (player.y - bullet.y)) < size then
        player.getHit(bullet)
        didGraze = false
      end
    end
  if didGraze then
    g.score = g.score + 10
    local gAngle = g.getAngle(player, didGraze)
    graze.spawn({x = didGraze.x, y = didGraze.y}, gAngle)
  end
  end
  bullet.clock = bullet.clock + 1
end

local function spawnZone()

  player.x = g.gameWidth / 2
  player.y = g.gameHeight / 2
  player.cameraX = 0
  player.cameraY = 0

  for i = 1, #stage.faries do stage.faries[i].active = false end
  for i = 1, #stage.bakebakes do stage.bakebakes[i].active = false end
  for i = 1, #stage.shells do stage.shells[i].active = false end
  local mod = stage.sectionCount / 2 - 1
  local xOffset, yOffset, y = mod * g.gameWidth, mod * g.gameHeight, 0
  for i = 1, stage.sectionCount do
    local x = 0
    for j = 1, stage.sectionCount do
      local eX, eY = x - xOffset, y - yOffset
      if stage.currentZone == 1 then -- fairy
        spawnFairy(eX, eY)
        spawnShell(eX, eY)
        if j % 2 == 1 and i % 3 == 1 then spawnBakebake(eX, eY) end
      elseif stage.currentZone == 2 then -- bakebake
        spawnShell(eX, eY)
        if j % 2 == 1 then spawnFairy(eX, eY) end
        if j % 2 == 1 then spawnBakebake(eX, eY) end
      elseif stage.currentZone == 3 then -- seashell
        spawnShell(eX, eY)
        if j % 2 == 1 then spawnFairy(eX, eY) end
        if j % 2 == 1 and i % 3 == 1 then
          spawnShell(eX, eY)
          spawnBakebake(eX, eY)
        end
      elseif stage.currentZone == 4 then -- void
        if j % 2 == 1 and i % 3 == 1 then
          spawnFairy(eX, eY)
          spawnShell(eX, eY)
          spawnBakebake(eX, eY)
        end
      end
      x = x + g.gameWidth
    end
    y = y + g.gameHeight
  end

  if stage.currentZone == 1 then stage.oniMax = 12
  elseif stage.currentZone == 2 then stage.oniMax = 15
  elseif stage.currentZone == 2 then stage.oniMax = 15
  elseif stage.currentZone == 3 then stage.oniMax = 20 end

end

local function updateZone()
  if g.changingZones then
    chrome.currentStatus = 'NEXT ZONE'
    chrome.currentStatusSub = stage.zones[stage.currentZone].name .. ' ZONE'
    g.changingZoneClock = g.changingZoneClock - 1
    if g.changingZoneClock <= 0 then
      g.changingZones = false
      chrome.currentStatus = false
      chrome.currentStatusSub = false
      spawnZone()
    end
  else g.changingZoneClock = 60 * 3.5 end
end



local function update()
  if not g.changingZones and not g.gameOver and not g.paused then
    for i = 1, #stage.faries do if stage.faries[i].active then updateFairy(stage.faries[i]) end end
    for i = 1, #stage.shells do if stage.shells[i].active then updateShell(stage.shells[i]) end end
    for i = 1, #stage.bakebakes do if stage.bakebakes[i].active then updateBakebake(stage.bakebakes[i]) end end
    updateOni()
  end
  if not g.paused then for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end end
  if stage.killBullets then
    killBulletClock = killBulletLimit
    stage.killBullets = false
  end
  if killBulletClock > 0 then killBulletClock = killBulletClock - 1 end
  if not stage.oni.active and not sound.playingBgm then
    sound.playBgm('stage')
  end
  updateZone()
  if controls.pause() and not pausing and not g.gameOver and not g.changingZones then
    g.pauseClock = 0
    pausing = true
    if g.paused then g.paused = false else g.paused = true end -- wtf lua
  elseif not controls.pause() and pausing then pausing = false end
  g.pauseClock = g.pauseClock + 1
end

local function drawOni()
  local x, y, width, height = stage.oni.x + g.grid - player.cameraX, stage.oni.y + g.grid - player.cameraY, images.onibottom:getWidth(), images.onibottom:getHeight()
  love.graphics.draw(images.onibottom, x, y, 0, 1, 1, width / 2, height / 2)
  g.mask('half', function() love.graphics.draw(images.onilinesshadow, x, y, 0, 1, 1, width / 2, height / 2) end)
  love.graphics.draw(images.onilines, x, y, 0, 1, 1, width / 2, height / 2)
  love.graphics.draw(images.onihead, x, y, 0, 1, 1, width / 2, height / 2)
  g.mask('most', function() love.graphics.draw(images.onishadow, x, y, 0, 1, 1, width / 2, height / 2) end)
  g.mask('quarter', function() love.graphics.draw(images.onishadow2, x, y, 0, 1, 1, width / 2, height / 2) end)
end

local function drawFairy(fairy)
  local x, y = fairy.x + g.grid - player.cameraX, fairy.y + g.grid - player.cameraY
  love.graphics.draw(images.fairydown, x, y, 0, 1, 1, images.fairydown:getWidth() / 2, images.fairydown:getHeight() / 2)
  g.mask('half', function() love.graphics.draw(images.fairydownwing, x, y, 0, 1, 1, images.fairydown:getWidth() / 2, images.fairydown:getHeight() / 2) end)
end

local function drawShell(shell)
  local img, x, y = 'shell' .. shell.img, shell.x + g.grid - player.cameraX, shell.y + g.grid - player.cameraY
  local flip = 1; if shell.flipped then flip = -1 end
  love.graphics.draw(images[img], x, y, shell.rotation, flip, 1, images[img]:getWidth() / 2, images[img]:getHeight() / 2)
  g.mask('half', function() love.graphics.draw(images[img .. 'over'], x, y, shell.rotation, flip, 1, images[img]:getWidth() / 2, images[img]:getHeight() / 2) end)
  love.graphics.setColor(g.colors.white)
end

local function drawBakebake(bakebake)
  local x, y, xOff, yOff = bakebake.x + g.grid - player.cameraX, bakebake.y + g.grid - player.cameraY, images.bakebake:getWidth() / 2, images.bakebake:getHeight() / 2
  love.graphics.draw(images.bakebake, x, y, 0, 1, 1, xOff, yOff)
  g.mask('half', function() love.graphics.draw(images.bakebakeover, x, y, 0, 1, 1, xOff, yOff) end)
end

local function drawBullets()
  local function drawBullet(bullet)
    if not bullet.flags.invisible then
      love.graphics.draw(images[bullet.type .. bullet.animateIndex], bullet.x + g.grid - player.cameraX, bullet.y + g.grid - player.cameraY, bullet.rotation, 1, 1, bullet.width / 2, bullet.height / 2)
    end
  end
  for i = 1, #bullets do if bullets[i].active and not bullets[i].top then drawBullet(bullets[i]) end end
  for i = 1, #bullets do if bullets[i].active and bullets[i].top then drawBullet(bullets[i]) end end
end

local function draw()
  if not g.changingZones and not g.gameOver then
    for i = 1, #stage.faries do if stage.faries[i].seen and stage.faries[i].active then drawFairy(stage.faries[i]) end end
    for i = 1, #stage.shells do if stage.shells[i].seen and stage.shells[i].active then drawShell(stage.shells[i]) end end
    for i = 1, #stage.bakebakes do if stage.bakebakes[i].seen and stage.bakebakes[i].active then drawBakebake(stage.bakebakes[i]) end end
    if stage.oni.active and stage.oni.seen then drawOni() end
  end
  drawBullets()
end

return {
  sectionCount = 3,
  oni = {
    health = 0,
    spawnAngle = math.tau * math.random()
  },
  oniMax = 13,
  oniX = 0,
  oniY = 0,
  faries = {},
  shells = {},
  bakebakes = {},
	load = load,
	update = update,
	draw = draw,
  killBullets = false,
  updateSeen = updateSeen,
  zones = {},
  currentZone = 1
}