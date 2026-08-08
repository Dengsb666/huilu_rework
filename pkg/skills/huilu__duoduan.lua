-- SPDX-License-Identifier: GPL-3.0-or-later

local duoduan = fk.CreateSkill {
  name = "huilu__duoduan"
}

Fk:loadTranslationTable{
  ["huilu__duoduan"] = "度断",
  [":huilu__duoduan"] = "每回合限一次，当你成为【杀】的目标后，你可重铸一张牌，然后你选择一项令此【杀】的使用者执行：1.摸两张牌令此【杀】无效；2.弃置一张牌令此【杀】不可被响应。",

  ["#huilu__duoduan-ask"] = "度断：你可重铸一张牌",
  ["#huilu__duoduan-choose"] = "度断：请选择一项令 %dest 执行",
  ["huilu__duoduan_draw"] = "其摸两张牌令此杀无效",
  ["huilu__duoduan_discard"] = "其弃置一张牌令此杀不可被响应",

  ["$huilu__duoduan1"] = "度势而谋，断计求胜。",
  ["$huilu__duoduan2"] = "逢敌先虑，定策后图。",
}

duoduan:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duoduan.name) and data.card.trueName == "slash" and
      not player:isNude() and player:usedSkillTimes(duoduan.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local cids = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = duoduan.name,
      prompt = "#huilu__duoduan-ask",
    })
    if #cids > 0 then
      event:setCostData(self, cids)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recastCard(event:getCostData(self), player, duoduan.name)
    local from = data.from
    if not from:isAlive() then return false end

    local choices = { "huilu__duoduan_draw" }
    if not from:isNude() then
      table.insert(choices, "huilu__duoduan_discard")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = duoduan.name,
      prompt = "#huilu__duoduan-choose::" .. from.id,
      all_choices = { "huilu__duoduan_draw", "huilu__duoduan_discard" },
    })

    if choice == "huilu__duoduan_draw" then
      from:drawCards(2, duoduan.name)
      data.use.nullifiedTargets = data.use.nullifiedTargets or {}
      table.forEach(room.players, function(p)
        table.insertIfNeed(data.use.nullifiedTargets, p)
      end)
    else
      if #room:askToDiscard(from, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = duoduan.name,
        cancelable = false,
      }) == 0 then
        return false
      end

      data.use.disresponsiveList = data.use.disresponsiveList or {}
      table.forEach(room.players, function(p)
        table.insertIfNeed(data.use.disresponsiveList, p)
      end)
    end
  end,
})

duoduan:addTest(function(room, me)
  lu.assertNotNil(Fk.skills[duoduan.name])
  lu.assertEquals(Fk.skills[duoduan.name].trueName, "duoduan")
  local general = Fk.generals["huilu__mobile__yangyi"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "yangyi")
  lu.assertTrue(table.contains(general.other_skills, "huilu__duoduan"))
  lu.assertTrue(table.contains(general.other_skills, "huilu__gongsun"))
end)

return duoduan
