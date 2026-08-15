-- SPDX-License-Identifier: GPL-3.0-or-later

local qingshi = fk.CreateSkill{
  name = "huilu__qingshi",
  related_skills = { "huilu__guanxing" },
}

Fk:loadTranslationTable{
  ["huilu__qingshi"] = "情势",
  [":huilu__qingshi"] = "每回合限一次，当你使用牌时，若你的手牌中有与此牌牌名相同的牌，你可以发动一次〖观星〗。",

  ["#huilu__qingshi-invoke"] = "情势：你可以发动一次“观星”（当前使用牌为%arg）",

  ["$huilu__qingshi1"] = "兵者，行霸道之势，彰王道之实。",
  ["$huilu__qingshi2"] = "将为军魂，可因势而袭，其有战无类。",
}

local function hasSameNameInHand(player, card)
  return table.find(player:getCardIds("h"), function(id)
    return Fk:getCardById(id).trueName == card.trueName
  end) ~= nil
end

local function getGuanxingCount(player)
  return math.max(0, 7 - player.hp)
end

local function askForGuanxing(room, player)
  local n = getGuanxingCount(player)
  if n == 0 then return end
  room:askToGuanxing(player, {
    cards = room:getNCards(n),
    skill_name = "huilu__guanxing",
  })
end

qingshi:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingshi.name) and
      player:usedSkillTimes(qingshi.name, Player.HistoryTurn) == 0 and
      hasSameNameInHand(player, data.card)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qingshi.name,
      prompt = "#huilu__qingshi-invoke:::" .. data.card:toLogString(),
    })
  end,
  on_use = function(self, event, target, player, data)
    askForGuanxing(player.room, player)
  end,
})

qingshi:addTest(function(room, me)
  lu.assertEquals(getGuanxingCount({ hp = 3 }), 4)
  lu.assertEquals(getGuanxingCount({ hp = 1 }), 6)

  local sameName = {}
  for _, id in ipairs(room.draw_pile) do
    local card = Fk:getCardById(id)
    sameName[card.trueName] = sameName[card.trueName] or {}
    table.insert(sameName[card.trueName], id)
    if #sameName[card.trueName] == 2 then
      local ids = sameName[card.trueName]
      FkTest.runInRoom(function()
        room:obtainCard(me, ids)
      end)
      lu.assertTrue(hasSameNameInHand(me, Fk:getCardById(ids[1])))
      return
    end
  end
  lu.fail("牌堆中没有两张同名牌，无法测试情势")
end)

return qingshi
