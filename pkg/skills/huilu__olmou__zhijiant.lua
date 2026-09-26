-- SPDX-License-Identifier: GPL-3.0-or-later

local zhijiant = fk.CreateSkill {
  name = "huilu__olmou__zhijiant",
}

Fk:loadTranslationTable{
  ["huilu__olmou__zhijiant"] = "执谏",
  [":huilu__olmou__zhijiant"] = "出牌阶段限一次，你可以令一名其他角色声明一个牌的类别，然后你摸一张牌并交给其一张牌（若上一次发动此技能也指定该角色，则多摸一张牌）。若此牌与声明的类别不同，其可以对你使用一张【杀】。",

  ["huilu__olmou__zhijiant_target"] = "上次目标",
  ["#huilu__olmou__zhijiant"] = "执谏：令一名角色声明一个类别，你摸牌并交给其一张牌",
  ["#huilu__olmou__zhijiant-choice"] = "执谏：声明一个类别，%src摸牌并交给你一张牌",
  ["#huilu__olmou__zhijiant-give"] = "执谏：交给%dest一张牌，若不为%arg，其可以对你使用一张【杀】",
  ["#huilu__olmou__zhijiant-slash"] = "执谏：你可以对%src使用一张【杀】",

  ["$huilu__olmou__zhijiant1"] = "",
  ["$huilu__olmou__zhijiant2"] = "",
}

zhijiant:addEffect("active", {
  anim_type = "support",
  prompt = "#huilu__olmou__zhijiant",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(zhijiant.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if selectable and player:getMark(zhijiant.name) == to_select then
      return "huilu__olmou__zhijiant_target"
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = player:getMark(zhijiant.name) == target and 2 or 1
    room:setPlayerMark(player, zhijiant.name, target)
    local choice = room:askToChoice(target, {
      choices = { "basic", "trick", "equip" },
      skill_name = zhijiant.name,
      prompt = "#huilu__olmou__zhijiant-choice:" .. player.id,
    })
    room:sendLog{
      type = "#Choice",
      from = target.id,
      arg = choice,
      toast = true,
    }
    player:drawCards(n, zhijiant.name)
    if player:isNude() or target.dead then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhijiant.name,
      prompt = "#huilu__olmou__zhijiant-give::" .. target.id .. ":" .. choice,
      cancelable = false,
    })
    local different = Fk:getCardById(card[1]):getTypeString() ~= choice
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, zhijiant.name, nil, false, player)
    if different and not player.dead and not target.dead then
      local use = room:askToUseCard(target, {
        skill_name = zhijiant.name,
        pattern = "slash",
        prompt = "#huilu__olmou__zhijiant-slash:" .. player.id,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          exclusive_targets = { player.id },
        },
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
})

return zhijiant
