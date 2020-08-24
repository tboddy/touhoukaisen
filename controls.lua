local joystick = false

local function load()
  local joysticks = love.joystick.getJoysticks()
  for i = 1, #joysticks do if i == 1 then joystick = joysticks[i] end end
  local dirTable = {'left', 'right', 'up', 'down', 'w', 's', 'a', 'd', 'j', 'k', 'i', 'l', 'z'}
  for i = 1, #dirTable do controls[dirTable[i]] = function()
    local isPressed = love.keyboard.isDown(dirTable[i])
    if joystick then
      local axis1, axis2, axis3, axis4, axis5 = joystick:getAxes()
      local hat1 = joystick:getHat(1)
      local leftX = math.floor(axis1 * 10)
      local leftY = math.floor(axis2 * 10)
      local rightX = math.floor(axis4 * 10)
      local rightY = math.floor(axis5 * 10)
      if hat1 then
        if hat1 == 'l' or hat1 == 'lu' or hat1 == 'ld' then leftX = -10 end
        if hat1 == 'r' or hat1 == 'ru' or hat1 == 'rd' then leftX = 10 end
        if hat1 == 'u' or hat1 == 'lu' or hat1 == 'ru' then leftY = -10 end
        if hat1 == 'd' or hat1 == 'ld' or hat1 == 'rd' then leftY = 10 end
      end
      local trigger = math.pi
      if dirTable[i] == 'a' and leftX <= -trigger then isPressed = true
      elseif dirTable[i] == 'd' and leftX >= trigger then isPressed = true end
      if dirTable[i] == 'w' and leftY <= -trigger then isPressed = true
      elseif dirTable[i] == 's' and leftY >= trigger then isPressed = true end

      if dirTable[i] == 'j' and rightX <= -trigger then isPressed = true
      elseif dirTable[i] == 'l' and rightX >= trigger then isPressed = true end
      if dirTable[i] == 'i' and rightY <= -trigger then isPressed = true
      elseif dirTable[i] == 'k' and rightY >= trigger then isPressed = true end

      if dirTable[i] == 'j' and joystick:isDown(3) then isPressed = true
      elseif dirTable[i] == 'l' and joystick:isDown(2) then isPressed = true
      elseif dirTable[i] == 'i' and joystick:isDown(4) then isPressed = true
      elseif dirTable[i] == 'k' and joystick:isDown(1) then isPressed = true end

    end
    return isPressed
  end end
end

local function shooting()
  local isPressed = love.keyboard.isDown('j') or love.keyboard.isDown('k') or love.keyboard.isDown('l') or love.keyboard.isDown('i')
  if(joystick) then
    local axis1, axis2, axis3, axis4, axis5 = joystick:getAxes()
    if axis5 then if axis4 ~= 0 or axis5 ~= 0 then isPressed = true end end
    if joystick:isDown(1) or joystick:isDown(2) or joystick:isDown(3) or joystick:isDown(4) then isPressed = true end
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

return {
  load = load,
  shot = shot,
  focus = focus,
  reload = reload,
  bomb = bomb,
  quit = quit,
  shooting = shooting,
  pause = pause
}
