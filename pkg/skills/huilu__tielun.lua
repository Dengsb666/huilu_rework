-- SPDX-License-Identifier: GPL-3.0-or-later

local tielun = fk.CreateSkill{
  name = "huilu__tielun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["huilu__tielun"] = "铁轮",
  [":huilu__tielun"] = "锁定技，你计算至其他角色的距离-X（X为你于此轮内使用过的牌数）。当你使用牌后，若此时所有其他角色与你的距离均为1，你本轮手牌上限+1。",

  ["@huilu__tielun-round"] = "铁轮",
}

local function everyoneAtDistanceOne(player)
  return table.every(player.room:getOtherPlayers(player, false), function(p)
    return player:distanceTo(p) == 1
  end)
end

tielun:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(tielun.name) then
      return -from:getMark("@huilu__tielun-round")
    end
  end,
})

tielun:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(tielun.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@huilu__tielun-round")
    if everyoneAtDistanceOne(player) then
      room:addPlayerMark(player, MarkEnum.AddMaxCards .. "-round")
    end
  end,
})

tielun:addTest(function(room, me)
  local useData = { card = Fk:cloneCard("jink") }
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, tielun.name)
    room.logic:trigger(fk.AfterCardUseDeclared, me, useData)
    room.logic:trigger(fk.AfterCardUseDeclared, me, useData)
  end)
  lu.assertFalse(everyoneAtDistanceOne(me))
  lu.assertEquals(me:getMark(MarkEnum.AddMaxCards .. "-round"), 0)

  FkTest.runInRoom(function()
    room.logic:trigger(fk.AfterCardUseDeclared, me, useData)
  end)
  lu.assertTrue(everyoneAtDistanceOne(me))
  lu.assertEquals(me:getMark(MarkEnum.AddMaxCards .. "-round"), 1)

  FkTest.runInRoom(function()
    room.logic:trigger(fk.AfterCardUseDeclared, me, useData)
  end)
  lu.assertEquals(me:getMark("@huilu__tielun-round"), 4)
  lu.assertEquals(me:getMark(MarkEnum.AddMaxCards .. "-round"), 2)
end)

return tielun
