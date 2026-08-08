-- SPDX-License-Identifier: GPL-3.0-or-later

local gongmou = fk.CreateSkill{
  name = "huilu__gongmou",
  related_skills = { "qice", "kanpo" },
}

Fk:loadTranslationTable{
  ["huilu__gongmou"] = "共谋",
  [":huilu__gongmou"] = "准备阶段，你可以与一名手牌数不大于你的其他角色交换手牌。若如此做，你获得〖奇策〗、其获得〖看破〗直到回合结束。",

  ["#huilu__gongmou-choose"] = "共谋：与一名手牌数不大于你的角色交换手牌；你获得“奇策”，其获得“看破”直到回合结束",

  ["$huilu__gongmou1"] = "夫居万死之地，必有死争之心。",
  ["$huilu__gongmou2"] = "大王案六军以示余力，何忧于败而欲自往？",
}

local function canChoosePartner(player, to)
  return to ~= player and to:getHandcardNum() <= player:getHandcardNum()
end

local function getEligiblePartners(room, player)
  return table.filter(room:getOtherPlayers(player, false), function(p)
    return canChoosePartner(player, p)
  end)
end

gongmou:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(gongmou.name) and player.phase == Player.Start and
      #getEligiblePartners(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = getEligiblePartners(room, player),
      skill_name = gongmou.name,
      prompt = "#huilu__gongmou-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not (player:isKongcheng() and to:isKongcheng()) then
      room:swapAllCards(player, { player, to }, gongmou.name)
    end
    if not player.dead and not player:hasSkill("qice", true) then
      room:handleAddLoseSkills(player, "qice")
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(player, "-qice")
      end)
    end
    if not to.dead and not to:hasSkill("kanpo", true) then
      room:handleAddLoseSkills(to, "kanpo")
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(to, "-kanpo")
      end)
    end
  end,
})

gongmou:addTest(function(room, me)
  local general = Fk.generals["huilu__m_shi__huanjie"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "huanjie")
  lu.assertTrue(table.contains(general.other_skills, gongmou.name))

  local twoCards = { getHandcardNum = function() return 2 end }
  local threeCards = { getHandcardNum = function() return 3 end }
  local otherThreeCards = { getHandcardNum = function() return 3 end }
  lu.assertTrue(canChoosePartner(threeCards, twoCards))
  lu.assertTrue(canChoosePartner(threeCards, otherThreeCards))
  lu.assertFalse(canChoosePartner(twoCards, threeCards))
  lu.assertFalse(canChoosePartner(twoCards, twoCards))
end)

return gongmou
