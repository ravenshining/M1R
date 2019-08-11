Triggers = {}

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  if Game.difficulty ~= "kindergarten" or Game.difficulty ~= "easy" then
    smartmonster(monster, aggressor_monster, damage_amount)
  end
end

function smartmonster(monster, aggressor_monster, damage_amount)
  if not monster._zerkvit then
    monster._zerkvit = ( monster.vitality + damage_amount ) / 4
  end
  if aggressor_monster and not aggressor_monster.player and aggressor_monster.valid then
    if not aggressor_monster._zerkvit then
      aggressor_monster._zerkvit = ( aggressor_monster.vitality + damage_amount ) / 4
    end
    local badzerktarget = nil
    if aggressor_monster._zerkvit >= aggressor_monster.vitality and aggressor_monster ~= monster and aggressor_monster.type.friends[monster.type.class] then
      local delta = 524288
-- find nearest enemy target to attack
      for m in Monsters() do
        if m.visible and aggressor_monster.type.enemies[m.type.class] then
          if m.life > 0 or m.player.life > 0 then
            local maybe = math.abs(math.abs(aggressor_monster.facing - angle_between_points(m,aggressor_monster))-180) + math.abs(m.x - aggressor_monster.x) + math.abs(m.y - aggressor_monster.y) + math.abs(m.z - aggressor_monster.z) * 7
            if maybe < delta then
              badzerktarget = m
              delta = maybe
            end
          end
        end
      end
    end
    if badzerktarget ~= nil then
      aggressor_monster:attack(badzerktarget)
--      local bz = "berserking "
--      local on = " on "
--      Players.print(bz..tostring(aggressor_monster)..on..tostring(badzerktarget))
      badzerktarget = nil
    elseif aggressor_monster == monster or aggressor_monster.type.friends[monster.type.class] then
      local dest = Players[0].monster.polygon
      local delta = 512
-- find anything to run towards, preferably but not necessarily forewards
      for p in Polygons() do
        local maybe = math.abs(math.abs(aggressor_monster.facing - angle_between_points(p,aggressor_monster))-180) + math.abs(p.x - aggressor_monster.x) + math.abs(p.y - aggressor_monster.y) + math.abs(p.z - aggressor_monster.z) * 7
        if maybe < delta then
          dest = p
          delta = maybe
        end
      end
      aggressor_monster:move_by_path(dest)
--      local mv = "moving "
--      local to = " to "
--      Players.print(mv..tostring(aggressor_monster)..to..tostring(dest))
    end
  end
end

function angleOfPoint(pt)
    local x, y = pt.x, pt.y
    local radian = math.atan2(y, x)
    local angle = radian * 180 / math.pi
    if angle < 0 then
        angle = 360 + angle
    end
    return angle
end

-- returns the degrees between two points (note: 0 degrees is 'east')
function angle_between_points(a, b)
    local x, y = b.x - a.x, b.y - a.y
    return angleOfPoint({x = x, y = y})
end