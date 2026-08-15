-- SPDX-License-Identifier: GPL-3.0-or-later

local liangzhu = fk.CreateSkill({
  name = "huilu__mou__liangzhu",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = { "shu" },
})

Fk:loadTranslationTable{
  ["huilu__mou__liangzhu"] = "良助",
  [":huilu__mou__liangzhu"] = "蜀势力技，当一名角色于其出牌阶段内回复体力后，你可以选择一项：1.摸一张牌；2.令其摸两张牌。若其有“助”，你可以获得场上的一张装备牌，然后你可以交给其一张牌。",

  ["huilu__mou__liangzhu_draw_self"] = "你摸一张牌",
  ["huilu__mou__liangzhu_draw_target"] = "令其摸两张牌",
  ["#huilu__mou__liangzhu-choice"] = "良助：选择你或 %dest 摸牌",
  ["#huilu__mou__liangzhu-equip"] = "良助：你可以获得场上的一张装备牌",
  ["#huilu__mou__liangzhu-give"] = "良助：你可以交给 %dest 一张牌",

  ["$huilu__mou__liangzhu1"] = "助君得胜战，跃马提缨枪！",
  ["$huilu__mou__liangzhu2"] = "平贼成君业，何惜上沙场！",
}

local function applyDrawChoice(player, target, choice)
  if choice == "huilu__mou__liangzhu_draw_self" then
    player:drawCards(1, liangzhu.name)
  else
    target:drawCards(2, liangzhu.name)
  end
end

liangzhu:addEffect(fk.HpRecover, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(liangzhu.name) and target:isAlive() and target.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = liangzhu.name,
      prompt = "#huilu__mou__liangzhu-choice::" .. target.id,
    }) then
      event:setCostData(self, { tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = { "huilu__mou__liangzhu_draw_self", "huilu__mou__liangzhu_draw_target" },
      skill_name = liangzhu.name,
      prompt = "#huilu__mou__liangzhu-choice::" .. target.id,
    })
    applyDrawChoice(player, target, choice)

    if player.dead or target.dead or target:getMark("@@huilu__mou__jieyin") == 0 then return end

    local equipOwners = table.filter(room.alive_players, function(p)
      return #p:getCardIds("e") > 0
    end)
    if #equipOwners > 0 then
      local tos = room:askToChoosePlayers(player, {
        targets = equipOwners,
        min_num = 1,
        max_num = 1,
        prompt = "#huilu__mou__liangzhu-equip",
        skill_name = liangzhu.name,
        cancelable = true,
      })
      if #tos > 0 then
        local id = room:askToChooseCard(player, {
          target = tos[1],
          flag = "e",
          skill_name = liangzhu.name,
        })
        room:obtainCard(player, id, true, fk.ReasonPrey, player, liangzhu.name)
      end
    end

    if player.dead or target.dead or player:isNude() then return end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = liangzhu.name,
      cancelable = true,
      pattern = ".",
      prompt = "#huilu__mou__liangzhu-give::" .. target.id,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, liangzhu.name, nil, false, player)
    end
  end,
})

liangzhu:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.setNextReplies(me, {
    "1", "huilu__mou__liangzhu_draw_self",
  })
  FkTest.runInRoom(function()
    room:changeKingdom(me, "shu")
    room:handleAddLoseSkills(me, liangzhu.name)
    comp2.phase = Player.Play
    room:loseHp(comp2, 1)
    room:recover{ who = comp2, num = 1, recoverBy = comp2 }
  end)
  lu.assertEquals(me:getHandcardNum(), 1)
end)

liangzhu:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function()
    applyDrawChoice(me, comp2, "huilu__mou__liangzhu_draw_target")
  end)
  lu.assertEquals(comp2:getHandcardNum(), 2)
end)

liangzhu:addTest(function(room, me)
  local comp2, comp3 = room.players[2], room.players[3]
  local equip = room:printCard("spear")
  FkTest.setNextReplies(me, {
    "1",
    "huilu__mou__liangzhu_draw_self",
    { card = { skill = "choose_players_skill", subcards = {} }, targets = { comp3.id } },
    equip.id,
    { card = { skill = "choose_cards_skill", subcards = { equip.id } }, targets = {} },
  })
  FkTest.runInRoom(function()
    room:changeKingdom(me, "shu")
    room:handleAddLoseSkills(me, liangzhu.name)
    room:setPlayerMark(comp2, "@@huilu__mou__jieyin", 1)
    room:useCard{ from = comp3, tos = { comp3 }, card = equip }
    comp2.phase = Player.Play
    room:loseHp(comp2, 1)
    room:recover{ who = comp2, num = 1, recoverBy = comp2 }
  end)
  lu.assertEquals(#comp3:getCardIds("e"), 0)
  lu.assertTrue(table.contains(comp2:getCardIds("h"), equip.id))
end)

return liangzhu
