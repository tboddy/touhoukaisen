local images, clock, playerSpeed, playerMoveClock, canShoot, shotClock, lastBulletX, lastBulletY, bulletAngle, canBomb, bombClock, lastX

local function load()
  images = g.images('player', {'hitbox', 'bullet', 'cirno', 'bomb', 'bombtop'})
  clock = 0
  player.x = g.gameWidth / 2
  player.y = g.gameHeight / 2
  player.cameraX = 0
  player.cameraY = 0
  playerSpeed = 3
  for i = 1, 64 do player.bullets[i] = {} end
  invulnerableLimit = 60 * 3
  canShoot = true
  canBomb = true
  shotClock = 0
  bulletAngle = math.pi / 2
  bombClock = 0
  lastX = -1
end

local function updateMove()
  local xSpeed = 0
  local ySpeed = 0
  local speed = playerSpeed
  if controls.a() then
    xSpeed = -1
    lastX = 1
  elseif controls.d() then
    xSpeed = 1
    lastX = -1
  end
  if controls.w() then ySpeed = -1
  elseif controls.s() then ySpeed = 1 end
  local fSpeed = speed / math.sqrt(math.max(xSpeed + ySpeed, 1))
  local moveModX = fSpeed * xSpeed
  local moveModY = fSpeed * ySpeed
  player.cameraX = player.cameraX + moveModX
  player.cameraY = player.cameraY + moveModY
  player.x = player.x + moveModX
  player.y = player.y + moveModY
end

local function spawnBullet(isBomb)
  local diff = math.pi / 15
  local bullet = player.bullets[g.getIndex(player.bullets)]
  local offset = 4
  bullet.active = true
  bullet.angle = bulletAngle
  bullet.x = player.x + math.cos(bullet.angle) * offset
  bullet.y = player.y + math.sin(bullet.angle) * offset
  bullet.bomb = false
  bullet.speed = 0
  if isBomb then
    bullet.bomb = true
    bullet.rotation = math.tau * math.random()
    bullet.xFlip = 1; if math.random() < .5 then bullet.xFlip = -1 end
    bullet.yFlip = 1; if math.random() < .5 then bullet.yFlip = -1 end
  end
end

local function updateBombBullet(bullet)
  if stage.oni.active then
    local distance = g.getDistance(bullet, stage.oni)
    if distance <= g.grid * 5 then
      bullet.active = false
      explosion.spawn({x = bullet.x, y = bullet.y, big = true})
      stage.oni.health = stage.oni.health - 1.5
      if stage.oni.health <= 0 then
        stage.oni.dead = true
        stage.oni.health = 0
      end
    end
  end
end

local function updateBullet(bullet)
  local bulletWidth = images.bullet:getWidth()
  local bulletHeight = images.bullet:getHeight()
  local bulletSpeed = bulletWidth
  if bullet.bomb then
    if stage.oni.active then bullet.angle = g.getAngle(bullet, stage.oni) end
    bulletSpeed = bullet.speed
    if bullet.speed < 4 then bullet.speed = bullet.speed + .25 end
  end
  bullet.x = bullet.x + math.cos(bullet.angle) * bulletSpeed
  bullet.y = bullet.y + math.sin(bullet.angle) * bulletSpeed
  stage.updateSeen(bullet)
  local offset = g.gameHeight / 2 + bulletWidth / 2
  if bullet.x < player.x - offset or bullet.x > player.x + offset or bullet.y > player.y + offset or bullet.y < player.y - offset then bullet.active = false
  elseif bullet.bomb then updateBombBullet(bullet) end
end

local function updateShot()
  if controls.shooting() and canShoot then
    if controls.i() then bulletAngle = math.pi * 1.5
    else bulletAngle = math.pi / 2 end
    if controls.j() then
      bulletAngle = math.pi
      if controls.i() then bulletAngle = bulletAngle + math.pi / 4
      elseif controls.k() then bulletAngle = bulletAngle - math.pi / 4 end
    elseif controls.l()
      then bulletAngle = 0
      if controls.i() then bulletAngle = bulletAngle - math.pi / 4
      elseif controls.k() then bulletAngle = bulletAngle + math.pi / 4 end
    end
    canShoot = false
    shotClock = 0
  end
  local interval = 5
  local limit = interval * 1
  local max = limit
  if not canShoot and not g.gameOver and not g.paused then
    if shotClock % interval == 0 and shotClock < limit then
      sound.playSfx('playershot')
      spawnBullet()
    end
    shotClock = shotClock + 1
  end
  if shotClock >= max then canShoot = true end
