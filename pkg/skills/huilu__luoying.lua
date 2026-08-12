-- SPDX-License-Identifier: GPL-3.0-or-later

local luoying = fk.CreateSkill {
  name = "huilu__luoying",
}

local fu_mark = "@huilu__fuyue-inhand"

Fk:loadTranslationTable{
  ["huilu__luoying"] = "落英",
  [":huilu__luoying"] = "你的回合外，当♣牌因弃置进入弃牌堆后，你可以获得之，然后你可以将至多等量的手牌标记为“赋”。",

  ["#huilu__luoying-invoke"] = "落英：你可以获得此次因弃置进入弃牌堆的梅花牌",
  ["#huilu__luoying-choose"] = "落英：选择要获得的梅花牌",
  ["#huilu__luoying-mark"] = "落英：你可以选择至多 %arg 张手牌标记为“赋”",
  ["huilu__luoying_get_all"] = "全部获得",

  ["$huilu__luoying1"] = "这些都是我的。",
  ["$huilu__luoying2"] = "别着急扔，给我就好。",
}

---@param room Room
---@param card Card
local function markAsFu(room, card)
  local choices = table.filter(Fk:getAllCardNames("btd", true), function(name)
    return name ~= card.trueName
  end)
  if #choices > 0 then
    room:setCardMark(card, fu_mark, room:tableRandomPick(choices))
  end
end

luoying:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(luoying.name) or player.room.current == player then return false end

    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).suit == Card.Club then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end

    ids = table.filter(ids, function(id)
      return player.room:getCardArea(id) == Card.DiscardPile
    end)
    ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
    if #ids > 0 then
      event:setCostData(self, { cards = ids })
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(event:getCostData(self).cards)
    if not room:askToSkillInvoke(player, {
      skill_name = luoying.name,
      prompt = "#huilu__luoying-invoke",
    }) then
      return false
    end

    if #ids > 1 then
      local cards, choice = room:askToChooseCardsAndChoice(player, {
        cards = ids,
        min_num = 1,
        max_num = #ids,
        skill_name = luoying.name,
        prompt = "#huilu__luoying-choose",
        cancel_choices = { "huilu__luoying_get_all" },
      })
      if choice ~= "huilu__luoying_get_all" and #cards > 0 then
        ids = cards
      end
    end
    event:setCostData(self, { cards = ids })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(event:getCostData(self).cards, function(id)
      return room:getCardArea(id) == Card.DiscardPile
    end)
    if #ids == 0 then return end

    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, luoying.name, nil, true, player)
    if player.dead then return end

    local candidates = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id, true):getMark(fu_mark) == 0
    end)
    local n = math.min(#ids, #candidates)
    if n == 0 then return end

    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = n,
      include_equip = false,
      skill_name = luoying.name,
      pattern = tostring(Exppattern { id = candidates }),
      prompt = "#huilu__luoying-mark:::" .. n,
      cancelable = true,
    })
    for _, id in ipairs(cards) do
      markAsFu(room, Fk:getCardById(id, true))
    end
  end,
})

luoying:addTest(function(room, me)
  lu.assertNotNil(Fk.skills[luoying.name])
  lu.assertTrue(table.contains(Fk.generals["huilu__mu__caozhi"].other_skills, luoying.name))
end)

return luoying
