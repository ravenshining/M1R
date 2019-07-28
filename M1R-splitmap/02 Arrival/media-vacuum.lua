Triggers = {}

function Triggers.init()
  outerdoor = Platforms[11]
  innerdoor = Platforms[12]
  for p in Platforms() do
    if p.polygon.media then
      if p.polygon.media == "goo" then
        outerdoor = p
      elseif p.polygon.media == "lava" then
        innerdoor = p
      end
    end
  end
  downstairs = {}
  for m in Monsters() do
    if m.polygon.media then
      if m.type == "tiny bob" or m.type.class == "fighter" then
        table.insert(downstairs, m)
      end
    end
  end
end

function Triggers.idle()
  for p in Players() do
    if p.polygon.media and p.dead == false then
      suffocatemrmarathon(p)
    end
  end
  if Game.ticks % 11 == 0 and next(downstairs) ~= nil then
    suffocatemonsters()
  end
end

function suffocatemrmarathon(p)
  p._cantbreathe = false
  p._o2start = p.oxygen
  if p.polygon.media.type == "goo" then
    p.oxygen = p.oxygen - 2
    p._cantbreathe = true
  elseif p.polygon.media.type == "jjaro" then
    p.oxygen = p.oxygen - 32
    p:damage(1, "shotgun")
    p._cantbreathe = true
  elseif outerdoor.active == "true" then
    if p.polygon.media.type == "lava" then
      p.oxygen = p.oxygen - 2
      p._cantbreathe = true
    elseif innerdoor.active == "true" and p.polygon.media == "water" then
      p.oxygen = p.oxygen - 1
      p._cantbreathe = true
    end
  end
  if p._cantbreathe == true then
    if p.oxygen <= 0 then
      p:damage(451, "suffocation")
    elseif math.floor(p._o2start / 1080) - math.floor(p.oxygen / 1080) > 0 then
      p:play_sound("breathing", 1)
    end
  end
end

function suffocatemonsters()
  for i = 1, #downstairs do
    local comic = downstairs[i]
    if comic and comic.valid then
      if comic.polygon.media and comic.active then
        if comic.action ~= "attacking close" and comic.action ~= "attacking far" and comic.action ~= "dying hard" and comic.action ~= "dying soft" and comic.action ~= "dying flaming" then
          comic._run = false
          if comic.polygon.media.type == "goo" then
            comic:damage(3, "explosion")
            comic._run = true
          elseif comic.polygon.media.type == "jjaro" then
            comic:damage(comic.life+1, "explosion")
          elseif outerdoor.floor_height < -0.8  then
            if comic.polygon.media.type == "lava" then
              comic:damage(2, "explosion")
              comic._run = true
            elseif innerdoor.floor_height < -0.8 and comic.polygon.media == "water" then
              comic:damage(1, "explosion")
              comic._run = true
            end
          end
          if comic._run == true then
            if comic.type == "tiny bob" or comic.mode ~= "locked" then
              comic:move_by_path(100)
            end
          end
        elseif comic.action == "dying hard" or comic.action == "dying soft" or  comic.action == "dying flaming" then
          table.remove(downstairs, i)
        end
      elseif comic.active and not comic.polygon.media then
        table.remove(downstairs, i)
      end
    end
  end
end
