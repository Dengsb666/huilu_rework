-- SPDX-License-Identifier: GPL-3.0-or-later

local shenpei = fk.CreateSkill{
  name = "huilu__shenpeij",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["huilu__shenpeij"] = "神霈",
  [":huilu__shenpeij"] = "限定技，你进入濒死时，可回复X点体力（X为你本局游戏进入过濒死的次数），对一名角色造成1点雷电伤害并获得〖<a href=':huitian'>回天</a>〗。",

  ["#huilu__shenpeij-invoke"] = "神霈：可回复%arg点体力、造成1点雷电伤害并获得“回天”",
  ["#huilu__shenpeij-choose"] = "神霈：选择一名其他角色，对其造成1点雷电伤害",

  ["$huilu__shenpeij1"] = "雄山峻壑终踏过，须信寒过总是春。",
  ["$huilu__shenpeij2"] = "世有云霓之望，维必借天馈之！",
}

local function dyingCount(room, player)
  local x = 0
  room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
    if e.data.who == player then
      x = x + 1
    end
  end, Player.HistoryGame)
  return x
end

local function thunderDamageAmount()
  return 1
end

shenpei:addEffect(fk.EnterDying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.hp < 1 and player:hasSkill(shenpei.name) and
      player:usedSkillTimes(shenpei.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shenpei.name,
      prompt = "#huilu__shenpeij-invoke:::" .. dyingCount(player.room, player),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = dyingCount(room, player)
    room:recover {
      who = player,
      num = x,
      recoverBy = player,
      skillName = shenpei.name,
    }
    if player.dead then return end
    room:handleAddLoseSkills(player, "huitian")
    if player.dead then return end
    local others = room:getOtherPlayers(player, false)
    if #others == 0 then return end
    room:damage {
      from = player,
      to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = others,
        skill_name = shenpei.name,
        prompt = "#huilu__shenpeij-choose",
        cancelable = false,
      })[1],
      damage = thunderDamageAmount(),
      damageType = fk.ThunderDamage,
      skillName = shenpei.name,
    }
  end,
})

shenpei:addTest(function(room, me)
  local skill = Fk.skills[shenpei.name]
  lu.assertNotNil(skill)
  lu.assertTrue(skill:hasTag(Skill.Limited))
  lu.assertEquals(thunderDamageAmount(), 1)

  local general = Fk.generals["huilu__mobile__godjiangwei"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "godjiangwei")
  lu.assertEquals(general.hp, 3)
  lu.assertEquals(general.maxHp, 3)
end)

return shenpei
