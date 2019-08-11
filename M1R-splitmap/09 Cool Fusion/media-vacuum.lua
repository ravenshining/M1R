Triggers = {}

function Triggers.init()
  vacdisabled = {}
  for m in Monsters() do
    if m.type.class == "fighter" then
        table.insert(vacdisabled, m)
    end
  end
end

function Triggers.idle()
  for p in Players() do
    if p.polygon.media and p.dead == false then
      suffocatemrmarathon(p)
    end
  end
  if Game.ticks % 11 == 0 and next(vacdisabled) ~= nil then
    suffocatemonsters()
  end
end

function suffocatemrmarathon(p)
  p._cantbreathe = false
  p._o2start = p.oxygen
  if p.polygon.media.type == "sewage" then
    p.oxygen = p.oxygen - 1
    p._cantbreathe = true
  end
  if p._cantbreathe == true then
    if p.oxygen <= 0 then
      p:damage(451, "suffocation")
    elseif math.floor(p._o2start / 900) - math.floor(p.oxygen / 900) > 0 then
      p:play_sound("breathing", 1)
    end
  end
end

function suffocatemonsters()
  for i = 1, #vacdisabled do
    local m = vacdisabled[i]
    if m and m.valid then
      if m.polygon.media and m.active then
        if m.action ~= "attacking close" and m.action ~= "attacking far" and m.action ~= "dying hard" and m.action ~= "dying soft" and m.action ~= "dying flaming" then
          m._run = false
          if m.polygon.media.type == "sewage" then
            m:damage(1, "explosion")
            m._run = true
          end
          if m._run == true and m.mode ~= "locked" then
            m:move_by_path(48)
          end
        elseif m.action == "dying hard" or m.action == "dying soft" or  m.action == "dying flaming" then
          table.remove(vacdisabled, i)
        end
      end
    end
  end
end
