Triggers = {}
-- CollectionsUsed = {12}

function Triggers.init(restoring_game)
  Game.proper_item_accounting = true
  bloodx = -2
  bloody = 9
  deathx = -2
  deathy = 9
  graveyard = 298
  pilgrim = 262
  for s in Scenery() do
    if s.type == "alien sludge" then
      pilgrim = s.polygon
    elseif s.type == "bob pieces" then
      graveyard = s.polygon
    end
  end
  orangespht = {}
  pinkspht = {}
  blackspht = {}
  greyspht = {}
  for m in Monsters() do
    if m.type == "green bob" then
      table.insert(orangespht, m)
    elseif m.type == "blue bob" then
      table.insert(pinkspht, m)
    elseif m.type == "security bob" then
      table.insert(blackspht, m)
    elseif m.type == "tiny bob" then
      table.insert(greyspht, m)

-- kills other combantants for testing
--    elseif m.type.class == "enforcer" then
--      m:damage(777)
--    elseif m.type.class == "fighter" then
--      m:damage(777)

    end
  end
end

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  if monster.type == "explodavacbob" then
    _mz = monster.z - 0.5
    bloodx = monster.x + Game.global_random(100) / 100 - 0.5
    bloody = monster.y + Game.global_random(100) / 100 - 0.5
    Scenery.new(bloodx, bloody, _mz, monster.polygon, "green stuff")
  end
end

function Triggers.monster_killed(monster, aggressor_player, projectile)
  if monster.type == "explodavacbob" then
    _mz = monster.z - 0.5
    Scenery.new(monster.x, monster.y, _mz, monster.polygon, "pistol clip")
    deathx = monster.x
    deathy = monster.y
    _os = 1
    _ps = 1
    _bs = 1
    _gs = 1
    for m in Monsters() do
      if m.type.class == "compiler" then
        m.active = true
        if m.type == "minor compiler" and m.life > 0 then
          orangespht[_os]:position(m.x, m.y, m.z, m.polygon)
          orangespht[_os]:move_by_path(pilgrim)
          orangespht[_os].life = m.life + 7
          _os = _os + 1
        elseif m.type == "major compiler" and m.life > 0 then
          pinkspht[_ps]:position(m.x, m.y, m.z, m.polygon)
          pinkspht[_ps]:move_by_path(pilgrim)
          pinkspht[_ps].life = m.life + 7
          _ps = _ps + 1
        elseif m.type == "minor invisible compiler" and m.life > 0 then
          blackspht[_bs]:position(m.x, m.y, m.z, m.polygon)
          blackspht[_bs]:move_by_path(pilgrim)
          blackspht[_bs].life = m.life + 7
          _bs = _bs + 1
        elseif m.type == "major invisible compiler" and m.life > 0 then
          greyspht[_gs]:position(m.x, m.y, m.z, m.polygon)
          greyspht[_gs]:move_by_path(pilgrim)
          greyspht[_gs].life = m.life + 7
          _gs = _gs + 1
        end
        m:position(deathx, deathy, 0, graveyard)
        m.life = Game.random(math.ceil(m.life)+1)
      elseif m.type.class == "drone" then
        m.active = true
        m:damage(m.life + 7)
      end
    end
    Tags[1].active = true
  end
end

function Triggers.idle()
  for p in Players() do
    if p.polygon.media and p.dead == false then
      if p.polygon.media.type == "water" then
        p:damage(64, "oxygen drain")
        p:damage(1, "suffocation")
        if p.oxygen <=0 then
          p:damage(451, suffocation)
        end
      end
    end
  end
end