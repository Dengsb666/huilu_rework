# 回炉重造扩展包

这是一个用于收录“保持原版规则、修复实际实现问题”的 FreeKill 自定义武将包。

## 当前武将

- 回鲁肃（`huilu__lusu`）：3 体力，吴势力。
- 好施（`huilu__haoshi`）：与神话再临·林的鲁肃实现一致。
- 缔盟（`huilu__dimeng`）：与神话再临·林的鲁肃实现一致，并修复选择两名目标之前装备区不展开、导致无法用装备牌支付弃牌差值的问题。

## 兼容性约定

- 包 ID：`huilu_rework`
- “回”武将使用 `huilu__<原武将ID>`；例如“回鲁肃”为 `huilu__lusu`。
- 未来重做“势鲁肃”时使用 `huilu__shi_lusu`，界面名称为“回势鲁肃”。
- 技能使用 `huilu__` 前缀，避免覆盖其他扩展包中的同名实现。

## 安装

将仓库克隆到 FreeKill 的 `packages/huilu_rework`，随后在包管理器中启用“回炉重造扩展包”。联机服务器也必须安装并启用同一 Git commit。

## 授权与资源

代码以 GPL-3.0-or-later 发布。复制及修改的代码、立绘与语音来源和改动说明见 [RESOURCES.md](RESOURCES.md)。
