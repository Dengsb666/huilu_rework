-- SPDX-License-Identifier: GPL-3.0-or-later

local dimeng = fk.CreateSkill {
  name = "huilu__dimeng",
}

Fk:loadTranslationTable{
  ["huilu__dimeng"] = "缔盟",
  [":huilu__dimeng"] = "出牌阶段限一次，你可以选择两名其他角色并弃置X张牌（X为这些角色手牌数差），令这两名角色交换手牌。",

  ["#huilu__dimeng"] = "缔盟：选择两名其他角色，点击“确定”后，选择与其手牌数之差等量的牌，这两名角色交换手牌",
  ["#huilu__dimeng-discard"] = "缔盟：弃置 %arg 张牌，交换%src和%dest的手牌",

  ["$huilu__dimeng1"] = "以和为贵，以和为贵。",
  ["$huilu__dimeng2"] = "合纵连横，方能以弱胜强。",
}

dimeng:addEffect("active", {
  anim_type = "control",
  prompt = "#huilu__dimeng",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 2,
  include_equip = true,
  can_use = function(self, player)
    return player:usedSkillTimes(dimeng.name, Player.HistoryPhase) == 0 and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected_targets == 2 and #selected < math.abs(selected_targets[1]:getHandcardNum() - selected_targets[2]:getHandcardNum())
    and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if to_select == player then
      return false
    end

    if #selected == 0 then
      return true
    elseif #selected == 1 then
      return not (to_select:isKongcheng() and selected[1]:isKongcheng())
    end
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if #selected == 2 then
      return #selected_cards == math.abs(selected[1]:getHandcardNum() - selected[2]:getHandcardNum())
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, dimeng.name, player, player)
    room:swapAllCards(player, effect.tos, dimeng.name)
  end,
})

dimeng:addTest(function(room, me)
  local skill = Fk.skills[dimeng.name]
  lu.assertNotNil(skill)
  lu.assertTrue(skill.include_equip)
  lu.assertEquals(skill.trueName, "dimeng")
end)

return dimeng
