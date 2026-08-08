-- SPDX-License-Identifier: GPL-3.0-or-later

local xinghun = fk.CreateSkill{
  name = "huilu__xinghun",
}

Fk:loadTranslationTable{
  ["huilu__xinghun"] = "星魂",
  [":huilu__xinghun"] = "出牌阶段限一次，你可观看牌堆顶五张牌，用任意张手牌与其中等量牌进行交换并排序。然后你可以令一名其他角色选择并展示你手牌与牌堆顶共五张牌，你可以对其使用其中至多一张【杀】；若你以此法使用【杀】，此牌结算结束后，该角色可以观看牌堆顶五张牌并以任意顺序放回牌堆顶。",

  ["#huilu__xinghun"] = "星魂：观看、交换并排列牌堆顶的五张牌",
  ["#huilu__xinghun-exchange"] = "星魂：观看、交换并排列这些牌，进入下一步",
  ["#huilu__xinghun-choose"] = "星魂：你可以令一名其他角色选择五张牌展示；取消则结束技能",
  ["#huilu__xinghun-choosecard"] = "星魂：从牌堆顶及%src的手牌中选择五张牌展示",
  ["#huilu__xinghun-slash"] = "星魂：你可以选择展示牌中的至多一张【杀】，对%dest使用",
  ["#huilu__xinghun-reorder-invoke"] = "星魂：是否观看牌堆顶五张牌并调整其顺序？",
  ["#huilu__xinghun-reorder"] = "星魂：调整这五张牌的顺序；所有牌只能放回牌堆顶",
  ["huilu__xinghun-shown"] = "星魂展示牌",

  ["$huilu__xinghun1"] = "仰观紫微知兴替，俯察将星照铁衣。",
  ["$huilu__xinghun2"] = "既晓九星所向，傲破万难独前。",
}

local function getUsableSlashes(player, to, shown)
  return table.filter(shown, function(id)
    local card = Fk:getCardById(id)
    return card.trueName == "slash" and
      player:canUseTo(card, to, { bypass_distances = true, bypass_times = true })
  end)
end

xinghun:addEffect("active", {
  prompt = "#huilu__xinghun",
  anim_type = "offensive",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local skillName = xinghun.name
    local player = effect.from
    local cards = room:getNCards(5)
    room:turnOverCardsFromDrawPile(player, cards, skillName, false)
    local results = room:askToArrangeCards(player, {
      skill_name = skillName,
      card_map = {
        "Top", cards,
        "$Hand", player:getCardIds("h"),
      },
      prompt = "#huilu__xinghun-exchange",
      free_arrange = true,
    })

    local moveInfos = {}
    for _, id in ipairs(table.reverse(results[1])) do
      table.insert(moveInfos, {
        ids = { id },
        from = not table.contains(cards, id) and player or nil,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = skillName,
        moveVisible = false,
        proposer = player,
        visiblePlayers = { player },
      })
    end
    room:moveCards(table.unpack(moveInfos))

    cards = table.filter(results[2], function(id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      if player.dead then
        room:cleanProcessingArea(cards)
        return
      end
      room:obtainCard(player, cards, false, fk.ReasonJustMove, player, skillName)
      if player.dead then return end
    end

    local others = room:getOtherPlayers(player, false)
    if #others == 0 then return end
    local chosen = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = others,
      skill_name = skillName,
      prompt = "#huilu__xinghun-choose",
      cancelable = true,
    })
    if #chosen == 0 then return end
    local to = chosen[1]

    cards = room:getNCards(5)
    local handCards = player:getCardIds("h")
    local visible_data = {}
    for _, id in ipairs(cards) do
      visible_data[tostring(id)] = 0
    end
    for _, id in ipairs(handCards) do
      visible_data[tostring(id)] = false
    end
    local toShow = room:askToPoxi(to, {
      poxi_type = "AskForCardsChosen",
      data = {
        { "Top", cards },
        { "$Hand", handCards },
      },
      extra_data = {
        to = player.id,
        min = 5,
        max = 5,
        skillName = skillName,
        prompt = "#huilu__xinghun-choosecard:" .. player.id,
        visible_data = visible_data,
      },
      cancelable = false,
    })

    local shownHand = {}
    local shownTop = table.filter(toShow, function(id)
      if table.contains(cards, id) then
        return true
      end
      table.insert(shownHand, id)
    end)
    if #shownHand > 0 then
      player:showCards(shownHand, to)
    end
    if #shownTop > 0 then
      room:showCards(shownTop, nil, to)
    end
    room:delay(1000)

    local slashes = getUsableSlashes(player, to, toShow)
    if #slashes == 0 then return end
    local selected = room:askToChooseCards(player, {
      target = player,
      flag = { card_data = { { "huilu__xinghun-shown", slashes } } },
      min = 0,
      max = 1,
      skill_name = skillName,
      prompt = "#huilu__xinghun-slash::" .. to.id,
      cancelable = true,
    })
    if #selected == 0 or player.dead or to.dead then return end

    local slash = Fk:getCardById(selected[1])
    if slash.trueName ~= "slash" or
      not player:canUseTo(slash, to, { bypass_distances = true, bypass_times = true }) then
      return
    end
    room:useCard {
      from = player,
      card = slash,
      tos = { to },
      extraUse = true,
    }

    if not to.dead and room:askToSkillInvoke(to, {
      skill_name = skillName,
      prompt = "#huilu__xinghun-reorder-invoke",
    }) then
      room:askToGuanxing(to, {
        cards = room:getNCards(5),
        bottom_limit = { 0, 0 },
        skill_name = skillName,
        prompt = "#huilu__xinghun-reorder",
      })
    end
  end,
})

