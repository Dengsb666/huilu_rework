-- SPDX-License-Identifier: GPL-3.0-or-later

local zhizhe = fk.CreateSkill{
  name = "huilu__zhizhe",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["huilu__zhizhe"] = "智哲",
  [":huilu__zhizhe"] = "限定技，出牌阶段，你可以展示一张手牌中的锦囊牌，然后获得一张与其花色和点数相同的基本牌：若展示牌为<font color='red'>♥</font>，此牌为【桃】；若为♠，此牌为【杀】；若为<font color='red'>♦</font>，此牌为【闪】；若为♣，此牌为【酒】。每回合限一次，当以此法获得的牌因你使用或打出而进入弃牌堆后，你可以弃置一张牌并获得之。",

  ["#huilu__zhizhe"] = "智哲：展示一张锦囊牌，获得一张花色和点数相同的基本牌",
  ["#huilu__zhizhe-reclaim"] = "智哲：你可以弃置一张牌，获得弃牌堆中的智哲牌%arg",
  ["@@huilu__zhizhe-inhand"] = "智哲",

  ["$huilu__zhizhe1"] = "轻舟载浊酒，此去，我欲借箭十万。",
  ["$huilu__zhizhe2"] = "主公有多大胆略，亮便有多少谋略。",
}

local basicCardBySuit = {
  [Card.Heart] = "peach",
  [Card.Spade] = "slash",
  [Card.Diamond] = "jink",
  [Card.Club] = "analeptic",
}

local function getBasicCardName(suit)
  return basicCardBySuit[suit]
end

local function hasDiscardableCard(player)
  return table.find(player:getCardIds("he"), function(id)
    return not player:prohibitDiscard(id)
  end) ~= nil
end

local function getReclaimableCards(room, player, data)
  local toConfirm, toObtain = {}, {}
  for _, move in ipairs(data) do
    if move.toArea == Card.DiscardPile and move.from == nil then
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.Processing and
          (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResponse) and
          table.contains(room.discard_pile, info.cardId) then
          table.insert(toConfirm, info.cardId)
        end
      end
    end
  end

  if #toConfirm == 0 then return toObtain end
  local moveEvent = room.logic:getCurrentEvent()
  local parentEvent = moveEvent.parent
  if not parentEvent or
    (parentEvent.event ~= GameEvent.UseCard and parentEvent.event ~= GameEvent.RespondCard) then
    return toObtain
  end

  local use = parentEvent.data ---@type UseCardData|RespondCardData
  if use.from ~= player or not use.subcardsFromInfo then return toObtain end
  for _, info in ipairs(use.subcardsFromInfo) do
    if table.removeOne(toConfirm, info.cardId) and info.from == player and
      info.beforeCard:getMark("@@huilu__zhizhe-inhand") > 0 then
      table.insert(toObtain, info.cardId)
    end
  end
  return room.logic:moveCardsHoldingAreaCheck(toObtain)
end

zhizhe:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#huilu__zhizhe",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedEffectTimes(zhizhe.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select) and
      card.type == Card.TypeTrick and getBasicCardName(card.suit) ~= nil
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local original = Fk:getCardById(effect.cards[1], true)
    player:showCards(effect.cards)
    local card = room:printCard(getBasicCardName(original.suit), original.suit, original.number)
    room:obtainCard(player, card, false, fk.ReasonJustMove, player, zhizhe.name,
      { "@@huilu__zhizhe-inhand", 1 })
  end,
})

zhizhe:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(zhizhe.name) or
      player:getMark("huilu__zhizhe-reclaim-turn") > 0 or
      not hasDiscardableCard(player) then
      return false
    end
    local cards = getReclaimableCards(player.room, player, data)
    if #cards > 0 then
      event:setCostData(self, { reclaim_cards = cards })
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local reclaimCards = event:getCostData(self).reclaim_cards
    local cards = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhizhe.name,
      prompt = "#huilu__zhizhe-reclaim:::" .. Fk:getCardById(reclaimCards[1]):toLogString(),
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, { cards = cards, reclaim_cards = reclaimCards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self)
    room:setPlayerMark(player, "huilu__zhizhe-reclaim-turn", 1)
    room:throwCard(costData.cards, zhizhe.name, player, player)
    local cards = table.filter(costData.reclaim_cards, function(id)
      return room:getCardArea(id) == Card.DiscardPile
    end)
    if #cards > 0 and not player.dead then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, zhizhe.name)
    end
  end,
})

zhizhe:addTest(function(room, me)
  lu.assertEquals(getBasicCardName(Card.Heart), "peach")
  lu.assertEquals(getBasicCardName(Card.Spade), "slash")
  lu.assertEquals(getBasicCardName(Card.Diamond), "jink")
  lu.assertEquals(getBasicCardName(Card.Club), "analeptic")
  lu.assertNil(getBasicCardName(Card.NoSuit))

  local trickId = table.find(room.draw_pile, function(id)
    local card = Fk:getCardById(id)
    return card.type == Card.TypeTrick and getBasicCardName(card.suit) ~= nil
  end)
  lu.assertNotNil(trickId)
  FkTest.runInRoom(function()
    room:obtainCard(me, trickId)
    Fk.skills[zhizhe.name]:onUse(room, { from = me, tos = {}, cards = { trickId } })
  end)

  local original = Fk:getCardById(trickId)
  local copiedId = table.find(me:getCardIds("h"), function(id)
    return Fk:getCardById(id, true):getMark("@@huilu__zhizhe-inhand") > 0
  end)
  lu.assertNotNil(copiedId)
  local copied = Fk:getCardById(copiedId)
  lu.assertEquals(copied.name, getBasicCardName(original.suit))
  lu.assertEquals(copied.suit, original.suit)
  lu.assertEquals(copied.number, original.number)
  lu.assertTrue(table.contains(me:getCardIds("h"), trickId))
end)

zhizhe:addTest(function(room, me)
  local comp2 = room.players[2]
  local trickId = table.find(room.draw_pile, function(id)
    local card = Fk:getCardById(id)
    return card.type == Card.TypeTrick and card.suit == Card.Spade
  end)
  local costId = table.find(room.draw_pile, function(id)
    return id ~= trickId and not me:prohibitDiscard(id)
  end)
  lu.assertNotNil(trickId)
  lu.assertNotNil(costId)

  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, zhizhe.name)
    room:obtainCard(me, { trickId, costId })
    Fk.skills[zhizhe.name]:onUse(room, { from = me, tos = {}, cards = { trickId } })
  end)
  local copiedId = table.find(me:getCardIds("h"), function(id)
    return Fk:getCardById(id, true):getMark("@@huilu__zhizhe-inhand") > 0
  end)
  lu.assertNotNil(copiedId)
  lu.assertEquals(Fk:getCardById(copiedId).trueName, "slash")

  FkTest.setNextReplies(me, { {
    card = { skill = "discard_skill", subcards = { costId } },
    targets = {},
  } })
  FkTest.setNextReplies(comp2, { "__cancel" })
  FkTest.runInRoom(function()
    room:useCard{
      from = me,
      tos = { comp2 },
      card = Fk:getCardById(copiedId),
      extraUse = true,
    }
  end)
  lu.assertEquals(room:getCardArea(costId), Card.DiscardPile)
  lu.assertEquals(room:getCardArea(copiedId), Card.PlayerHand)
  lu.assertEquals(me:getMark("huilu__zhizhe-reclaim-turn"), 1)
end)

return zhizhe
