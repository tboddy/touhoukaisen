local joystick, hat, leftStick, rightStick

local function load()
  local joysticks = love.joystick.getJoysticks()
  for i = 1, #joysticks do if i == 1 then joystick = joysticks[i] end end
  local dirTable = {'left', 'right', 'up', 'down', 'w', 's', 'a', 'd', 'j', 'k', 'i', 'l', 'z'}
  for i = 1, #dirTable do controls[dirTable[i]] = function()
    local isPressed = love.keyboard.isDown(dirTable[i])
    if hat then
      if (hat == 'l' or hat == 'lu' or hat == 'ld') and dirTable[i] == 'a' then isPressed = true end
      if (hat == 'r' or hat == 'ru' or hat == 'rd') and dirTable[i] == 'd' then isPressed = true end
      if (hat == 'u' or hat == 'lu' or hat == 'ru') and dirTable[i] == 'w' then isPressed = true end
      if (hat == 'd' or hat == 'ld' or hat == 'rd') and dirTable[i] == 's' then isPressed = true end
    end
    -- if joystick then
    --   if dirTable[i] == 'j' and joystick:isDown(3) then isPressed = true
    --   elseif dirTable[i] == 'l' and joystick:isDown(2) then isPressed = true
    --   elseif dirTable[i] == 'i' and joystick:isDown(4) then isPressed = true
    --   elseif dirTable[i] == 'k' and joystick:isDown(1) then isPressed = true end
    -- end
    return isPressed
  end end
end

local function shooting()
  local isPressed = love.keyboard.isDown('j') or love.keyboard.isDown('k') or love.keyboard.isDown('l') or love.keyboard.isDown('i')
  if(joystick) then
    if joystick:isDown(1) or joystick:isDown(2) or joystick:isDown(3) or joystick:isDown(4) then isPressed = true end
    if player.rightStick then
      if player.rightStick.x ~= 0 or player.rightStick.y ~= 0 then isPressed = true end
    end
  end
  return isPressed
end

local function bomb()
  return love.keyboard.isDown('space') or love.keyboard.isDown('return') or (joystick and (joystick:isDown(5) or joystick:isDown(6)))
end

local function reload()
  return (love.keyboard.isDown('q') or (joystick and (joystick:isDown(7)))) and g.started
end

local function quit()
  return love.keyboard.isDown('escape')
end

local function pause()
  return love.keyboard.isDown('p') or (joystick and (joystick:isDown(8)))
end

local function update()
  if(joystick) then
    if joystick:getHatCount() > 0 then hat = joystick:getHat(1) end
    if joystick:getAxisCount() > 0 then
      player.leftStick = {x = joystick:getAxis(1), y = joystick:getAxis(2)}
      player.rightStick = {x = joystick:getAxis(3), y = joystick:getAxis(4)}
    end
    if leftStick then updateAnalog() end
  end
end

return {
  load = load,
  shot = shot,
  focus = focus,
  reload = reload,
  bomb = bomb,
  quit = quit,
  shooting = shooting,
  pause = pause,
  update = update
}
