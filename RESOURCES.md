# 资源与派生代码说明

## 代码

- `pkg/skills/huilu__haoshi.lua` 派生自 FreeKill `shzl` 包的 `pkg/forest/skills/haoshi.lua`。
- `pkg/skills/huilu__dimeng.lua` 派生自 FreeKill `shzl` 包的 `pkg/forest/skills/dimeng.lua`。
- 基线：`shzl` commit `7f9daae027e5429378c904b940fcb457f84b9e4a`。
- 实质改动：为回鲁肃的缔盟 ActiveSkill 增加 `include_equip = true`，让客户端在选定目标前就展开装备区；其余规则逻辑保持原版。
- 上述源包以 GPL-3.0-or-later 发布。

## 立绘

- `image/generals/huilu__lusu.jpg` 复用 FreeKill `ol` 包中的 `image/generals/ol_ex__lusu.jpg`。
- 原武将：界鲁肃。
- 画师署名：游漫美绘。
- 本包未修改图片内容，仅按新武将 ID 重命名。

## 语音

- `audio/skill/huilu__haoshi1.mp3`、`huilu__haoshi2.mp3` 复用 FreeKill `shzl` 包的原版好施语音。
- `audio/skill/huilu__dimeng1.mp3`、`huilu__dimeng2.mp3` 复用 FreeKill `shzl` 包的原版缔盟语音。
- `audio/death/huilu__lusu.mp3` 复用 FreeKill `shzl` 包的原版鲁肃阵亡语音。
- 音频内容未修改，仅按新武将与技能 ID 重命名。

> 立绘和音频的署名及再分发条件以各源包和原素材权利人的声明为准；若用于公开发布，请再次核验素材授权。
