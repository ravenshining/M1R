Triggers = {}
CollectionsUsed = {12}
followers = 0
Game.proper_item_accounting = true
peace = true

function Triggers.init(restoring)
  for m in MonsterTypes() do
    if m.class == "yeti" then
      m.enemies["player"] = false
      m.type._timer = 133
      Players.print(peace)
    end
  end
end

function Triggers.idle()
  for p in Players() do
    if p.action_flags.action_trigger == true then
      t = p:find_target()
      if is_monster(t) then
        actionmonster(p,t)
      elseif is_polygon(t) then
        follow(t,false)
      elseif is_side(t) or is_scenery(t) then
        follow(t.polygon,false)
      end
    end
    if p.weapons.current then
      if p.weapons.current.type ~= "fist" and p.weapons.current.type ~= "ball" then
        for m in MonsterTypes() do
          if m._timer then
            if Game.ticks - (m._timer + Game.global_random(77)) > 77 then
              peace = false
              m.enemies["player"] = true
            end
          end
        end
      end
    end
  end
  if followers > 0 then
    if Game.ticks % 2 == 0 then
      follow(nil)
    end
  elseif followers < 0 then
    followers = 0
  end
end

function Triggers.monster_killed(monster, aggressor_player, projectile)
  if monster._following then
    monster._following = nil
    followers = followers - 1
    if aggressor_player then
      youdonebad(aggressor_player,monster)
    end
  end
  if monster.type.class == "yeti" then
    peace = false
    monster.type.enemies["player"] = true
    monster.type.friends["player"] = false
  elseif aggressor_player and monster._attacked then
    if monster._attacked.class == "yeti" then
      peace = true
      monster._attacked.enemies["player"] = false
      monster._attacked.friends["player"] = true
      for m in Monsters() do
        if m.valid and m.visible and m.active then
          if m.type == monster._attacked then
            m.active = false
            m.active = true
            m:play_sound("flickta projectile attack")
          end
        end
      end
    end
  end
end

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  if aggressor_monster then
    if monster.player then
      if monster.player.life >= 0 then
        if aggressor_monster.player then
          if aggressor_monster.player.life >= 0 and monster.player ~= aggressor_monster.player then
            dronebomb(aggressor_monster.player,monster.player,false)
            dronebomb(monster.player,aggressor_monster.player,false)
          end
        elseif aggressor_monster.life >= 0 then
          dronebomb(aggressor_monster,monster.player,false)
        end
      end
    elseif monster.life >= 0 and aggressor_monster.player then
      if aggressor_monster.player.life >= 0 then
        dronebomb(monster,aggressor_monster.player,false)
      end
    end
    if monster.type.class == "yeti" and aggressor_monster.type.class ~= "yeti" then
      aggressor_monster._attacked = monster.type
    end
  end
end

function follow(dest,p)
  for m in Monsters() do
    if m._following then
      if dest and m.valid and p == m._following then
        m._dest = dest
        if dest ~= m.polygon then
          m.active = true
        end
        if m.mode == "lost lock" or m.mode == "running" then
          m:move_by_path(dest)
        end
      end
      if not m.valid then
        m._following = nil
        followers = followers - 1
      elseif m.mode == "unlocked" then
        if m._dest then
          if m._dest == m.polygon and m.dest == m._following.polygon then
            m.active = false
          elseif m._dest ~= m.polygon then
            m:move_by_path(m._dest)
          else
            m:move_by_path(m._following.polygon)
          end
        else
          if m.polygon == m._following.polygon then
            m.active = false
          else
            m:move_by_path(m._following.polygon)
          end
        end
      elseif Game.ticks % 14 == 0 and not dest then
        if m._dest then
          if m.polygon == m._dest then
            m._dest = nil
          elseif m.mode == "running" then
            m:move_by_path(m._dest)
          end
        elseif m.mode == "running" and m._following.polygon ~= m.polygon then
          m:move_by_path(m._following.polygon)
        end
      end
    end
  end
end

