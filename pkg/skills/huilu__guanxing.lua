-- SPDX-License-Identifier: GPL-3.0-or-later

local guanxing = fk.CreateSkill{
  name = "huilu__guanxing",
}

Fk:loadTranslationTable{
  ["huilu__guanxing"] = "观星",
  [":huilu__guanxing"] = "准备阶段，你可以观看牌堆顶的X张牌（X为7减去你的体力值），然后将其中任意张牌以任意顺序置于牌堆顶，其余牌以任意顺序置于牌堆底。",

  ["$huilu__guanxing1"] = "情记三顾之恩，亮必继之以死。",
  ["$huilu__guanxing2"] = "身负六尺之孤，臣当鞠躬尽瘁。",
}

local function getGuanxingCount(player)
  return math.max(0, 7 - player.hp)
end

local function askForGuanxing(room, player)
  local n = getGuanxingCount(player)
  if n == 0 then return end
  room:askToGuanxing(player, {
    cards = room:getNCards(n),
    skill_name = guanxing.name,
  })
end

guanxing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guanxing.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    askForGuanxing(player.room, player)
  end,
})

guanxing:addTest(function(room, me)
  local general = Fk.generals["huilu__wm__zhugeliang"]
  lu.assertNotNil(general)
  lu.assertEquals(general.trueName, "zhugeliang")
  lu.assertEquals(general.hp, 3)
  lu.assertEquals(general.maxHp, 7)
  lu.assertTrue(table.contains(general.other_skills, guanxing.name))
  lu.assertTrue(table.contains(general.other_skills, "huilu__zhizhe"))
  lu.assertTrue(table.contains(general.other_skills, "huilu__qingshi"))

  lu.assertEquals(getGuanxingCount({ hp = 7 }), 0)
  lu.assertEquals(getGuanxingCount({ hp = 3 }), 4)
  lu.assertEquals(getGuanxingCount({ hp = 1 }), 6)
  lu.assertEquals(getGuanxingCount({ hp = 0 }), 7)
end)

return guanxing
