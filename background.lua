local images, bottomQuad, topQuad, bottomX, bottomY, topX, topY

local function load()
  images = g.images('background', {'stars'})
  images.stars:setWrap('repeat')
  bottomQuad = love.graphics.newQuad(0, 0, 0, 0, images.stars:getDimensions())
  topQuad = love.graphics.newQuad(0, 0, 0, 0, images.stars:getDimensions())
  bottomX, bottomY, topX, topY = 0, 0, 0, 0
end

local function update()
  if not g.paused then
    local mod, topMod = .05, 2
    if not g.changingZones and not g.gameOver then
      bottomX = bottomX + background.diffX * mod
      bottomY = bottomY + background.diffY * mod
      topX = topX + background.diffX * (mod * topMod)
      topY = topY + background.diffY * (mod * topMod)
    end
    mod = .01
    bottomX = bottomX + mod * topMod
    bottomY = bottomY + mod * topMod
    topX = topX + mod * topMod
    topY = topY + mod * topMod

    bottomQuad:setViewport(bottomX, bottomY, g.gameWidth, g.gameHeight)
    topQuad:setViewport(topX + g.gameWidth / 2, topY - g.gameHeight / 4, g.gameWidth, g.gameHeight)
  end
end

local function draw()
  love.graphics.setColor(g.colorsLo.black)
  love.graphics.rectangle('fill', 0, 0, g.gameWidth, g.gameHeight)
  love.graphics.setColor(g.colorsLo.gray)
  love.graphics.draw(images.stars, bottomQuad, 0, 0)
  love.graphics.setColor(g.colorsLo.brown)
  love.graphics.draw(images.stars, topQuad, 0, 0)
  love.graphics.setColor(g.colors.white)
end

return {
  diffX = 0,
  diffY = 0,
	load = load,
	update = update,
	draw = draw
}