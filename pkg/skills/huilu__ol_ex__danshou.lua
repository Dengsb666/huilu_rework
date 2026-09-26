-- SPDX-License-Identifier: GPL-3.0-or-later

local danshou = fk.CreateSkill {
  name = "huilu__ol_ex__danshou",
  max_branches_use_time = {
    ["huilu__ol_ex__danshou1"] = {
      [Player.HistoryPhase] = 1
    },
    ["huilu__ol_ex__danshou2"] = {
      [Player.HistoryPhase] = 1
    },
    ["huilu__ol_ex__danshou3"] = {
      [Player.HistoryPhase] = 1
    },
    ["huilu__ol_ex__danshou4"] = {
      [Player.HistoryPhase] = 1
    },
  }
}

Fk:loadTranslationTable{
  ["huilu__ol_ex__danshou"] = "胆守",
  [":huilu__ol_ex__danshou"] = "出牌阶段每项限一次，若你有牌，你可以选择一名角色执行以下一项："..
  "1.你弃置其一张牌；2.你获得其一张牌；3.你对其造成1点伤害；4.你与其各摸两张牌。然后你弃置你本次执行序号数张牌（不足则全弃）。",

  ["#huilu__ol_ex__danshou"] = "胆守：选择一名角色执行一项，然后你弃置序号数张牌",
  ["huilu__ol_ex__danshou1"] = "弃置其一张牌",
  ["huilu__ol_ex__danshou2"] = "获得其一张牌",
  ["huilu__ol_ex__danshou3"] = "对其造成1点伤害",
  ["huilu__ol_ex__danshou4"] = "与其各摸两张牌",

  ["$huilu__ol_ex__danshou1"] = "",
  ["$huilu__ol_ex__danshou2"] = "",
}

danshou:addEffect("active", {
  anim_type = "support",
  prompt = "#huilu__ol_ex__danshou",
  card_num = 0,
  target_num = 1,
  interaction = function(self, player)
    local choices = {}
    for i = 1, 4 do
      if danshou:withinBranchTimesLimit(player, "huilu__ol_ex__danshou" .. i, Player.HistoryPhase) then
        table.insert(choices, "huilu__ol_ex__danshou" .. i)
      end
    end
    return UI.OptionBox {
      options = choices,
      all_options = {
        "huilu__ol_ex__danshou1",
        "huilu__ol_ex__danshou2",
        "huilu__ol_ex__danshou3",
        "huilu__ol_ex__danshou4",
      },
      direct_send = true,
    }
  end,
  can_use = function(self, player)
    return not player:isNude()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if self.interaction.data == "huilu__ol_ex__danshou1" then
        return table.find(to_select:getCardIds("he"), function(id)
          return not player:prohibitDiscard(id)
        end)
      elseif self.interaction.data == "huilu__ol_ex__danshou2" then
        if to_select == player then
          return #player:getCardIds("e") > 0
        else
          return not to_select:isNude()
        end
      else
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local branch = self.interaction.data
    player:addSkillBranchUseHistory(danshou.name, branch, 1)
    local n = tonumber(branch:sub(-1))

    if n == 1 then
      if target == player then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = danshou.name,
          cancelable = false,
        })
      else
        local id = room:askToChooseCard(player, {
          target = target,
          flag = "he",
          skill_name = danshou.name,
        })
        room:throwCard(id, danshou.name, target, player)
      end
    elseif n == 2 then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = target == player and "e" or "he",
        skill_name = danshou.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, danshou.name, nil, false, player)
    elseif n == 3 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = danshou.name,
      }
    elseif n == 4 then
      player:drawCards(2, danshou.name)
      if not target.dead then
        target:drawCards(2, danshou.name)
      end
    end

    room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = danshou.name,
      cancelable = false,
    })
  end,
}, { check_skill_limit = true })

return danshou
