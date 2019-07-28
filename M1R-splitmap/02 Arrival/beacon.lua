Triggers = {}

function Triggers.terminal_exit(terminal, player)
  if terminal == 0 and Platforms[20].active == true then
    player.compass.lua = true
    player.compass.beacon = true
    player.compass.x = Goals[1].x
    player.compass.y = Goals[1].y
  end
end
