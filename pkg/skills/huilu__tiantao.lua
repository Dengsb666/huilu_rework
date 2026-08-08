-- SPDX-License-Identifier: GPL-3.0-or-later

local tiantao = fk.CreateSkill{
  name = "huilu__tiantao",
}

Fk:loadTranslationTable{
  ["huilu__tiantao"] = "天涛",
  [":huilu__tiantao"] = "结束阶段，你可以弃置所有手牌，然后依次弃置任意名其他角色的一张手牌。因此弃置过牌且未弃置【杀】的角色失去1点体力。",

  ["#huilu__tiantao-invoke"] = "天涛：是否弃置所有手牌，然后弃置任意名其他角色各一张手牌？",
  ["#huilu__tiantao-choose"] = "天涛：选择任意名有手牌的其他角色，依次弃置这些角色各一张手牌",

  ["$huilu__tiantao1"] = "以此天穹之水，涤瑕荡秽！",
  ["$huilu__tiantao2"] = "心怀浊恶之徒，岂能承神雨之清？",
}

local function discardedWithoutSlash(ids)
  return #ids > 0 and not table.find(ids, function(id)
    return Fk:getCardById(id).trueName == "slash"
  end)
end

tiantao:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tiantao.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tiantao.name,
      prompt = "#huilu__tiantao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local loseHp = {}
    local cards = table.filter(player:getCardIds("h"), function(id)
      return not player:prohibitDiscard(Fk:getCardById(id))
    end)
    if discardedWithoutSlash(cards) then
      table.insert(loseHp, player)
    end
    if #cards > 0 then
      room:throwCard(cards, tiantao.name, player, player)
      if player.dead then return end
    end

    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng()
    end)
    if #targets > 0 then
      targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 998,
        targets = targets,
        skill_name = tiantao.name,
        prompt = "#huilu__tiantao-choose",
        cancelable = false,
      })
      for _, p in ipairs(targets) do
        if not (player.dead or p.dead or p:isKongcheng()) then
          local id = room:askToChooseCard(player, {
            target = p,
            skill_name = tiantao.name,
            flag = "h",
          })
          if Fk:getCardById(id).trueName ~= "slash" then
            table.insert(loseHp, p)
          end
          room:throwCard(id, tiantao.name, p, player)
        end
      end
    end

    for _, p in ipairs(loseHp) do
      if not p.dead then
        room:loseHp(p, 1, tiantao.name, player)
      end
    end
  end,
})

tiantao:addTest(function(room, me)
  local skill = Fk.skills[tiantao.name]
  lu.assertNotNil(skill)
  lu.assertFalse(skill:hasTag(Skill.Compulsory))

  local slashId, nonSlashId
  for _, id in ipairs(room.draw_pile) do
    if Fk:getCardById(id).trueName == "slash" then
      slashId = slashId or id
    else
      nonSlashId = nonSlashId or id
    end
    if slashId and nonSlashId then break end
  end
  lu.assertNotNil(slashId)
  lu.assertNotNil(nonSlashId)
  lu.assertFalse(discardedWithoutSlash({}))
  lu.assertFalse(discardedWithoutSlash({ nonSlashId, slashId }))
  lu.assertTrue(discardedWithoutSlash({ nonSlashId }))
end)

return tiantao
