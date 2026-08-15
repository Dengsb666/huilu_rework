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

General:new(extension, "huilu__m_shi__huanjie", "wei", 4):addSkills {
  "huilu__gongmou",
  "zhengshuo",
}

local godjiangwei = General:new(extension, "huilu__mobile__godjiangwei", "god", 3, 3)
godjiangwei:addSkills {
  "huilu__xinghun",
  "huilu__tiantao",
  "huilu__shenpeij",
}
godjiangwei:addRelatedSkill("huitian")

General:new(extension, "huilu__mu__caozhi", "wei", 3):addSkills {
  "huilu__fuyue",
  "huilu__luoying",
  "huilu__wenlan",
}

General:new(extension, "huilu__wm__zhugeliang", "shu", 3, 7):addSkills {
  "huilu__guanxing",
  "huilu__zhizhe",
  "huilu__qingshi",
}

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

  ["huilu__m_shi__huanjie"] = "回势桓阶",
  ["#huilu__m_shi__huanjie"] = "才周托命",
  ["illustrator:huilu__m_shi__huanjie"] = "凝聚永恒",

  ["$qice_huilu__m_shi__huanjie1"] = "无有奇策，何以解之？",
  ["$qice_huilu__m_shi__huanjie2"] = "为今之计，唯效图纬故事。",
  ["!huilu__m_shi__huanjie"] = "殿下身承天命，无所与让也。",
  ["~huilu__m_shi__huanjie"] = "陛下厚遇，臣唯结草相报。",

  ["huilu__mobile__godjiangwei"] = "回手杀神姜维",
  ["#huilu__mobile__godjiangwei"] = "万民承霖",
  ["illustrator:huilu__mobile__godjiangwei"] = "云涯",

  ["~huilu__mobile__godjiangwei"] = "身陨何妨作新斗？与日同天卫九州。",
  ["!huilu__mobile__godjiangwei"] = "心炎生熙暖尘世，天水化霖泽人间。",

  ["huilu__mu__caozhi"] = "回乐曹植",
  ["#huilu__mu__caozhi"] = "漱律重章",
  ["~huilu__mu__caozhi"] = "志较天高，命犹纸薄。",

  ["huilu__wm__zhugeliang"] = "回武诸葛亮",
  ["#huilu__wm__zhugeliang"] = "忠武良弼",
  ["illustrator:huilu__wm__zhugeliang"] = "梦回唐朝",
  ["cv:huilu__wm__zhugeliang"] = "马洋",

  ["~huilu__wm__zhugeliang"] = "天下事，了犹未了，终以不了了之……",
}

return extension
