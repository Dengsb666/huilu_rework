-- SPDX-License-Identifier: GPL-3.0-or-later

local fuyue = fk.CreateSkill {
  name = "huilu__fuyue",
  tags = { Skill.Compulsory },
}

local fu_mark = "@huilu__fuyue-inhand"

Fk:loadTranslationTable{
  ["huilu__fuyue"] = "赋乐",
  [":huilu__fuyue"] = "锁定技，你的初始手牌均标记为“赋”且不计入手牌上限。“赋”随机获得另一种非装备牌牌名，"..
  "你使用“赋”时可以选择使用该牌所拥有的任意一种牌名。",

  [fu_mark] = "赋",
  ["#huilu__fuyue-viewas"] = "赋乐：按“赋”记录的牌名使用此牌",

  ["$huilu__fuyue1"] = "曲终人不见，邺下风冷，落梅如坟。",
  ["$huilu__fuyue2"] = "人言江南丝竹好，偏我来时不逢春。",
}

---@param room Room
---@param card Card
---@param reset boolean?
local function markAsFu(room, card, reset)
  local old_name = reset and card:getMark(fu_mark) or nil
  local choices = table.filter(Fk:getAllCardNames("btd", true), function(name)
    return name ~= card.trueName and name ~= old_name
  end)
  if #choices > 0 then
    room:setCardMark(card, fu_mark, room:tableRandomPick(choices))
  end
end

fuyue:addEffect("viewas", {
  prompt = "#huilu__fuyue-viewas",
  pattern = ".",
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|hand",
  },
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local name = Fk:getCardById(to_select, true):getMark(fu_mark)
    if name == 0 then return false end
    local card = Fk:cloneCard(name, nil, nil, fuyue.name, to_select)
    return card and player:canUseOrResponseInCurrent(card)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    return Fk:cloneCard(Fk:getCardById(cards[1], true):getMark(fu_mark), nil, nil, fuyue.name, cards[1])
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
  enabled_at_nullification = function(self, player, data)
    return table.find(player:getCardIds("h"), function(id)
      return Fk:getCardById(id, true):getMark(fu_mark) == "nullification"
    end) ~= nil
  end,
})

fuyue:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuyue.name) and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      markAsFu(room, Fk:getCardById(id, true))
    end
  end,
})

fuyue:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return player:hasSkill(fuyue.name) and card:getMark(fu_mark) ~= 0
  end,
})

fuyue:addLoseEffect(function(self, player, is_death)
  local room = player.room
  for _, id in ipairs(player:getCardIds("h")) do
    room:setCardMark(Fk:getCardById(id, true), fu_mark, 0)
  end
end)

fuyue:addTest(function(room, me)
  local general = Fk.generals["huilu__mu__caozhi"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "caozhi")
  lu.assertTrue(table.contains(general.other_skills, fuyue.name))
end)

fuyue:addTest(function(room, me)
  local ids = table.slice(room.draw_pile, 1, 4)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, fuyue.name)
    room:obtainCard(me, ids)
    room.logic:trigger(fk.GameStart, room.current)
  end)

  for _, id in ipairs(ids) do
    local card = Fk:getCardById(id, true)
    local name = card:getMark(fu_mark)
    lu.assertNotEquals(name, 0)
    lu.assertNotEquals(name, card.trueName)
    lu.assertNotEquals(Fk:cloneCard(name).type, Card.TypeEquip)
  end
end)

return fuyue
