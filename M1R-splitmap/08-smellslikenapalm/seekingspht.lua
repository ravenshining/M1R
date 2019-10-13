Triggers = {}

function Triggers.init(restoring)
  Game.proper_item_accounting = true
  for s in Scenery() do
    if s.type == "bob blood" then
      eastend = s.polygon
    elseif s.type == "bob pieces" then
      westend = s.polygon
    elseif s.type == "jjaro short light" then
      controlroom = s.polygon
    end
  end
  for a in Annotations() do
    if a.text == "Shuttle Drydock" then
      drydock = a.polygon
    elseif a.text == "hole" then
      hole = a.polygon
      a.polygon = nil
    elseif a.text == "east" then
      eastdoor = a.polygon
      a.polygon = nil
    elseif a.text == "west" then
      westdoor = a.polygon
      a.polygon = nil
    elseif a.text == "ugh" then
      ugh = a.polygon
    end
  end
end

function Triggers.idle()
  if Game.ticks % 7 == 0 then
    trappedplayers = 0
    for p in Players() do
      if p.polygon.media then
        trappedplayers = trappedplayers + 1
        mole = p.monster
      end
    end
    for m in Monsters() do
      if m.valid and m.visible then
        if m.type.class == "compiler" and m.action ~= "attacking far" and m.action~= "attacking close" and m.action ~= "waiting to attack again" and m.action ~= "being hit" then
          if trappedplayers > 0 and ugh.ceiling.z == 1 then
            if not m.polygon.media and m.polygon ~= hole then
              m:move_by_path(hole)
            elseif m.polygon == hole then
              m:attack(mole)
            end
            m._goeast = nil
            m._gowest = nil
            m._goup = nil
            m._godown = nil
          elseif m.type == "minor invisible compiler" or m.type == "major invisible compiler" or m.active then
            if not m._goeast and not m._gowest and not m._goup and not m._godown then
              if westdoor.z ~= westdoor.ceiling.z and not m.polygon == westend then
                m:move_by_path(westend)
                m._gowest = true
              elseif eastdoor.z ~= eastdoor.ceiling.z and not m.polygon == eastend then
                m:move_by_path(eastend)
                m._goeast = true
              elseif not m.polygon == drydock then
                m:move_by_path(drydock)
                m._godown = true
              elseif not m.polygon == controlroom then
                m:move_by_path(controlroom)
                m._goup = true
              end
            elseif m.polygon == eastend and m._goeast then
              m._goeast = nil
            elseif m.polygon == westend and m._gowest then
              m._gowest = nil
            elseif m.polygon == controlroom and m._goup then
              m._goup = nil
            elseif m.polygon == drydock and m._godown then
              m._godown = nil
            end
          end
        end
        if m.type.class == "compiler" and m.action ~= "moving" then
          m._goeast = nil
          m._gowest = nil
          m._goup = nil
          m._godown = nil 
        end
      end
    end
  end
end
