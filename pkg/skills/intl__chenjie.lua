-- SPDX-License-Identifier: GPL-3.0-or-later

local intl__chenjie = fk.CreateSkill{
  name = "intl__chenjie",
}

Fk:loadTranslationTable{
  ["intl__chenjie"] = "臣节",
  [":intl__chenjie"] = "当一名角色的判定牌生效前，你可以用一张与判定牌相同花色的牌代替之，然后你摸两张牌。",

  ["#intl__chenjie-invoke"] = "臣节：你可以打出一张%arg牌修改 %dest 的 %arg2 判定并摸两张牌",

  ["$intl__chenjie1"] = "臣心怀二心，不可事君也。",
  ["$intl__chenjie2"] = "竭力致身，以尽臣节。",
}

intl__chenjie:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(intl__chenjie.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = intl__chenjie.name,
      pattern = ".|.|"..data.card:getSuitString(),
      prompt = "#intl__chenjie-invoke::"..target.id..":"..data.card:getSuitString(true)..":"..data.reason,
      include_equip = true,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeJudge{
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skillName = intl__chenjie.name,
    }
    if not player.dead then
      player:drawCards(2, intl__chenjie.name)
    end
  end,
})

return intl__chenjie
