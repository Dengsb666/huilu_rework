-- SPDX-License-Identifier: GPL-3.0-or-later

local jieyin = fk.CreateSkill({
  name = "huilu__mou__jieyin",
  tags = { Skill.Quest },
})

Fk:loadTranslationTable{
  ["huilu__mou__jieyin"] = "结姻",
  [":huilu__mou__jieyin"] = "使命技，游戏开始时，你选择一名其他角色，令其获得“助”。你的出牌阶段开始时，有“助”的角色选择一项："..
  "1.若其有手牌，其交给你两张手牌（不足两张则全部交给你），然后其获得1点护甲；"..
  "2.令你移动或移除其“助”标记（若其并非第一次获得“助”，则只能移除）。<br>"..
  "⬤　失败：当“助”标记被移除或有“助”的角色死亡后，你回复1点体力，将势力改为吴，减1点体力上限，然后此技能失效。",

  ["#huilu__mou__jieyin-choose"] = "结姻：选择一名其他角色，令其获得“助”",
  ["#huilu__mou__jieyin-price"] = "结姻：交给 %src %arg张手牌，或点取消令其移动或移除你的“助”",
  ["#huilu__mou__jieyin-transfer"] = "结姻：将 %dest 的“助”移给一名角色，或点取消将其移除",
  ["@@huilu__mou__jieyin"] = "助",

  ["$huilu__mou__jieyin1"] = "君若不负吾心，妾自随君千里。",
  ["$huilu__mou__jieyin2"] = "夫妻之情既断，何必再问归期！",
  ["$huilu__mou__jieyin3"] = "今日良姻既结，你我永为夫妇。",
  ["$huilu__mou__jieyin4"] = "此生得遇夫君，实乃妾身幸事。",
}

local function canUse(player)
  return player:hasSkill(jieyin.name) and not player:getQuestSkillState(jieyin.name)
end

local function clearAid(room, player)
  local targetId = player:getMark("huilu__mou__jieyin_target")
  room:setPlayerMark(player, "huilu__mou__jieyin_target", 0)
  if targetId == 0 then return end

  local to = room:getPlayerById(targetId)
  if to and to:getMark("@@huilu__mou__jieyin") > 0 and
      table.every(room.alive_players, function(p)
        return p:getMark("huilu__mou__jieyin_target") ~= targetId
      end) then
    room:setPlayerMark(to, "@@huilu__mou__jieyin", 0)
  end
end

local function failQuest(self, event, target, player, data)
  local room = player.room
  player:broadcastSkillInvoke(jieyin.name, 2)
  room:updateQuestSkillState(player, jieyin.name, true)
  clearAid(room, player)

  if player:isWounded() then
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = jieyin.name,
    }
  end
  if player:isAlive() then
    room:changeKingdom(player, "wu", true)
    room:changeMaxHp(player, -1)
    room:invalidateSkill(player, jieyin.name)
  end
end

jieyin:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return canUse(player) and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, jieyin.name, "support")
    player:broadcastSkillInvoke(jieyin.name, 1)
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      skill_name = jieyin.name,
      prompt = "#huilu__mou__jieyin-choose",
      cancelable = false,
    })
    if #tos > 0 then
      room:setPlayerMark(tos[1], "@@huilu__mou__jieyin", 1)
      room:setPlayerMark(player, "huilu__mou__jieyin_target", tos[1].id)
    end
  end,
})

