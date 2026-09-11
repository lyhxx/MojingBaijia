# 墨境百家（项目文档）

水墨风幸存者类单机游戏：扮演书生，首卷在墨家书院庭院里走位，
用四方印自动退敌，10:00 无字判官登场，击杀即通关。
后续按"百家"加地图（儒/道/法……），一卷一书院。纯自嗨版本，无联网、无内购。

- 引擎：Godot 4.3（Forward+，2D，全 GDScript）
- 平台：Windows 桌面 1920x1080，键鼠 + 手柄左摇杆可走
- 入口：`scenes/menu.tscn`（标题菜单）→ `scenes/main.tscn`（战斗）
- 单局：约 8–12 分钟

## 一局流程

```
菜单落笔开始 → 墨兽潮（0:00）→ 墨鸦群冲（1:30）→ 石傀掉宝箱（~75秒一只）
→ 10:00 判官登场（送一个宝箱）→ 击杀判官 = 大胜 / 自己死 = 墨尽
```

## 操作

| 按键 | 作用 |
|---|---|
| WASD / 方向键 | 移动（全自动攻击，不用瞄准）|
| 1 / 2 / 3 或鼠标 | 升级三选一、宝箱三选一 |
| Q | 重写：换一批升级选项（每局 2 次）|
| X | 禁咒：清屏小怪、精英扣 35%、Boss 扣 15%（每局 1 次）|
| Esc | 暂停 / 继续（含重开、回菜单）|
| R | 结算后重开 |
| F1 | 无敌调试开关 |
| Enter | 菜单直接开始 |

## 四印四心法

- 青锋印：追踪飞剑；镇岳印：天降绿印 AOE；逐墨印：环绕墨剑；摄魂印：紫链跳跃群伤
- 养浩（血）、墨守（甲）、观心（暴击+拾取）、通玄（移速），藏在升级选项里，右下角计数

## 目录结构

```
project.godot          Godot 工程文件（主场景=menu）
export_presets.cfg     Win64 导出预设
scenes/                menu.tscn 菜单 / main.tscn 战斗（根节点+脚本，内容全代码生成）
scripts/               全部逻辑（21 个 .gd，见开发文档）
data/weapons.json      武器名/数值/通关条件速查
art/                   预留（当前美术全是代码绘制，无外部贴图）
audio/                 10 个程序化 WAV（剑/印/拾取/升级/宝箱/链/吼/核弹/BGM）
tools/gen_audio.py     音频再生脚本 / check_static.py 静态检查脚本
docs/DEV.md            开发文档（架构+加新内容 SOP+坑）
```

## 换电脑继续开发（迁移步骤）

1. 把整个 `test3` 文件夹拷走（含 `.git`、`audio/`、`tools/`），另一台电脑解压到任意盘
2. 装 Godot：官网下 **4.3 Stable 免安装版**，解压记住路径（不用和原来一样）
3. 打开 Godot → Import → 选新路径下的 `project.godot` → Import & Edit
4. 首次打开等右下角导入完（主要是 `audio/*.wav` 生成 `.import`），点 ▶ 或 F5 运行
5. 要打包 exe：Project → Export → 第一次按下提示装官方 Export Templates →
   选预设 Windows Desktop → Export 到 `D:\build\mojing_baijia.exe`（路径可改）

## 存档位置

- 本地：`%APPDATA%/Godot/app_userdata/MojingBaijia/mojing_save.cfg`（只存最佳时长/击杀/等级）
- 删档：删掉这个文件重进就是新卷；换电脑不会同步，想带走就拷它

## 仓库说明

- `audio/*.wav` 是生成物，已直接入库，换电脑不用重跑；想改音效才跑
  `python tools/gen_audio.py`
- `tools/` 下的 `.py` 已在 `export_presets.cfg` 里排除，不会打进 exe
