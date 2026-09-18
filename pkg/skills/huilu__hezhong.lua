-- SPDX-License-Identifier: GPL-3.0-or-later

local hezhong = fk.CreateSkill{
  name = "huilu__hezhong",
  max_turn_use_time = 1,
}

Fk:loadTranslationTable{
  ["huilu__hezhong"] = "和衷",
  [":huilu__hezhong"] = "每回合限一次，当你的手牌数变为1后，你可以展示手牌并摸一张牌，然后选择一项：本回合你使用的下一张点数大于或小于此牌点数的普通锦囊牌额外结算一次。",

  ["#huilu__hezhong-choice"] = "和衷：令你本回合点数大于或小于%arg的下一张普通锦囊额外结算一次",
  ["huilu__hezhong_greater"] = "大于",
  ["huilu__hezhong_less"] = "小于",
  ["@huilu__hezhong-turn"] = "和衷",

  ["$huilu__hezhong1"] = "家和而万事兴，国亦如是。",
  ["$huilu__hezhong2"] = "你我同殿为臣，理当协力齐心。",
}

local greater_mark = "huilu__hezhong_greater-turn"
local less_mark = "huilu__hezhong_less-turn"
local used_mark = "huilu__hezhong_used-turn"

---@param player ServerPlayer
local function updateHezhongMark(player)
  local n = player:getMark(greater_mark)
  if n > 0 then
    player.room:setPlayerMark(player, "@huilu__hezhong-turn", ">" .. n)
    return
  end
  n = player:getMark(less_mark)
  player.room:setPlayerMark(player, "@huilu__hezhong-turn", n > 0 and "&lt;" .. n or 0)
end

hezhong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(hezhong.name) or player:getHandcardNum() ~= 1 then
      return false
    end
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        return true
      end
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = player:getCardIds("h")[1]
    local n = Fk:getCardById(id).number
    player:showCards({ id })
    if player.dead then return end
    player:drawCards(1, hezhong.name)
    if player.dead then return end

    local choice = room:askToChoice(player, {
      choices = { "huilu__hezhong_greater", "huilu__hezhong_less" },
      skill_name = hezhong.name,
      prompt = "#huilu__hezhong-choice:::" .. n,
    })
    room:setPlayerMark(player, choice == "huilu__hezhong_greater" and greater_mark or less_mark, n)
    updateHezhongMark(player)
  end,
}, { check_skill_limit = true })

hezhong:addEffect(fk.CardUsing, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or #data.tos == 0 or not data.card:isCommonTrick() or
      data.card.number <= 0 or player:getMark(used_mark) > 0 then
      return false
    end
    return (player:getMark(greater_mark) > 0 and data.card.number > player:getMark(greater_mark)) or
      (player:getMark(less_mark) > 0 and data.card.number < player:getMark(less_mark))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, used_mark, 1)
    room:setPlayerMark(player, greater_mark, 0)
    room:setPlayerMark(player, less_mark, 0)
    updateHezhongMark(player)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

hezhong:addTest(function(room, me)
  local general = Fk.generals["huilu__ol__feiyi"]
  lu.assertNotNil(general)
  lu.assertTrue(table.contains(general.other_skills, hezhong.name))
end)

hezhong:addTest(function(room, me)
  local shown = room:printCard("slash", Card.Heart, 7)
  FkTest.setNextReplies(me, { "1", "huilu__hezhong_greater" })

  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, hezhong.name)
    room:obtainCard(me, shown)
  end)

  lu.assertEquals(me:getHandcardNum(), 2)
  lu.assertEquals(me:usedSkillTimes(hezhong.name, Player.HistoryTurn), 1)
  lu.assertEquals(me:getMark(greater_mark), 7)

  local drawn = table.find(me:getCardIds("h"), function(id)
    return id ~= shown.id
  end)
  FkTest.runInRoom(function()
    room:throwCard(drawn, hezhong.name, me, me)
  end)

  lu.assertEquals(me:getHandcardNum(), 1)
  lu.assertEquals(me:usedSkillTimes(hezhong.name, Player.HistoryTurn), 1)
end)

hezhong:addTest(function(room, me)
  local comp2 = room.players[2]
  local effect = hezhong.effects[2]
  local trick = room:printCard("duel", Card.Spade, 9)
  local data = { from = me, tos = { comp2 }, card = trick }

  FkTest.runInRoom(function()
    room:setPlayerMark(me, greater_mark, 7)
  end)
  lu.assertTrue(effect:triggerable(fk.CardUsing, me, me, data))

  FkTest.runInRoom(function()
    effect:use(fk.CardUsing, me, me, data)
  end)
  lu.assertEquals(data.additionalEffect, 1)
  lu.assertEquals(me:getMark(greater_mark), 0)
  lu.assertEquals(me:getMark(used_mark), 1)
  lu.assertFalse(effect:triggerable(fk.CardUsing, me, me, data))
end)

return hezhong
