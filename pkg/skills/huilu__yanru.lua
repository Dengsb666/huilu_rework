-- SPDX-License-Identifier: GPL-3.0-or-later

local yanru = fk.CreateSkill{
  name = "huilu__yanru",
  max_phase_use_time = 1,
}

Fk:loadTranslationTable{
  ["huilu__yanru"] = "晏如",
  [":huilu__yanru"] = "出牌阶段限一次，若你的手牌数为大于0的偶数，你可以弃置至少半数手牌，然后摸三张牌。",

  ["#huilu__yanru"] = "晏如：你可以弃置至少%arg张手牌，然后摸三张牌",

  ["$huilu__yanru1"] = "国有宁日，民有丰年，大同也。",
  ["$huilu__yanru2"] = "及臻厥成，天下晏如也。",
}

yanru:addEffect("active", {
  anim_type = "drawcard",
  prompt = function(self, player)
    return "#huilu__yanru:::" .. (player:getHandcardNum() // 2)
  end,
  can_use = function(self, player)
    return not player:isKongcheng() and player:getHandcardNum() % 2 == 0
  end,
  min_card_num = function(self, player)
    return player:getHandcardNum() // 2
  end,
  max_card_num = function(self, player)
    return player:getHandcardNum()
  end,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_num = 0,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, yanru.name, player, player)
    if not player.dead then
      player:drawCards(3, yanru.name)
    end
  end,
}, { check_skill_limit = true })

yanru:addTest(function(room, me)
  local general = Fk.generals["huilu__ol__feiyi"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "feiyi")
  lu.assertTrue(table.contains(general.other_skills, yanru.name))
end)

yanru:addTest(function(room, me)
  local skill = Fk.skills[yanru.name]
  local cards = {
    room:printCard("slash"),
    room:printCard("jink"),
    room:printCard("peach"),
    room:printCard("analeptic"),
  }

  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, yanru.name)
    room:obtainCard(me, table.slice(cards, 1, 4))
  end)
  lu.assertFalse(skill:canUse(me))

  FkTest.runInRoom(function()
    room:obtainCard(me, cards[4])
  end)
  lu.assertTrue(skill:canUse(me))
  lu.assertEquals(skill:getMinCardNum(me), 2)
  lu.assertEquals(skill:getMaxCardNum(me), 4)

  FkTest.runInRoom(function()
    skill:onUse(room, { from = me, cards = { cards[1].id, cards[2].id } })
  end)
  lu.assertEquals(me:getHandcardNum(), 5)

  FkTest.runInRoom(function()
    me:addSkillUseHistory(yanru.name)
  end)
  lu.assertFalse(skill:canUse(me))
end)

return yanru
