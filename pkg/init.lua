-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("huilu_rework")
extension.extensionName = "huilu_rework"

extension:loadSkillSkelsByPath("./packages/huilu_rework/pkg/skills")

General:new(extension, "huilu__lusu", "wu", 3):addSkills {
  "huilu__haoshi",
  "huilu__dimeng",
}

Fk:loadTranslationTable{
  ["huilu__lusu"] = "回鲁肃",
  ["#huilu__lusu"] = "独断的外交家",
  ["illustrator:huilu__lusu"] = "游漫美绘",

  ["~huilu__lusu"] = "此联盟已破，吴蜀休矣……",
}

return extension
