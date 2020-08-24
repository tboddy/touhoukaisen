local currentSound, sfxTypes, bgmTypes

local function load()
  sfxTypes = {'bullet1', 'bullet2', 'bullet3', 'clearwave', 'explosion1', 'explosion2', 'gameover', 'lostrabbit', 'menuchange', 'playerhit', 'playershot', 'rabbit', 'start'}
  bgmTypes = {'startintro', 'start', 'boss', 'bossintro', 'bossoutro', 'stage'}
  for i = 1, #sfxTypes do
    sound.sfxFiles[sfxTypes[i]] = love.audio.newSource('sfx/' .. sfxTypes[i] .. '.wav', 'static')
    sound.sfxFiles[sfxTypes[i]]:setVolume(sound.sfxVolume)
  end
  for i = 1, #bgmTypes do
    sound.bgmFiles[bgmTypes[i]] = love.audio.newSource('bgm/' .. bgmTypes[i] .. '.ogg', 'static')
		sound.bgmFiles[bgmTypes[i]]:setVolume(sound.bgmVolume)
		sound.bgmFiles[bgmTypes[i]]:setLooping(true)
  end
  sound.bgmFiles.startintro:setLooping(false)
  sound.bgmFiles.bossintro:setLooping(false)
  sound.bgmFiles.bossoutro:setLooping(false)
  sound.sfxFiles.playershot:setVolume(.25)
end

local function playBgm(bgm)
  for i = 1, #bgmTypes do
    if sound.bgmFiles[bgmTypes[i]]:isPlaying() then sound.bgmFiles[bgmTypes[i]]:stop() end
  end
  sound.bgmFiles[bgm]:play()
end

local function stopBgm()
  for i = 1, #bgmTypes do
    if sound.bgmFiles[bgmTypes[i]]:isPlaying() then sound.bgmFiles[bgmTypes[i]]:stop() end
  end
end

local function playSfx(sfx)
  if sound.sfxFiles[sfx]:isPlaying() then sound.sfxFiles[sfx]:stop() end
  sound.sfxFiles[sfx]:play()
end

local function update()
  sound.playingBgm = false
  for i = 1, #bgmTypes do
    if sound.bgmFiles[bgmTypes[i]]:isPlaying() then sound.playingBgm = true end
  end
end

return {
  load = load,
  update = update,
  sfxFiles = {},
  bgmFiles = {},
  sfx = false,
  bgm = false,
	sfxVolume = .75,
	bgmVolume = 1,
  playBgm = playBgm,
  playingBgm = false,
  stopBgm = stopBgm,
  playSfx = playSfx
}
