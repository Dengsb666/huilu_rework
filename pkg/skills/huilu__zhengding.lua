-- SPDX-License-Identifier: GPL-3.0-or-later

local zhengding = fk.CreateSkill{
  name = "huilu__zhengding",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["huilu__zhengding"] = "正订",
  [":huilu__zhengding"] = "锁定技，当你于回合外使用或打出牌响应其他角色使用的牌时，若这两张牌颜色相同，你加1点体力上限，然后摸两张牌。",

  ["$huilu__zhengding1"] = "二论相订，是非乃见。",
  ["$huilu__zhengding2"] = "正乱序朝纲，订太平文王之道。",
}

local function applyReward(player)
  local room = player.room
  room:changeMaxHp(player, 1)
  if player:isAlive() then player:drawCards(2, zhengding.name) end
end

local spec = {
  on_use = function(self, event, target, player, data)
    applyReward(player)
  end,
}

zhengding:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhengding.name) and data.responseToEvent and
      player.room.current ~= player and data.toCard and data.toCard:compareColorWith(data.card) and
      data.responseToEvent.from ~= player
  end,
  on_use = spec.on_use,
})

zhengding:addEffect(fk.CardResponding, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhengding.name) and data.responseToEvent and
      player.room.current ~= player and data.responseToEvent.card and
      data.responseToEvent.card:compareColorWith(data.card) and data.responseToEvent.from ~= player
  end,
  on_use = spec.on_use,
})

zhengding:addTest(function(room, me)
  local oldMaxHp = me.maxHp
  FkTest.runInRoom(function()
    applyReward(me)
  end)
  lu.assertEquals(me.maxHp, oldMaxHp + 1)
  lu.assertEquals(me:getHandcardNum(), 2)
end)

return zhengding
