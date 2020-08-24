local images, groundQuad, cloudsQuad, groundX, groundY, cloudsX, cloudsY, bgSpeed, bgSpeedInit, bgMod, lastF, lastX, lastY

local function load()
  images = g.images('background', {'sand', 'fade', 'water', 'clouds'})
  images.water:setWrap('repeat')
  images.clouds:setWrap('repeat')
  groundQuad = love.graphics.newQuad(0, 0, 0, 0, images.water:getDimensions())
  cloudsQuad = love.graphics.newQuad(0, 0, 0, 0, images.clouds:getDimensions())
  groundX, groundY, cloudsX, cloudsY = 0, 0, 0, 0
  bgSpeedInit = 1.5
  bgSpeed = 0
  speedMomentum = 0
  bgMod = .01
end

local function update()
  if not g.paused then

    local mod, cloudMod = .15, 1.5

    -- if not g.changingZones and not g.gameOver then
    --   local xSpeed = 0
    --   local ySpeed = 0
    --   local speed = bgSpeed
    --   if controls.a() then xSpeed = -1
    --   elseif controls.d() then xSpeed = 1 end
    --   if controls.w() then ySpeed = -1
    --   elseif controls.s() then ySpeed = 1 end
    --   local fSpeed = speed / math.sqrt(math.max(xSpeed + ySpeed, 1))
    --   groundX = groundX + fSpeed * xSpeed
    --   groundY = groundY + fSpeed * ySpeed
    --   fSpeed = fSpeed * cloudMod
    --   cloudsX = cloudsX + fSpeed * xSpeed
    --   cloudsY = cloudsY + fSpeed * ySpeed
    --   if controls.a() or controls.d() or controls.w() or controls.d() then
    --     if bgSpeed < bgSpeedInit then bgSpeed = bgSpeed + bgMod
    --     else bgSpeed = bgSpeedInit end
    --     lastF = fSpeed
    --     lastX = xSpeed
    --     lastY = ySpeed
    --   else
    --     if bgSpeed > 0 then bgSpeed = bgSpeed - bgMod * 2
    --     else bgSpeed = 0 end
    --     if lastF and lastX and lastY then
    --       cloudsX = cloudsX + fSpeed * lastX
    --       cloudsY = cloudsY + fSpeed * lastY
    --     end
    --   end
    -- end

    groundX = groundX + mod
    groundY = groundY + mod
    cloudsX = cloudsX + mod * cloudMod
    cloudsY = cloudsY + mod * cloudMod
  end
end

local function draw()
  groundQuad:setViewport(groundX, groundY, g.gameWidth, g.gameHeight)
  cloudsQuad:setViewport(cloudsX, cloudsY, g.gameWidth, g.gameHeight)
  love.graphics.setColor(g.colors.black)
  love.graphics.rectangle('fill', g.grid, g.grid, g.gameWidth, g.gameHeight)
  love.graphics.setColor(g.colors.purple)
  g.mask('quarter', function() love.graphics.draw(images.water, groundQuad, g.grid, g.grid) end)
  love.graphics.setColor(g.colors.blueDark)
  g.mask('quarter', function() love.graphics.draw(images.clouds, cloudsQuad, g.grid, g.grid) end)
  love.graphics.setColor(g.colors.black)
  love.graphics.draw(images.fade, g.grid, g.grid)
  love.graphics.setColor(g.colors.white)
end

return {
	load = load,
	update = update,
	draw = draw
}