xinghun:addTest(function(room, me)
  local general = Fk.generals["huilu__mobile__godjiangwei"]
  lu.assertNotNil(general)
  lu.assertTrue(table.contains(general.other_skills, xinghun.name))

  local comp2 = room.players[2]
  local shown = {}
  for _, id in ipairs(room.draw_pile) do
    if Fk:getCardById(id).trueName == "slash" then
      table.insert(shown, id)
      if #shown == 2 then break end
    end
  end
  lu.assertEquals(#shown, 2)
  lu.assertEquals(#getUsableSlashes(me, comp2, shown), 2)
end)

xinghun:addTest(function(room, me)
  local originalTop = table.slice(room.draw_pile, 1, 6)
  local arrangedTop = table.slice(originalTop, 1, 6)
  FkTest.setNextReplies(me, {
    { arrangedTop, {} },
    "__cancel",
  })

  FkTest.runInRoom(function()
    Fk.skills[xinghun.name]:onUse(room, { from = me, tos = {}, cards = {} })
  end)

  lu.assertItemsEquals(me:getCardIds("h"), {})
  lu.assertEquals(table.slice(room.draw_pile, 1, 6), originalTop)
end)

xinghun:addTest(function(room, me)
  local comp2 = room.players[2]
  local slashId = table.find(room.draw_pile, function(id)
    return Fk:getCardById(id).trueName == "slash"
  end)
  lu.assertNotNil(slashId)
  FkTest.runInRoom(function()
    room:moveCardTo(slashId, Card.DrawPile)
  end)

  local shown = table.slice(room.draw_pile, 1, 6)
  lu.assertEquals(shown[1], slashId)
  local topAfterSlash = table.slice(room.draw_pile, 2, 7)
  local reordered = table.reverse(table.simpleClone(topAfterSlash))
  FkTest.setNextReplies(me, {
    { table.simpleClone(shown), {} },
    FkTest.ReplyChoosePlayer({ comp2 }),
    { slashId },
  })
  FkTest.setNextReplies(comp2, {
    table.simpleClone(shown),
    "__cancel",
    "1",
    { table.simpleClone(reordered) },
  })

  local oldHp = comp2.hp
  FkTest.runInRoom(function()
    Fk.skills[xinghun.name]:onUse(room, { from = me, tos = {}, cards = {} })
  end)

  lu.assertEquals(comp2.hp, oldHp - 1)
  lu.assertEquals(table.slice(room.draw_pile, 1, 6), reordered)
end)

return xinghun
