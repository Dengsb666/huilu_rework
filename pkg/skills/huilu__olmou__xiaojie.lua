-- SPDX-License-Identifier: GPL-3.0-or-later

local xiaojie = fk.CreateSkill {
  name = "huilu__olmou__xiaojie",
}

Fk:loadTranslationTable{
  ["huilu__olmou__xiaojie"] = "效竭",
  [":huilu__olmou__xiaojie"] = "当你成为【杀】的目标后，你可以令你不可响应之。若如此做，你于此【杀】结算完毕后，视为使用你使用的上一张普通锦囊牌或摸一张牌。",

  ["#huilu__olmou__xiaojie-invoke"] = "效竭：你可以令你不可响应此%arg，结算后视为使用锦囊或摸一张牌",
  ["#huilu__olmou__xiaojie-use"] = "效竭：视为使用【%arg】，或点“取消”摸一张牌",

  ["$huilu__olmou__xiaojie1"] = "",
  ["$huilu__olmou__xiaojie2"] = "",
}

xiaojie:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiaojie.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiaojie.name,
      prompt = "#huilu__olmou__xiaojie-invoke:::" .. data.card:toLogString(),
    })
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.huilu__olmou__xiaojie = data.extra_data.huilu__olmou__xiaojie or {}
    data.extra_data.huilu__olmou__xiaojie[player] = true
    data.disresponsive = true
  end,
})

xiaojie:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and ((data.extra_data or {}).huilu__olmou__xiaojie or {})[player]
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local name = ""
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
      if e.data.from == player and e.data.card:isCommonTrick() then
        name = e.data.card.name
        return true
      end
    end, 0, Player.HistoryGame)
    if name ~= "" then
      if not room:askToUseVirtualCard(player, {
        name = name,
        skill_name = xiaojie.name,
        prompt = "#huilu__olmou__xiaojie-use:::" .. name,
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      }) then
        player:drawCards(1, xiaojie.name)
      end
    else
      player:drawCards(1, xiaojie.name)
    end
  end,
})

return xiaojie
