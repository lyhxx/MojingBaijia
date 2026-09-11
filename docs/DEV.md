# 墨境百家（开发文档）

给换电脑后的自己看的：架构、数值位置、加新内容的标准步骤、已知的坑。

## 1. 架构一句话

**无物理引擎、无场景拼装**：`main.tscn` 只有一个根 Node2D，一切单位都是
`Node2D` 子类用代码 `new()` 出来、走 `position += dir*speed*delta`、
碰撞全是**圆心距离判定**。敌人 80 上限，O(n²) 够用且省心。

```
Main (Node2D, main.gd)
├── Player (MojingPlayer) + OrbitInk xN（孩子，跟随转）
├── enemies[]: MojingEnemy / MojingGolem / InkCrow / InkJudge
├── swords/seals/soulfx/ebullets/gems/chests（平级，用完 queue_free）
├── Camera2D + GroundInk（跟镜头吸附画砖缝）
├── CanvasLayer(-10) > PaperBG（全屏宣纸+远山+竹子，不跟镜头）
└── HUD (CanvasLayer, hud.gd)
Autoload: GameState（局内数值）→ AudioMan（8 通道 SFX + BGM 循环）
```

暂停靠 `get_tree().paused`，HUD/菜单按钮 `PROCESS_MODE_ALWAYS`，
战斗单位默认 INHERIT，升级/宝箱/暂停/结算四种情况统一暂停树。

## 2. 文件地图（改代码先看这张表）

| 文件 | 管什么 | 关键函数/变量 |
|---|---|---|
| `scripts/game_state.gd` | 等级经验、升级池、重写/禁咒次数、最佳存档 | `add_xp/roll_choices/roll_chest_choices/save_best/load_best`，`rerolls=2 nukes=1` |
| `scripts/main.gd` | 刷怪、武器发射、AOE 结算、Boss 技能、核弹、暂停重开回菜单 | `fire_swords/fire_seals/fire_soul/deal_aoe/spawn_enemy/spawn_crow/spawn_golem/spawn_boss/cast_nuke` |
| `scripts/player.gd` | 移动、四武器计时器、承伤、吃升级 | `sword/seal/orbit/soul` 四组数值，`roll_damage` 暴击，`_ensure_orbits` |
| `scripts/hud.gd` | 左上等级/顶部计时/右上重写禁咒/Boss 条/升级面板/暂停/结算 | `show_choices/show_boss/show_end/show_pause/refresh_items/refresh_passives` |
| `scripts/menu.gd` | 主菜单最佳战绩显示 | `_on_start/_on_quit` |
| `scripts/enemy/golem/crow/boss.gd` | 四种敌人；鸦有 `crow_move`，判官只有数值+ drawbacks，技能在 main 里 | `setup/take_damage`；`boss.skill_burst_t/skill_summon_t` |
| `scripts/sword/seal/soul/orbit/ebullet.gd` | 五种投射物/范围器，各自 `_process` 自走+索敌+命中 | seal 落定调 `main.deal_aoe`；soul 纯表现，伤害在 `fire_soul` 里即时结算 |
| `scripts/gem/chest.gd` | 蓝经验磁吸；金箱走近开 | `open_chest` 回 15% 血 + 宝箱三选一 |
| `scripts/paper_bg/ground_ink/splash/dmgnum.gd` | 纸底、砖缝、墨 splash、飘字 | `spawn_splash/spawn_dmgnum/add_shake` 在 main |
| `scripts/audio_man.gd` | 读 `audio/*.wav`，`play(name)` 轮询 8 通道 | `start_bgm` 菜单和开局各调一次 |
| `data/weapons.json` | 速查表（真数值在各 gd 默认值里，json 只做记录） | — |

## 3. 数值位置（调平衡只改这几处）

- 玩家：`player.gd` 头部（血 120、速 300、青锋 12/0.9s、镇岳 26/3.2s、环绕 10、链 18/2.6s/跳 3、暴击 5%/1.6 倍）
- 升级 id 全表：`sword_dmg/sword_cd/sword_num/seal_dmg/seal_cd/seal_num/
  orbit_dmg/orbit_num/soul_dmg/soul_jumps/soul_cd/crit/move_spd/max_hp/
  pickup/armor/heal`，分别在 `game_state.roll_choices` 入池、
  `player.apply_choice` 生效，上限在 `roll_choices` 过滤（双/分/环 2 次，链 3 次）
