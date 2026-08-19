-- SPDX-License-Identifier: GPL-3.0-or-later

local qingya = fk.CreateSkill{
  name = "huilu__qingya",
}

Fk:loadTranslationTable{
  ["huilu__qingya"] = "倾轧",
  [":huilu__qingya"] = "当你使用【杀】指定唯一目标后，你可以选择一个方向，弃置你与其之间沿此方向的角色各一张手牌。本回合下个阶段结束时，你可以使用其中一张牌。",

  ["#huilu__qingya-invoke"] = "倾轧：选择一个方向，弃置你与 %dest 之间沿此方向的角色各一张手牌",
  ["#huilu__qingya-use"] = "倾轧：你可以使用其中一张牌",

  ["$huilu__qingya1"] = "罡风从虎，威震四方。",
  ["$huilu__qingya2"] = "铁车过处，寸草不生。",
}

local function getRoutePlayers(player, to, direction)
  local route = {}
  if direction == "clockwise" then
    local current = to.next
    while current ~= player do
      if not current.dead then table.insert(route, current) end
      current = current.next
    end
  else
    local current = player.next
    while current ~= to do
      if not current.dead then table.insert(route, current) end
      current = current.next
    end
  end
  return route
end

local function hasInterveningPlayersOnBothSides(player, to)
  return #getRoutePlayers(player, to, "clockwise") > 0 and
    #getRoutePlayers(player, to, "anticlockwise") > 0
end

qingya:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingya.name) and data.card.trueName == "slash" and
      data:isOnlyTarget(data.to) and not data.to.dead and #player.room.alive_players > 3 and
      hasInterveningPlayersOnBothSides(player, data.to)
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = { "clockwise", "anticlockwise", "Cancel" },
      skill_name = qingya.name,
      prompt = "#huilu__qingya-invoke::" .. data.to.id,
    })
    if choice ~= "Cancel" then
      local tos = getRoutePlayers(player, data.to, choice)
      player.room:sortByAction(tos)
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local info = { 0, {} }
    local phaseEvent = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
    if phaseEvent then info[1] = phaseEvent.id end

    for _, p in ipairs(event:getCostData(self).tos) do
      if not (p.dead or p:isKongcheng()) then
        local card = room:askToChooseCard(player, {
          target = p,
          flag = "h",
          skill_name = qingya.name,
        })
        table.insertIfNeed(info[2], card)
        room:throwCard(card, qingya.name, p, player)
        if player.dead then return end
      end
    end
    room:addTableMark(player, "huilu__qingya-turn", info)
  end,
})

qingya:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("huilu__qingya-turn") == 0 or player.dead then return false end

    local room = player.room
    local cards, currentId, remaining = {}, -1, {}
    local phaseEvent = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
    if phaseEvent then currentId = phaseEvent.id end
    for _, info in ipairs(player:getMark("huilu__qingya-turn")) do
      if info[1] ~= currentId then
        table.insertTableIfNeed(cards, info[2])
      else
        table.insert(remaining, info)
      end
    end
    room:setPlayerMark(player, "huilu__qingya-turn", #remaining > 0 and remaining or 0)
    cards = table.filter(cards, function(id)
      return table.contains(room.discard_pile, id)
    end)
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards = event:getCostData(self).cards
    player.room:askToUseRealCard(player, {
      pattern = cards,
      skill_name = qingya.name,
      prompt = "#huilu__qingya-use",
      extra_data = {
        bypass_times = true,
        extraUse = true,
        expand_pile = cards,
      },
    })
  end,
})

qingya:addTest(function(room, me)
  local general = Fk.generals["huilu__ol__yadan"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "yadan")
  lu.assertEquals(general.kingdom, "qun")
  lu.assertEquals(general.hp, 4)
  lu.assertTrue(table.contains(general.other_skills, qingya.name))
  lu.assertTrue(table.contains(general.other_skills, "huilu__tielun"))

  local p1, p2, p3, p4, p5 = {}, {}, {}, {}, {}
  p1.next, p2.next, p3.next, p4.next, p5.next = p2, p3, p4, p5, p1
  p1.dead, p2.dead, p3.dead, p4.dead, p5.dead = false, false, false, false, false
  lu.assertEquals(#getRoutePlayers(p1, p4, "anticlockwise"), 2)
  lu.assertEquals(#getRoutePlayers(p1, p4, "clockwise"), 1)
  lu.assertTrue(hasInterveningPlayersOnBothSides(p1, p4))
end)

return qingya
