Triggers = {}
destination = 155
function Triggers.init(restoring_game)
  for g in Goals() do
    destination = g.polygon
  end
end
function Triggers.idle()
  for m in Monsters() do 
    if m.type.class == "bob" and m.polygon ~= destination then
      if m.action == "teleporting out" then
        m:accelerate(m.facing, 0.1, 0)
        m:move_by_path(destination)
      end
      if m.mode == "unlocked" and m.vitality > 0 then
        thisone = m
        destmon = 0
        for m in Monsters() do
          if m.type == "explodavacbob" then
              destmon = m
          end
        end
        thisone:attack(destmon)
        m:move_by_path(destination)
      end
    end
    if m.type.class == "bob" and m.polygon == destination and m.vitality > 0 and m.mode ~= "unlocked" then
      m.active = false
      m.active = true
    end
  end
end