- 刷怪：`main._process`（小怪间隔 1.2→0.28s、80 上限；鸦 90s 后 9→4s；
  石傀 50s 后 75s 一只；判官 `BOSS_TIME=600`）
- 怪数值：`spawn_enemy/spawn_crow/spawn_golem/spawn_boss` 四个函数内联公式
- 判官：9000 血/55 速/8 发环形弹 3.6s/招怪 9s，30% 血狂暴（12 发/2.6s/7s）

## 4. 加新内容的 SOP

**新武器（例：第 5 印）**：① `player.gd` 加 `w5_dmg/w5_cd`+计时器；
② `main.gd` 加 `fire_w5`；③ 新建 `scripts/w5.gd`（抄 `seal.gd` 结构）；
④ `game_state.roll_choices` 入池 + `player.apply_choice` 生效；
⑤ `hud.refresh_passives` 的左下字符串加一项。不要改 `main.tscn`。

**新敌人**：① 新建脚本 `extends MojingEnemy`（参考 `crow.gd`，特殊移动写成
`xxx_move(delta, player_pos)`）；② `main` 加 `spawn_xxx`；
③ 在 `_process` 移动分支里 `has_method` 先行（鸦已有范例）；
④ 在 `on_enemy_died` 决定掉落（参考石傀掉箱）。

**新拾取**：抄 `chest.gd`（`_process` 测距触发 + `_draw` 画外形），
效果函数写进 `main`（参考 `open_chest`），记得暂停树再弹面板。

## 5. 美术与音频怎么续

- 美术现在全是 `_draw()` 代码绘制（色块+线），`art/` 是空的占位。
  换真美术时：把各单位 `_draw` 换成 `Sprite2D`+贴图即可，逻辑不动；
  `PaperBG`（屏空间）和 `GroundInk`（世界空间）是两层背景，别合在一起。
- 音频是生成的：改音效直接改 `tools/gen_audio.py` 跑
  `python tools/gen_audio.py`，10 个 wav 会重写，进 Godot 自动重导入；
  新增音效要在 `audio_man.gd` 的名字表里加一行，并在逻辑处 `AudioMan.play`。

## 6. 已知的坑（别再踩）

1. `class_name` 全局类靠编辑器扫描缓存：新电脑首次 Import 后如果报
   `Identifier MojingX not found`，关掉重开一次就好。
2. `menu.tscn` 的 `load_steps` 手改过（=2），再用编辑器存一遍会自动修正，不用管。
3. 不用物理层：所有单位都没 CollisionShape，凑近判定全看
   `distance_squared_to`，加新单位别去加碰撞体。
4. `AudioStreamWAV.loop_mode` 只在 `is AudioStreamWAV` 时设置（已修过一次），
   加新循环音沿用这个写法。
5. 飘字用 `ThemeDB.fallback_font`，引擎低于 4.2 会没有——本工程锁定 4.3，别降版本。
6. `tools/*.py` 不进包（`export_presets.cfg` 已排除），别把游戏逻辑放 tools 里。

## 7. 性能预算（自用笔记本线）

小怪 80、鸦不计入额外上限、投射物随缘（飞剑 1.6s 生命+穿透 1）、
splash/飘字即生即灭。低端机先关 `PaperBG` 竹子数量和 splash 半径，
不动判定。80 同屏 O(n²) 约 6400 次距离检查，60fps 无压力。

## 8. 待办（想继续磨按这个顺序）

1. 真篇进化：满级武器+对应心法→质变（代码位：`apply_choice` 计数已埋好）
2. 减速白区怪（纸傀）：踩中减速的 Area 逻辑，参考 `GroundInk` 画法
3. 第二张图：换 `PaperBG` 山形种子 + `GroundInk` 配色即换肤
4. 手柄震动/键位自定义：现在只有键盘+左摇杆移动
5. Steam 化：成就/云存档/排行榜都不存在，要卖再加