function actionmonster(p,t)
  dist = ((p.x - t.x)^2 + (p.y - t.y)^2 + (p.z - t.z)^2)^0.5
  if t.type.class == "bob" then
    if dist <= 1.5 then
      if t._following then
        t.vitality = math.min(t.vitality + 1,32)
        t._following = nil
        followers = followers - 1
        if t.type.impact_effect == "civilian blood splash" then
          t:play_sound("bob chatter")
        elseif t.type.impact_effect == "civilian fusion blood splash" then
          t:play_sound("vacbob chatter")
        end
      else
        if not t.active then
          t.active = true
        else
          if t.type.impact_effect == "civilian blood splash" then
            t:play_sound("bob activation")
          elseif t.type.impact_effect == "civilian fusion blood splash" then
            t:play_sound("vacbob activation")
          end
        end
        t.vitality = math.min(t.vitality + 1,32)
        t._following = p
        followers = followers + 1
      end
      t:move_by_path(p.polygon)
    else
      follow(t.polygon,p)
    end
  elseif t.type.class == "madd" then
    if dist <= 1.5 then
      t.active = true
      if t._following then
        t._following = nil
        followers = followers - 1
        t:play_sound("computer logon")
      else
        t:play_sound("computer logoff")
        t._following = p
        followers = followers + 1
      end
      t.vitality = math.min(t.vitality + 7,800)
      t:move_by_path(p.polygon)
    else
      follow(t.polygon,p)
    end
  elseif t.type.class == "explodabob" then
    if dist <= 1.5 then
      t.active = true
      if t.type.impact_effect ~= "assimilated civilian fusion blood splash" then
        t:play_sound("assimilated bob chatter")
      elseif t.type.impact_effect == "assimilated civilian fusion blood splash" then
        t:play_sound("assimilated vacbob chatter")
      end
      t.vitality = t.vitality + 7
    else
      follow(t.polygon,p)
    end
  elseif t.type.class == "possessed drone" then
    t.active = true
    if dist <= 1.5 then
      if t.type.enemies["player"] then
        t:play_sound("destroy control panel")
        t:damage(7,"fusion")
      elseif t.type.friends["player"] then
        t:play_sound("puzzle switch")
        if t._following then
          t._following = nil
          followers = followers - 1
        else
          t._following = p
          followers = followers + 1
        end
        t.vitality = math.min(t.vitality + 2,128)
        t:move_by_path(p.polygon)
      end
    else
      follow(t.polygon,p)
    end
  elseif t.type.class == "yeti" and dist <= 1.5 then
    if p.weapons.current then
      if p.weapons.current.type == "fist" or p.weapons.current.type == "ball" then
        peace = true
      else
        t:play_sound("flickta melee attack")
      end
    elseif p.weapons.active == false then
      peace = true
    end
    if peace == true then
      t.active = false
      t.type.enemies["player"] = false
      t.active = true
      t.vitality = t.vitality + 7
      t:play_sound("flickta projectile attack")
      t.type._timer = Game.ticks
    end
  elseif t.type.enemies["player"] or t.player and not Game.type == "cooperative play" then
    dronebomb(t,p,true)
  else
    follow(t.polygon,p)
  end
end

function dronebomb(t,p,direct)
  for m in Monsters() do
    if m._following then
      if not m.valid then
        m._following = nil
        followers = followers - 1
      elseif m._following == p or Game.type == "cooperative play" and not t.player then
        if m.mode == "unlocked" or direct == true and m.action ~= "attacking close" and m.action ~= "attacking far" then
          m:attack(t)
        end
      end
    end
  end
end

function youdonebad(murderer,victim)
  if followers > 0 then
    for m in Monsters() do
      if m._following then
        m._following = nil
        followers = followers - 1
        if m.valid then
          m:attack(murderer.monster)
          if m.type.class == "bob" then
--            if m.type.impact_effect == "civilian blood splash" then
--              m:play_sound("bob kill the player")
--            elseif m.type.impact_effect == "civilian fusion blood splash" then
--              m:play_sound("vacbob kill the player")
--            end
            m.vitality = m.vitality * 3
          elseif m.type.class == "madd" then
            m:play_sound("alarm")
          elseif m.type.class == "possessed drone" then
            m:play_sound("juggernaut warning")
            m.vitality = m.vitality * 2
          end
        end
      end
    end
  end
  if victim.type.class == "possessed drone" then
    pilot = Monsters.new(victim.x,victim.y,victim.z,victim.polygon,"tiny bob")
    pilot:attack(murderer.monster)
    vengeance = Projectiles.new(victim.x,victim.y,victim.z,victim.polygon,"durandal hummer")
    vengeance.elevation = murderer.pitch * -1
    vengeance.facing = math.abs(murderer.head_direction - 180)
    vengeance.owner = pilot
    vengeance.target = murderer
  elseif victim.type.class == "madd" then
    vengeance = Projectiles.new(victim.x,victim.y,victim.z,victim.polygon,"minor hummer")
    vengeance.elevation = math.max(murderer.pitch * -1,0)
    vengeance.facing = math.abs(murderer.head_direction - 180)
--    vengeance.owner = victim
    vengeance.target = murderer
  elseif victim.type.class == "bob" then
    vengeance = Projectiles.new(murderer.x,murderer.y,murderer.z,murderer.polygon,"major energy drain")
    vengeance.elevation = murderer.pitch * -1
    vengeance.facing = math.abs(murderer.head_direction - 180)
--    vengeance.owner = victim
    vengeance.target = murderer
  end
end