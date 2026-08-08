# 资源与派生代码说明

## 代码

- `pkg/skills/huilu__haoshi.lua` 派生自 FreeKill `shzl` 包的 `pkg/forest/skills/haoshi.lua`。
- `pkg/skills/huilu__dimeng.lua` 派生自 FreeKill `shzl` 包的 `pkg/forest/skills/dimeng.lua`。
- 基线：`shzl` commit `7f9daae027e5429378c904b940fcb457f84b9e4a`。
- 实质改动：为回鲁肃的缔盟 ActiveSkill 增加 `include_equip = true`，让客户端在选定目标前就展开装备区；其余规则逻辑保持原版。
- `pkg/skills/huilu__yichengl.lua` 派生自 FreeKill `ol` 包的 `pkg/xinghe/skills/yicheng.lua`，基线 commit `e3090054066c8cdb5c53d3b4fb053aa707832ef1`。修复第二段可选整体交换的取消路径，并明确要求首段实际等量交换且展示牌点数和因此增加。
- `pkg/skills/huilu__gongsun.lua` 派生自 FreeKill `mobile` 包的 `pkg/mobile_sp/skills/gongsun.lua`，基线 commit `23acd9fc2df5986d7bab0594b74ab5202a10abba`。
- `pkg/skills/huilu__duoduan.lua` 派生自 FreeKill `overseas` 包的 `pkg/overseas_sp/skills/os_duoduan.lua`，基线 commit `edc5e1d8510c1a1bb04fd4892dfdbbff913d2ff0`；用于补齐手杀杨仪在未启用海外包时缺失的度断。
- `pkg/skills/huilu__lingren.lua` 与 `pkg/skills/huilu__fujian.lua` 派生自 FreeKill `ol` 包的曹婴技能。凌人删除猜对两项后令当前牌不计次数的代码，其余收益保持原版。
- 上述源包以 GPL-3.0-or-later 发布。

## 立绘

- `image/generals/huilu__lusu.jpg` 复用 FreeKill `ol` 包中的 `image/generals/ol_ex__lusu.jpg`。
- 原武将：界鲁肃。
- 画师署名：游漫美绘。
- 本包未修改图片内容，仅按新武将 ID 重命名。
- `image/generals/huilu__ol__liupi.jpg` 复用 `tenyear` 包的刘辟立绘，画师署名君桓文化。
- `image/generals/huilu__mobile__yangyi.jpg` 复用 `ol` 包的杨仪立绘，画师署名游漫美绘。
- `image/generals/huilu__ol__caoying.jpg` 复用 `mobile` 包的曹婴立绘，画师署名 DH。

## 语音

- `audio/skill/huilu__haoshi1.mp3`、`huilu__haoshi2.mp3` 复用 FreeKill `shzl` 包的原版好施语音。
- `audio/skill/huilu__dimeng1.mp3`、`huilu__dimeng2.mp3` 复用 FreeKill `shzl` 包的原版缔盟语音。
- `audio/death/huilu__lusu.mp3` 复用 FreeKill `shzl` 包的原版鲁肃阵亡语音。
- 回OL刘辟的易城与阵亡语音复用 `ol` 包对应资源。
- 回手杀杨仪的度断、共损与阵亡语音复用 `mobile` 包对应资源。
- 回OL曹婴的凌人、伏间、奸雄、行殇与阵亡语音复用 `ol` 包对应资源。
- 音频内容未修改，仅按新武将与技能 ID 重命名。

> 立绘和音频的署名及再分发条件以各源包和原素材权利人的声明为准；若用于公开发布，请再次核验素材授权。
