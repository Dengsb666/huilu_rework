-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("huilu_rework")
extension.extensionName = "huilu_rework"

extension:loadSkillSkelsByPath("./packages/huilu_rework/pkg/skills")

General:new(extension, "huilu__lusu", "wu", 3):addSkills {
  "huilu__haoshi",
  "huilu__dimeng",
}

General:new(extension, "huilu__ol__liupi", "qun", 4):addSkills {
  "huilu__yichengl",
}

General:new(extension, "huilu__mobile__yangyi", "shu", 3):addSkills {
  "huilu__duoduan",
  "huilu__gongsun",
}

local caoying = General:new(extension, "huilu__ol__caoying", "wei", 4, 4, General.Female)
caoying:addSkills {
  "huilu__lingren",
  "huilu__fujian",
}
caoying:addRelatedSkills { "ex__jianxiong", "xingshang" }

Fk:loadTranslationTable{
  ["huilu__lusu"] = "回鲁肃",
  ["#huilu__lusu"] = "独断的外交家",
  ["illustrator:huilu__lusu"] = "游漫美绘",

  ["~huilu__lusu"] = "此联盟已破，吴蜀休矣……",

  ["huilu__ol__liupi"] = "回OL刘辟",
  ["#huilu__ol__liupi"] = "易城报君",
  ["illustrator:huilu__ol__liupi"] = "君桓文化",
  ["designer:huilu__ol__liupi"] = "那个背影",

  ["~huilu__ol__liupi"] = "玄德公速行，曹军某自当之！",

  ["huilu__mobile__yangyi"] = "回手杀杨仪",
  ["#huilu__mobile__yangyi"] = "孤鹬",
  ["illustrator:huilu__mobile__yangyi"] = "游漫美绘",

  ["~huilu__mobile__yangyi"] = "如今追悔，亦不可复及矣……",

  ["huilu__ol__caoying"] = "回OL曹婴",
  ["#huilu__ol__caoying"] = "龙城凤鸣",
  ["cv:huilu__ol__caoying"] = "水原",
  ["illustrator:huilu__ol__caoying"] = "DH",
  ["designer:huilu__ol__caoying"] = "韩旭",

  ["$ex__jianxiong_huilu__ol__caoying"] = "且收此弩箭，不日奉还。",
  ["$xingshang_huilu__ol__caoying"] = "此刀枪军械，尽归我有。",
  ["~huilu__ol__caoying"] = "曹魏天下存，魂归故土安……",
}

return extension
