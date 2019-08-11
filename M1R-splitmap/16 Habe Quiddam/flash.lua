Triggers = {}

begin = true

function Triggers.postidle()
  if begin == true then
    for p in Players() do
      p:fade_screen("bright")
    end
    begin = false
  end
end

function Triggers.player_revived(player)
  player:fade_screen("bright")
end
