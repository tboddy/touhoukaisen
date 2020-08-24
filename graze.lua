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
		g.mask('half', function() love.graphics.draw(images.graze, grazes[i].x + g.grid - player.cameraX, grazes[i].y + g.grid - player.cameraY, 0, 2, 2, images.graze:getWidth() / 2, images.graze:getHeight() / 2) end)
  end end
end

return {
	image = love.graphics.newImage('img/player/graze.png'),
	graze = {},
	load = load,
	draw = draw,
	update = update,
	spawn = spawn
}