end

local function updateBomb()
  if controls.bomb() and canBomb then
    bombClock = 0
    canBomb = false
  end
  if not canBomb and not g.gameOver and not g.paused then
    if bombClock == 0 and player.bombs > 0 then
      spawnBullet(true)
      sound.playSfx('explosion2')
      player.bombs = player.bombs - 1
    end
    bombClock = bombClock + 1
  end
  if bombClock >= 60 then canBomb = true end
end

local function getHit(bullet)
  if player.invulnerableClock == 0 and not g.gameOver then
    bullet.active = false
    explosion.spawn({x = bullet.x, y = bullet.y, type = 'red', big = true})
    stage.killBullets = true
    sound.playSfx('playerhit')
    if player.lives > 0 then
      player.lives = player.lives - 1
      player.invulnerableClock = invulnerableLimit
    else
      sound.playSfx('gameover')
      g.gameOver = true
    end
  end
end

local lastRollover = 0
local function update()
  if not g.changingZones and not g.gameOver and not g.paused then
    if player.invulnerableClock < invulnerableLimit - 15 then updateMove() end
    updateShot()
    if player.invulnerableClock > 0 then player.invulnerableClock = player.invulnerableClock - 1 end
    updateBomb()
    clock = clock + 1
  end
  for i = 1, #player.bullets do if player.bullets[i].active then updateBullet(player.bullets[i]) end end
  local extraCount = math.floor(g.score / 50000)
  if extraCount > lastRollover then
    player.lives = player.lives + 1
    lastRollover = extraCount
  end
end

local function drawBullet(bullet)
  local x, y = bullet.x + g.grid - player.cameraX, bullet.y + g.grid - player.cameraY
  if bullet.bomb then
    love.graphics.draw(images.bomb, x, y, bullet.rotation, bullet.xFlip, bullet.yFlip, images.bomb:getWidth() / 2, images.bomb:getHeight() / 2)
    g.mask('half', function()  love.graphics.draw(images.bombtop, x, y, bullet.rotation, bullet.xFlip, bullet.yFlip, images.bomb:getWidth() / 2, images.bomb:getHeight() / 2) end)
  else
    g.mask('half', function() love.graphics.draw(images.bullet, x, y, bullet.angle, 1, 1, images.bullet:getWidth() / 2, images.bullet:getHeight() / 2) end)
  end
end

local function draw()
  if not g.changingZones and not g.gameOver then
    local x, y = player.x + g.grid - player.cameraX, player.y + g.grid - player.cameraY
    local xOffset = -3
    if lastX == 1 then xOffset = 2 end
    local interval = 30
    if player.invulnerableClock % interval < interval / 2 then
      love.graphics.draw(images.cirno, x + xOffset, y, 0, lastX, 1, images.cirno:getWidth() / 2, images.cirno:getHeight() / 2)
    end
    for i = 1, #player.bullets do if player.bullets[i].active and player.bullets[i].seen then drawBullet(player.bullets[i]) end end
  end
end

local function drawHitbox()
  if not g.changingZones and not g.gameOver then
    local x, y = player.x + g.grid - player.cameraX, player.y + g.grid - player.cameraY
    love.graphics.draw(images.hitbox, x, y, 0, 1, 1, images.hitbox:getWidth() / 2, images.hitbox:getHeight() / 2)
  end
end

return {
  bullets = {},
  lives = 2,
  mapOffsetX = g.gameWidth / 2,
  mapOffsetY = g.gameHeight / 2,
	load = load,
  bombs = 5,
  draw = draw,
  drawHitbox = drawHitbox,
  update = update,
  invulnerableClock = 0,
  getHit = getHit
}