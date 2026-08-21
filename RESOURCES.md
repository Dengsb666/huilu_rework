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
- `pkg/skills/huilu__gongmou.lua` 派生自 FreeKill `mobile` 包的 `pkg/mobile_bingshi/skills/gongmou.lua`；仅增加目标手牌数不大于技能拥有者的限制。
- `pkg/skills/huilu__xinghun.lua`、`huilu__tiantao.lua`、`huilu__shenpeij.lua` 派生自 FreeKill `mobile` 包的神姜维技能。星魂限制为至多使用一张展示的【杀】并在结算后允许目标仅重排牌堆顶五张；天涛改为非锁定技且只弃置手牌；神霈的雷电伤害固定为1点。关联技能〖回天〗复用原版且未修改。
- `pkg/skills/huilu__fuyue.lua` 与 `huilu__wenlan.lua` 派生自 FreeKill `tenyear` 包 2026-08-12 时点的乐曹植实现；保留“赋”的双牌名、初始标记和不计手牌上限机制，文澜改为每使用两张“赋”后标记两张手牌或重置任意张“赋”的额外牌名，每回合每项限一次。
- `pkg/skills/huilu__luoying.lua` 派生自 FreeKill `yj` 包的原版落英实现，基线 commit `00995865cbc3bdc2ad9b6165ba7ee3f88cfcfd02`；触发范围改为技能拥有者的回合外所有因弃置进入弃牌堆的梅花牌，并增加至多等量标记“赋”的可选效果，不包含判定牌。
- `pkg/skills/huilu__guanxing.lua`、`huilu__zhizhe.lua` 与 `huilu__qingshi.lua` 参考 FreeKill `standard` 包的〖观星〗以及 `tenyear` 包武诸葛亮的〖尽瘁〗、〖智哲〗和〖情势〗实现；基线 commit 分别为 `37f8c1248d491f5fbc7a07f1bc53724191e44497` 与 `397a15ada7ecb317b550a8cf520b20dc0a602a8d`。本包按回武诸葛亮的新规则重新实现观星数量、智哲的花色映射与弃牌回收，以及情势触发观星。
- `pkg/skills/huilu__mou__jieyin.lua` 与 `huilu__mou__xiaoji.lua` 派生自 FreeKill `mougong` 包改版前的谋孙尚香实现，基线 commit `fbc1c4569c3e2cfdf237c3cf39b6ddd761bc7d0b`；保留旧版使命失败流程，删除已不再使用的“妆”牌流程，并为技能和标记加独立前缀。`huilu__mou__liangzhu.lua` 按本包的新规则重新实现回复体力后的摸牌、获得场上装备和交牌流程。
- `pkg/skills/huilu__qingya.lua` 与 `huilu__tielun.lua` 派生自 FreeKill `ol` 包的雅丹技能，基线 commit `e3090054066c8cdb5c53d3b4fb053aa707832ef1`；倾轧取消较短路径对方向选项的限制，铁轮增加全员距离为1时的本轮手牌上限奖励。
- `pkg/skills/huilu__bingjie.lua` 与 `huilu__zhengding.lua` 派生自 FreeKill `ol` 包的马日磾技能，基线 commit `e3090054066c8cdb5c53d3b4fb053aa707832ef1`；秉节保持原版，正订在原有增加体力上限后追加摸两张牌。
- `pkg/skills/huilu__nigu.lua` 与 `huilu__lulian.lua` 派生自 FreeKill `mobile` 包的势孙綝技能，基线 commit `23acd9fc2df5986d7bab0594b74ab5202a10abba` 所对应工作区的 `mobile_bingshi` 实现；逆固删除未交牌后的本回合增伤标记与触发，戮连的乘势改为可选且目标改为全场体力值最大者。
- `pkg/skills/huilu__mutao.lua` 与 `huilu__yimou.lua` 派生自 FreeKill `mobile` 包的手杀鲍信技能，基线 commit `f3cd83af005fa2219069a47c19baca95f1ee114b`；募讨仅将对最后一名角色造成的伤害由其手牌中【杀】的数量（至多2点）改为固定1点，毅谋保持原版。
- `pkg/skills/huilu__zhijie.lua` 与 `huilu__shushen.lua` 派生自 FreeKill `mobile` 包的手杀甘夫人技能，基线 commit `f3cd83af005fa2219069a47c19baca95f1ee114b`；智诫保持原版，淑慎将两个分支原本分别计算的“每回合各限一次”改为共用一次发动次数。
- 上述源包以 GPL-3.0-or-later 发布。

## 立绘

