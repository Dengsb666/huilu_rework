-- SPDX-License-Identifier: GPL-3.0-or-later

local xiaoji = fk.CreateSkill({
  name = "huilu__mou__xiaoji",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = { "wu" },
})

Fk:loadTranslationTable{
  ["huilu__mou__xiaoji"] = "枭姬",
  [":huilu__mou__xiaoji"] = "吴势力技，当你失去装备区里的一张牌后，你摸两张牌，然后你可以弃置场上的一张牌。",

  ["#huilu__mou__xiaoji-discard"] = "枭姬：选择一名角色，弃置其装备区或判定区里的一张牌",

  ["$huilu__mou__xiaoji1"] = "吾之所通，何止十八般兵刃！",
  ["$huilu__mou__xiaoji2"] = "既如此，就让尔等见识一番！",
}

xiaoji:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xiaoji.name) then return false end
    return table.find(data, function(move)
      return move.from == player and table.find(move.moveInfo, function(info)
        return info.fromArea == Card.PlayerEquip
      end)
    end) ~= nil
  end,
  trigger_times = function(self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then n = n + 1 end
        end
      end
    end
    return n
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, xiaoji.name)
    if player.dead then return end

    local targets = table.filter(room.alive_players, function(p)
      return #p:getCardIds("ej") > 0
    end)
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#huilu__mou__xiaoji-discard",
      skill_name = xiaoji.name,
      cancelable = true,
    })
    if #tos == 0 then return end
    local id = room:askToChooseCard(player, {
      target = tos[1],
      flag = "ej",
      skill_name = xiaoji.name,
    })
    room:throwCard(id, xiaoji.name, tos[1], player)
  end,
})

xiaoji:addTest(function(room, me)
  local spear = room:printCard("spear")
  local armor = room:printCard("nioh_shield")
  FkTest.runInRoom(function()
    room:changeKingdom(me, "wu")
    room:handleAddLoseSkills(me, xiaoji.name)
    room:useCard{ from = me, tos = { me }, card = spear }
    room:useCard{ from = me, tos = { me }, card = armor }
    room:throwCard(me:getCardIds("e"), nil, me, me)
  end)
  lu.assertEquals(me:getHandcardNum(), 4)
end)

return xiaoji