jieyin:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or player.phase ~= Player.Play or not canUse(player) then return false end
    local targetId = player:getMark("huilu__mou__jieyin_target")
    return targetId ~= 0 and not player.room:getPlayerById(targetId).dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(jieyin.name, 1)
    local targetId = player:getMark("huilu__mou__jieyin_target")
    local to = room:getPlayerById(targetId)

    local cards = {}
    if not to:isKongcheng() then
      local n = math.min(2, to:getHandcardNum())
      cards = room:askToCards(to, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = jieyin.name,
        cancelable = true,
        pattern = ".",
        prompt = "#huilu__mou__jieyin-price:" .. player.id .. "::" .. n,
      })
    end

    if #cards > 0 then
      room:moveCards{
        ids = cards,
        from = to.id,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        proposer = to.id,
        skillName = jieyin.name,
        moveVisible = false,
      }
      if to:isAlive() then room:changeShield(to, 1) end
      return
    end

    local received = "huilu__mou__jieyin_received_" .. to.id
    if player:getMark(received) == 0 then
      room:setPlayerMark(player, received, 1)
      local candidates = table.filter(room:getOtherPlayers(player, false), function(p)
        return p ~= to
      end)
      if #candidates > 0 then
        local tos = room:askToChoosePlayers(player, {
          targets = candidates,
          min_num = 1,
          max_num = 1,
          prompt = "#huilu__mou__jieyin-transfer::" .. to.id,
          skill_name = jieyin.name,
          cancelable = true,
        })
        if #tos > 0 then
          room:setPlayerMark(player, "huilu__mou__jieyin_target", tos[1].id)
          if table.every(room.alive_players, function(p)
            return p:getMark("huilu__mou__jieyin_target") ~= to.id
          end) then
            room:setPlayerMark(to, "@@huilu__mou__jieyin", 0)
          end
          room:setPlayerMark(tos[1], "@@huilu__mou__jieyin", 1)
          return
        end
      end
    end

    failQuest(self, event, target, player, data)
  end,
})

jieyin:addEffect(fk.Deathed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return canUse(player) and player:getMark("huilu__mou__jieyin_target") == target.id
  end,
  on_cost = Util.TrueFunc,
  on_use = failQuest,
})

jieyin:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player:getMark("huilu__mou__jieyin_target") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    clearAid(player.room, player)
  end,
})

jieyin:addTest(function(room, me)
  local general = Fk.generals["huilu__mou__sunshangxiang"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "sunshangxiang")
  lu.assertEquals(general.kingdom, "shu")
  lu.assertEquals(general.hp, 4)
  lu.assertEquals(general.maxHp, 4)
  lu.assertEquals(general.gender, General.Female)
  lu.assertTrue(table.contains(general.other_skills, jieyin.name))
  lu.assertTrue(table.contains(general.other_skills, "huilu__mou__liangzhu"))
  lu.assertTrue(table.contains(general.other_skills, "huilu__mou__xiaoji"))

  local comp2 = room.players[2]
  local cards = { room:printCard("slash").id, room:printCard("jink").id }
  FkTest.setNextReplies(me, {
    { card = { skill = "choose_players_skill", subcards = {} }, targets = { comp2.id } },
    "",
  })
  FkTest.setNextReplies(comp2, {
    { card = { skill = "choose_cards_skill", subcards = cards }, targets = {} },
  })
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, jieyin.name)
    room.logic:trigger(fk.GameStart, me, {})
    room:obtainCard(comp2, cards)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
  lu.assertEquals(comp2.shield, 1)
  lu.assertEquals(comp2:getMark("@@huilu__mou__jieyin"), 1)
end)

jieyin:addTest(function(room, me)
  local comp2, comp3 = room.players[2], room.players[3]
  FkTest.setNextReplies(me, {
    { card = { skill = "choose_players_skill", subcards = {} }, targets = { comp2.id } },
    { card = { skill = "choose_players_skill", subcards = {} }, targets = { comp3.id } },
    "",
    { card = { skill = "choose_players_skill", subcards = {} }, targets = { comp2.id } },
    "",
    "",
  })
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, jieyin.name)
    room:loseHp(me, 1)
    room.logic:trigger(fk.GameStart, me, {})
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(me.kingdom, "wu")
  lu.assertEquals(me.maxHp, 3)
  lu.assertEquals(me.hp, 3)
  lu.assertEquals(me:getQuestSkillState(jieyin.name), "failed")
  lu.assertEquals(comp2:getMark("@@huilu__mou__jieyin"), 0)
end)

return jieyin
