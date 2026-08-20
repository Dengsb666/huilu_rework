-- SPDX-License-Identifier: GPL-3.0-or-later

local lulian = fk.CreateSkill{
  name = "huilu__lulian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["huilu__lulian"] = "戮连",
  [":huilu__lulian"] = "锁定技，当你使用手牌结算结束后，若你没有此类别的手牌，且有目标角色：体力值小于等于你，此牌的所有目标横置；装备区牌数小于等于你，你摸一张牌。乘势：你可以对一名体力值为全场最大值的角色造成1点火焰伤害。",

  ["#huilu__lulian-choose"] = "戮连：你可以对一名体力值为全场最大值的角色造成1点火焰伤害",

  ["$huilu__lulian1"] = "本朝可无天子，可无我孙綝否？",
  ["$huilu__lulian2"] = "朝事在君，生杀在我！",
  ["$huilu__lulian3"] = "莫言泉下孤苦，自有汝族相陪！",
  ["$huilu__lulian4"] = "我心性善，不忍见离，自许汝举族团圆！",
}

local function getMaxHpTargets(room)
  return table.filter(room.alive_players, function(p)
    return table.every(room.alive_players, function(q)
      return p.hp >= q.hp
    end)
  end)
end

lulian:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lulian.name) and data:isUsingHandcard(player) and
      not table.find(player:getCardIds("h"), function(id)
        return Fk:getCardById(id).type == data.card.type
      end) and
      table.find(data.tos, function(p)
        return p.hp <= player.hp or #p:getCardIds("e") <= #player:getCardIds("e")
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local activedBranches = {}
    for _, p in ipairs(data.tos) do
      if p.hp <= player.hp then table.insert(activedBranches, "branch_one") end
      if #p:getCardIds("e") <= #player:getCardIds("e") then table.insert(activedBranches, "branch_two") end
    end
    if #activedBranches > 0 then
      local audioIndex = #activedBranches < 2 and { 1, 2 } or { 3, 4 }
      event:setCostData(self, { activedBranches = activedBranches, audio_index = table.random(audioIndex) })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local activedBranches = event:getCostData(self).activedBranches

    if table.contains(activedBranches, "branch_one") then
      for _, p in ipairs(room:getAlivePlayers()) do
        if table.contains(data.tos, p) and not p.chained then p:setChainState(true) end
      end
    end
    if not player:isAlive() then return false end

    if table.contains(activedBranches, "branch_two") then
      player:drawCards(1, lulian.name)
    end
    if not player:isAlive() or #activedBranches <= 1 then return end

    local targets = getMaxHpTargets(room)
    if #targets == 0 or not room:askToSkillInvoke(player, {
      skill_name = lulian.name,
      prompt = "#huilu__lulian-choose",
    }) then
      return
    end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#huilu__lulian-choose",
      skill_name = lulian.name,
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = lulian.name,
    }
  end,
})

lulian:addTest(function(room, me)
  local general = Fk.generals["huilu__m_shi__sunchen"]
  lu.assertNotNil(general)
  lu.assertEquals(general.maxHp, 4)

  local p1, p2, p3 = { hp = 2 }, { hp = 4 }, { hp = 4 }
  local fakeRoom = { alive_players = { p1, p2, p3 } }
  lu.assertEquals(#getMaxHpTargets(fakeRoom), 2)
  lu.assertTrue(table.contains(getMaxHpTargets(fakeRoom), p2))
  lu.assertTrue(table.contains(getMaxHpTargets(fakeRoom), p3))
  p3.hp = 3
  lu.assertEquals(#getMaxHpTargets(fakeRoom), 1)
  lu.assertTrue(table.contains(getMaxHpTargets(fakeRoom), p2))
end)

return lulian
