-- SPDX-License-Identifier: GPL-3.0-or-later

local nigu = fk.CreateSkill {
  name = "huilu__nigu",
}

Fk:loadTranslationTable{
  ["huilu__nigu"] = "逆固",
  [":huilu__nigu"] = "出牌阶段限一次，你可以弃置至少一张花色不同的牌，令攻击范围内的角色同时选择是否交给你一张牌。",

  ["#huilu__nigu"] = "逆固：弃置至少一张花色不同的牌，令攻击范围内的角色选择是否交给你一张牌",
  ["#huilu__nigu-give"] = "逆固：是否交给 %src 一张牌？",

  ["$huilu__nigu1"] = "诸卿若不奉我，便是已有反心！",
  ["$huilu__nigu2"] = "正值尽忠死战之时，何故生此迟疑！",
  ["$huilu__nigu3"] = "天子若有他意，我亦当复改图！",
  ["$huilu__nigu4"] = "我令既不得行，我刑当得行也！",
}

nigu:addEffect("active", {
  audio_index = { 1, 2 },
  anim_type = "control",
  prompt = "#huilu__nigu",
  min_card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(nigu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected, selected_targets)
    return not player:prohibitDiscard(to_select) and not table.find(selected, function(id)
      return Fk:getCardById(id):compareSuitWith(Fk:getCardById(to_select))
    end)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, nigu.name, player, player)
    if player.dead then return end

    local targets = table.filter(room:getAlivePlayers(), function(p)
      return player:inMyAttackRange(p)
    end)
    if #targets == 0 then return end
    room:doIndicate(player, targets)
    local result = room:askToJointCards(player, {
      players = targets,
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = nigu.name,
      cancelable = true,
      prompt = "#huilu__nigu-give:" .. player.id,
    })

    local moves = {}
    for _, p in ipairs(targets) do
      if #result[p] > 0 then
        table.insert(moves, {
          ids = result[p],
          from = p,
          to = player,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonGive,
          skillName = nigu.name,
        })
      end
    end
    if next(moves) then room:moveCards(table.unpack(moves)) end
  end,
})

nigu:addTest(function(room, me)
  local general = Fk.generals["huilu__m_shi__sunchen"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "sunchen")
  lu.assertEquals(general.kingdom, "wu")
  lu.assertEquals(general.hp, 4)
  lu.assertTrue(table.contains(general.other_skills, nigu.name))
  lu.assertTrue(table.contains(general.other_skills, "huilu__lulian"))

  -- 逆固本身只处理弃牌和交牌；无人交牌时不留下回合增伤标记。
  local card = room:printCard("slash")
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, nigu.name)
    room:obtainCard(me, card)
    room:throwCard(card, nigu.name, me, me)
  end)
  lu.assertEquals(me:getMark("@huilu__nigu-turn"), 0)
end)

return nigu
