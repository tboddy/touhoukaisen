local images, grazes

local function load()
  images = g.images('player', {'graze'})
  grazes = {}
  for i = 1, 32 do grazes[i] = {} end
end

local function spawn(pos, angle)
  local grazeItem = grazes[g.getIndex(grazes)]
	local speed = 1
	grazeItem.x = pos.x
	grazeItem.active = true
	grazeItem.y = pos.y
	grazeItem.clock = 0
	grazeItem.velocity = {
		x = math.cos(angle) * speed,
		y = math.sin(angle) * speed
	}
end

local function update()
  for i = 1, #grazes do if grazes[i].active then
		local grazeItem = grazes[i]
		grazeItem.x = grazeItem.x + grazeItem.velocity.x
		grazeItem.y = grazeItem.y + grazeItem.velocity.y
		grazeItem.clock = grazeItem.clock + 1
		if grazeItem.clock >= 30 then grazeItem.active = false end
  end end
end

local function draw()
  for i = 1, #grazes do if grazes[i].active then
  	local x, y = grazes[i].x - player.cameraX, grazes[i].y - player.cameraY
		love.graphics.setColor(g.colorsLo.red)
  	love.graphics.draw(images.graze, x, y, 0, 1, 1, images.graze:getWidth() / 2, images.graze:getHeight() / 2)
		love.graphics.setColor(g.colorsLo.offWhite)
  	love.graphics.rectangle('fill', x - 1, y - 1, 1, 1)
  end end
	love.graphics.setColor(g.colorsLo.white)
end

return {
	image = love.graphics.newImage('img/player/graze.png'),
	graze = {},
	load = load,
	draw = draw,
	update = update,
	spawn = spawn
}