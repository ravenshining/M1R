function Triggers.monster_killed(monster, aggressor_player, projectile)
  if monster.type.clas == "juggernaut" then
    for m in Monsters() do
      if m.valid and m.visible then
        if (math.abs(monster.x - m.x)^2 + math.abs(monster.y - m.y)^2)^0.5 <= 5.5 then 
          m.active = true
	end
      end
    end
  end
end