- `image/generals/huilu__lusu.jpg` 复用 FreeKill `ol` 包中的 `image/generals/ol_ex__lusu.jpg`。
- 原武将：界鲁肃。
- 画师署名：游漫美绘。
- 本包未修改图片内容，仅按新武将 ID 重命名。
- `image/generals/huilu__ol__liupi.jpg` 复用 FreeKill `ol` 包的 OL 刘辟原画（`image/generals/ol__liupi.jpg`）。
- `image/generals/huilu__mobile__yangyi.jpg` 复用 FreeKill `mobile` 包的手杀杨仪原画（`image/generals/mobile__yangyi.jpg`）。
- `image/generals/huilu__ol__caoying.jpg` 取自三国杀移动版官网曹婴页面的第 3 张官方立绘（蓝色冰雪背景、白色毛领），原图为 `https://www.sanguosha.cn/storage/uploads/images/skins/46102.jpg`，来源页为 `https://www.sanguosha.cn/pc/hero-detail-288.html`，下载日期为 2026-08-08；本包仅按 FreeKill 武将立绘比例裁切并缩放，官网页面未标注画师。
- `image/generals/huilu__m_shi__huanjie.jpg` 与 `image/generals/huilu__mobile__godjiangwei.jpg` 分别原样复用 FreeKill `mobile` 包的势桓阶、手杀神姜维原画。
- `image/generals/huilu__mu__caozhi.jpg` 原样复用 FreeKill `tenyear` 包的乐曹植原画。
- `image/generals/huilu__wm__zhugeliang.jpg` 原样复用 FreeKill `tenyear` 包的武诸葛亮原画（画师：梦回唐朝）。
- `image/generals/huilu__mou__sunshangxiang.jpg` 原样复用 FreeKill `mougong` 包的谋孙尚香原画（画师：暗金）。
- `image/generals/huilu__ol__yadan.jpg` 原样复用 FreeKill `ol` 包的雅丹原画（画师：匠人绘）。
- `image/generals/huilu__ol__mamidi.jpg` 原样复用 FreeKill `ol` 包的 OL 马日磾原画（画师：猎枭）。
- `image/generals/huilu__m_shi__sunchen.jpg` 原样复用 FreeKill `mobile` 包的势孙綝原画。
- `image/generals/huilu__mobile__baoxin.jpg` 原样复用 FreeKill `mobile` 包的手杀鲍信原画（画师：梦想君）。
- `image/generals/huilu__mobile__ganfuren.jpg` 原样复用 FreeKill `mobile` 包的手杀甘夫人原画（画师：错落宇宙）。

## 语音

- `audio/skill/huilu__haoshi1.mp3`、`huilu__haoshi2.mp3` 复用 FreeKill `shzl` 包的原版好施语音。
- `audio/skill/huilu__dimeng1.mp3`、`huilu__dimeng2.mp3` 复用 FreeKill `shzl` 包的原版缔盟语音。
- `audio/death/huilu__lusu.mp3` 复用 FreeKill `shzl` 包的原版鲁肃阵亡语音。
- 回OL刘辟的易城与阵亡语音复用 `ol` 包对应资源。
- 回手杀杨仪的度断、共损与阵亡语音复用 `mobile` 包对应资源。
- 回OL曹婴的凌人、伏间、奸雄、行殇与阵亡语音复用 `ol` 包对应资源。
- 回势桓阶和回手杀神姜维复用 `mobile` 包对应技能、阵亡及胜利语音；源包未提供势桓阶的独立阵亡语音文件。
- 回乐曹植的赋乐、文澜和阵亡语音复用 `tenyear` 包对应资源；落英语音复用 `yj` 包原版曹植的落英语音。
- 回武诸葛亮的观星、智哲、情势和阵亡语音复用 `tenyear` 包武诸葛亮的尽瘁、智哲、情势及阵亡资源；尽瘁语音按新技能 ID 重命名为观星语音。
- 回谋孙尚香的结姻、良助、枭姬及阵亡语音原样复用 FreeKill `mougong` 包对应资源。
- 回OL雅丹的倾轧及阵亡语音原样复用 FreeKill `ol` 包对应资源；原包未提供铁轮语音。
- 回OL马日磾的秉节、正订及阵亡语音原样复用 FreeKill `ol` 包对应资源。
- 回势孙綝的逆固、戮连及阵亡语音原样复用 FreeKill `mobile` 包对应资源。
- 回手杀鲍信的募讨、毅谋及阵亡语音原样复用 FreeKill `mobile` 包对应资源。
- 回手杀甘夫人的智诫、淑慎及阵亡语音原样复用 FreeKill `mobile` 包对应资源。
- 音频内容未修改，仅按新武将与技能 ID 重命名。

> 立绘和音频的署名及再分发条件以各源包和原素材权利人的声明为准；若用于公开发布，请再次核验素材授权。
