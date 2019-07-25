Triggers = {}

function Triggers.idle()
  for p in Players() do
    if p.polygon.media and p.dead == false then
      p._o2start = p.oxygen
      p.oxygen = p.oxygen - 2
      if p.oxygen <= 0 then
        p:damage(451, "suffocation")
      elseif math.floor(p._o2start / 1080) - math.floor(p.oxygen / 1080) > 0 then
        p:play_sound("breathing", 1)
      end
    end
  end
end
