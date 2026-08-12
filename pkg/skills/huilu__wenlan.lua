-- SPDX-License-Identifier: GPL-3.0-or-later

local wenlan = fk.CreateSkill {
  name = "huilu__wenlan",
}

local fu_mark = "@huilu__fuyue-inhand"
local count_mark = "huilu__wenlan_count"
local mark_used = "huilu__wenlan_mark-turn"
local reset_used = "huilu__wenlan_reset-turn"

Fk:loadTranslationTable{
  ["huilu__wenlan"] = "文澜",
  [":huilu__wenlan"] = "你每使用两张“赋”后，可以选择一项（每回合每项限一次）：1.将两张手牌标记为“赋”；"..
  "2.选择任意张手牌中的“赋”，重置其额外牌名。",

  ["#huilu__wenlan-invoke"] = "文澜：你已使用两张“赋”，可以标记两张新的“赋”或重置部分“赋”的牌名",
  ["#huilu__wenlan-mark"] = "文澜：选择两张手牌标记为“赋”",
  ["#huilu__wenlan-reset"] = "文澜：选择任意张“赋”，重置其额外牌名",
  ["huilu__wenlan_mark"] = "将两张手牌标记为“赋”",
  ["huilu__wenlan_reset"] = "重置任意张“赋”的额外牌名",

  ["$huilu__wenlan1"] = "胸中万仞，寥落纸上数言。",
  ["$huilu__wenlan2"] = "欲写当年白马篇，笺已破，笔已残。",
}

---@param data UseCardData
local function isFuUse(data)
  local infos = data.subcardsFromInfo
  return infos and #infos == 1 and infos[1].beforeCard:getMark(fu_mark) ~= 0
end

---@param room Room
---@param card Card
---@param reset boolean?
local function markAsFu(room, card, reset)
  local old_name = reset and card:getMark(fu_mark) or nil
  local names = table.filter(Fk:getAllCardNames("btd", true), function(name)
    return name ~= card.trueName and name ~= old_name
  end)
  if #names > 0 then
    room:setCardMark(card, fu_mark, room:tableRandomPick(names))
  end
end

---@param player ServerPlayer
---@return string[]
local function getChoices(player)
  local unmarked = table.filter(player:getCardIds("h"), function(id)
    return Fk:getCardById(id, true):getMark(fu_mark) == 0
  end)
  local marked = table.filter(player:getCardIds("h"), function(id)
    return Fk:getCardById(id, true):getMark(fu_mark) ~= 0
  end)
  local choices = {}
  if #unmarked >= 2 and player:getMark(mark_used) == 0 then
    table.insert(choices, "huilu__wenlan_mark")
  end
  if #marked > 0 and player:getMark(reset_used) == 0 then
    table.insert(choices, "huilu__wenlan_reset")
  end
  return choices
end

wenlan:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(wenlan.name) and isFuUse(data)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, count_mark, 1)
    if player:getMark(count_mark) >= 2 and #getChoices(player) == 0 then
      room:setPlayerMark(player, count_mark, player:getMark(count_mark) - 2)
    end
  end,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wenlan.name) and
      player:getMark(count_mark) >= 2 and isFuUse(data)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, count_mark, player:getMark(count_mark) - 2)

    local choices = getChoices(player)
    if #choices == 0 then return false end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = wenlan.name,
      prompt = "#huilu__wenlan-invoke",
      cancelable = true,
    })
    if choice == "Cancel" then return false end
    event:setCostData(self, { choice = choice })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice == "huilu__wenlan_mark" then
      room:setPlayerMark(player, mark_used, 1)
      local candidates = table.filter(player:getCardIds("h"), function(id)
        return Fk:getCardById(id, true):getMark(fu_mark) == 0
      end)
      if #candidates < 2 then return end
      local cards = room:askToCards(player, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = wenlan.name,
        pattern = tostring(Exppattern { id = candidates }),
        prompt = "#huilu__wenlan-mark",
        cancelable = false,
      })
      for _, id in ipairs(cards) do
        markAsFu(room, Fk:getCardById(id, true))
      end
    else
      room:setPlayerMark(player, reset_used, 1)
      local candidates = table.filter(player:getCardIds("h"), function(id)
        return Fk:getCardById(id, true):getMark(fu_mark) ~= 0
      end)
      if #candidates == 0 then return end
      local cards = room:askToCards(player, {
        min_num = 1,
        max_num = #candidates,
        include_equip = false,
        skill_name = wenlan.name,
        pattern = tostring(Exppattern { id = candidates }),
        prompt = "#huilu__wenlan-reset",
        cancelable = false,
      })
      for _, id in ipairs(cards) do
        markAsFu(room, Fk:getCardById(id, true), true)
      end
    end
  end,
})

wenlan:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, count_mark, 0)
end)

wenlan:addTest(function(room, me)
  lu.assertNotNil(Fk.skills[wenlan.name])
  lu.assertTrue(table.contains(Fk.generals["huilu__mu__caozhi"].other_skills, wenlan.name))
end)

wenlan:addTest(function(room, me)
  local first = room:printCard("crossbow")
  local second = room:printCard("eight_diagram")
  local kept = room:printCard("jink")

  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, wenlan.name)
    room:obtainCard(me, { first, second, kept })
    markAsFu(room, first)
    markAsFu(room, second)
    markAsFu(room, kept)
  end)
  FkTest.runInRoom(function()
    room:useCard { from = me, tos = { me }, card = first }
  end)
  lu.assertEquals(me:getMark(count_mark), 1)

  FkTest.setNextReplies(me, { "1", "1", "huilu__wenlan_reset" })
  FkTest.runInRoom(function()
    room:useCard { from = me, tos = { me }, card = second }
  end)

  lu.assertEquals(me:getMark(count_mark), 0)
  lu.assertNotEquals(kept:getMark(fu_mark), 0)
  lu.assertNotEquals(kept:getMark(fu_mark), kept.trueName)
end)

wenlan:addTest(function(room, me)
  local marked = room:printCard("jink")
  local first = room:printCard("slash")
  local second = room:printCard("peach")
  FkTest.runInRoom(function()
    room:obtainCard(me, { marked, first, second })
    markAsFu(room, marked)
  end)

  lu.assertItemsEquals(getChoices(me), {
    "huilu__wenlan_mark",
    "huilu__wenlan_reset",
  })
  FkTest.runInRoom(function()
    room:setPlayerMark(me, mark_used, 1)
  end)
  lu.assertItemsEquals(getChoices(me), { "huilu__wenlan_reset" })
  FkTest.runInRoom(function()
    room:setPlayerMark(me, reset_used, 1)
  end)
  lu.assertItemsEquals(getChoices(me), {})
end)

return wenlan
