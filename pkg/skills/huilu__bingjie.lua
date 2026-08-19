-- SPDX-License-Identifier: GPL-3.0-or-later

local bingjie = fk.CreateSkill{
  name = "huilu__bingjie",
}

Fk:loadTranslationTable{
  ["huilu__bingjie"] = "秉节",
  [":huilu__bingjie"] = "出牌阶段开始时，你可以减1点体力上限，然后当你本回合使用【杀】或普通锦囊牌指定第一个目标后，除你以外的目标角色各弃置一张牌。",

  ["@@huilu__bingjie-turn"] = "秉节",

  ["$huilu__bingjie1"] = "秉节之使，衔命直指。",
  ["$huilu__bingjie2"] = "执德秉节，不负国恩。",
}

bingjie:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bingjie.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@huilu__bingjie-turn", 1)
    room:changeMaxHp(player, -1)
  end,
})

bingjie:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@huilu__bingjie-turn") > 0 and data.firstTarget and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      table.find(data.use.tos, function(p)
        return p ~= player and p:isAlive()
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.filter(data.use.tos, function(p)
      return p ~= player and p:isAlive()
    end)
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if to:isAlive() and not to:isNude() then
        room:askToDiscard(to, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = bingjie.name,
          cancelable = false,
        })
      end
    end
  end,
})

bingjie:addTest(function(room, me)
  local general = Fk.generals["huilu__ol__mamidi"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "mamidi")
  lu.assertEquals(general.kingdom, "qun")
  lu.assertEquals(general.hp, 4)
  lu.assertEquals(general.maxHp, 6)
  lu.assertTrue(table.contains(general.other_skills, bingjie.name))
  lu.assertTrue(table.contains(general.other_skills, "huilu__zhengding"))

  FkTest.setNextReplies(me, { "1", "" })
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, bingjie.name)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(me.maxHp, 3)
  lu.assertEquals(me:getMark("@@huilu__bingjie-turn"), 0)
end)

return bingjie
