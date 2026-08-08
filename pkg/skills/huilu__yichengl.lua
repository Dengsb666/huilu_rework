-- SPDX-License-Identifier: GPL-3.0-or-later

local yicheng = fk.CreateSkill{
  name = "huilu__yichengl",
}

Fk:loadTranslationTable{
  ["huilu__yichengl"] = "易城",
  [":huilu__yichengl"] = "出牌阶段限一次，你可以展示牌堆顶X张牌（X为你的体力上限），然后可以用任意张手牌交换其中等量张。若你以此法交换过牌且展示牌点数之和因此增加，你可以用所有手牌交换展示牌。",

  ["#huilu__yichengl"] = "易城：展示牌堆顶%arg张牌，并可以用手牌交换其中等量张牌",
  ["#huilu__yichengl-exchange"] = "易城：你可以用任意张手牌交换等量展示牌；不交换则无事发生（原点数和：%arg）",
  ["#huilu__yichengl-whole"] = "易城：展示牌点数和因交换而增加，是否用所有手牌交换全部展示牌？",
  ["#huilu__yichengl-order"] = "易城：排列将置于牌堆顶的所有手牌",

  ["$huilu__yichengl1"] = "改帜易土，当奉玄德公为汝南之主。",
  ["$huilu__yichengl2"] = "地无常主，人有恒志，其择木而栖。",
}

local function sumCardNumbers(ids)
  local sum = 0
  for _, id in ipairs(ids) do
    sum = sum + Fk:getCardById(id).number
  end
  return sum
end

local function shouldOfferWholeExchange(exchangedCount, oldSum, newSum)
  return exchangedCount > 0 and newSum > oldSum
end

yicheng:addEffect("active", {
  prompt = function(self, player)
    return "#huilu__yichengl:::"..player.maxHp
  end,
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(yicheng.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local revealed = room:getNCards(player.maxHp)
    room:turnOverCardsFromDrawPile(player, revealed, yicheng.name)

    local oldSum = sumCardNumbers(revealed)
    local hand = player:getCardIds("h")
    local cardmap = { revealed, hand }
    if #hand > 0 then
      cardmap = room:askToArrangeCards(player, {
        skill_name = yicheng.name,
        card_map = {
          "Top", revealed,
          "$Hand", hand,
        },
        prompt = "#huilu__yichengl-exchange:::" .. oldSum,
        min_limit = { #revealed, #hand },
        max_limit = { #revealed, #hand },
      })
    end

    local displayed = cardmap[1]
    local handToDisplay = table.filter(displayed, function(id)
      return not table.contains(revealed, id)
    end)
    local displayToHand = table.filter(revealed, function(id)
      return not table.contains(displayed, id)
    end)

    local exchanged = #handToDisplay > 0 and #handToDisplay == #displayToHand
    if exchanged then
      room:moveCardTo(handToDisplay, Card.Processing, nil, fk.ReasonJustMove, yicheng.name, nil, true, player)
      room:moveCardTo(displayToHand, Card.PlayerHand, player, fk.ReasonJustMove, yicheng.name, nil, true, player)

      if player.dead then
        room:cleanProcessingArea(displayed)
        return
      end

      local newSum = sumCardNumbers(displayed)
      if shouldOfferWholeExchange(#handToDisplay, oldSum, newSum) and
        room:askToSkillInvoke(player, {
          skill_name = yicheng.name,
          prompt = "#huilu__yichengl-whole",
        }) then
        local allHand = player:getCardIds("h")
        local top = room:askToArrangeCards(player, {
          skill_name = yicheng.name,
          card_map = { "Top", allHand },
          prompt = "#huilu__yichengl-order",
          free_arrange = true,
          min_limit = { #allHand },
          max_limit = { #allHand },
        })[1]

        room:moveCards{
          ids = table.reverse(top),
          from = player,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = yicheng.name,
          proposer = player,
          moveVisible = true,
        }
        if player.dead then
          room:cleanProcessingArea(displayed)
        else
          room:moveCardTo(displayed, Card.PlayerHand, player, fk.ReasonJustMove, yicheng.name, nil, true, player)
        end
        return
      end
    end

    room:returnCardsToDrawPile(player, displayed, yicheng.name)
  end,
})

yicheng:addTest(function(room, me)
  local general = Fk.generals["huilu__ol__liupi"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "liupi")
  lu.assertTrue(table.contains(general.other_skills, yicheng.name))
  lu.assertFalse(shouldOfferWholeExchange(0, 10, 20))
  lu.assertFalse(shouldOfferWholeExchange(1, 10, 10))
  lu.assertFalse(shouldOfferWholeExchange(1, 10, 9))
  lu.assertTrue(shouldOfferWholeExchange(1, 10, 11))
end)

yicheng:addTest(function(room, me)
  local handId = room.draw_pile[#room.draw_pile]
  FkTest.runInRoom(function()
    room:obtainCard(me, handId)
  end)
  local revealed = table.slice(room.draw_pile, 1, me.maxHp + 1)
  FkTest.setNextReplies(me, {
    { revealed, { handId } },
  })

  FkTest.runInRoom(function()
    Fk.skills[yicheng.name]:onUse(room, { from = me, tos = {}, cards = {} })
  end)

  lu.assertItemsEquals(me:getCardIds("h"), { handId })
  for _, id in ipairs(revealed) do
    lu.assertEquals(room:getCardArea(id), Card.DrawPile)
  end
end)

yicheng:addTest(function(room, me)
  local lowId, highId = room.draw_pile[1], room.draw_pile[1]
  for _, id in ipairs(room.draw_pile) do
    if Fk:getCardById(id).number < Fk:getCardById(lowId).number then lowId = id end
    if Fk:getCardById(id).number > Fk:getCardById(highId).number then highId = id end
  end
  lu.assertTrue(Fk:getCardById(highId).number > Fk:getCardById(lowId).number)

  FkTest.runInRoom(function()
    room:obtainCard(me, highId)
    table.removeOne(room.draw_pile, lowId)
    table.insert(room.draw_pile, 1, lowId)
  end)

  local revealed = table.slice(room.draw_pile, 1, me.maxHp + 1)
  local displayed = table.simpleClone(revealed)
  displayed[1] = highId
  FkTest.setNextReplies(me, {
    { displayed, { lowId } },
    "__cancel",
  })

  FkTest.runInRoom(function()
    Fk.skills[yicheng.name]:onUse(room, { from = me, tos = {}, cards = {} })
  end)

  lu.assertItemsEquals(me:getCardIds("h"), { lowId })
  lu.assertEquals(room:getCardArea(highId), Card.DrawPile)
  for _, id in ipairs(table.slice(revealed, 2)) do
    lu.assertNotEquals(room:getCardArea(id), Card.PlayerHand)
  end
end)

return yicheng
