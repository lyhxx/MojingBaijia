extends Node
## Autoload: holds run state, xp/level, upgrade pool.

signal xp_changed(level: int, xp: int, xp_next: int)
signal hp_changed(hp: float, max_hp: float)
signal level_up(choices: Array)
signal run_time_changed(sec: float)

var level: int = 1
var xp: int = 0
var xp_next: int = 10
var kills: int = 0
var run_time: float = 0.0
var pending_levels: int = 0
var game_over: bool = false
var rerolls: int = 2
var nukes: int = 1

# Upgrade pool ids (self-use minimal set)
var _taken_count: Dictionary = {}

func reset_run() -> void:
	level = 1
	xp = 0
	xp_next = 10
	kills = 0
	run_time = 0.0
	pending_levels = 0
	game_over = false
	rerolls = 2
	nukes = 1
	_taken_count.clear()
	xp_changed.emit(level, xp, xp_next)

const SAVE_PATH := "user://mojing_save.cfg"

func save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)  # keep old bests
	var best_t: float = float(cfg.get_value("best", "time", 0.0))
	var best_k: int = int(cfg.get_value("best", "kills", 0))
	var best_l: int = int(cfg.get_value("best", "level", 0))
	cfg.set_value("best", "time", maxf(best_t, run_time))
	cfg.set_value("best", "kills", maxi(best_k, kills))
	cfg.set_value("best", "level", maxi(best_l, level))
	cfg.save(SAVE_PATH)

func load_best() -> Dictionary:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	return {"time": float(cfg.get_value("best", "time", 0.0)), "kills": int(cfg.get_value("best", "kills", 0)), "level": int(cfg.get_value("best", "level", 0))}

func add_xp(v: int) -> void:
	if game_over:
		return
	xp += v
	while xp >= xp_next:
		xp -= xp_next
		level += 1
		xp_next = int(xp_next * 1.35) + 5
		pending_levels += 1
	xp_changed.emit(level, xp, xp_next)
	if pending_levels > 0:
		pending_levels -= 1
		var choices: Array = roll_choices()
		level_up.emit(choices)

func roll_choices() -> Array:
	var pool: Array = []
	pool.append({"id": "sword_dmg", "name": "青锋·淬", "desc": "飞剑伤害 +25%"})
	pool.append({"id": "sword_cd", "name": "青锋·疾", "desc": "飞剑冷却 -10%"})
	pool.append({"id": "sword_num", "name": "青锋·双", "desc": "飞剑数量 +1 (最多3)", "max": 2})
	pool.append({"id": "seal_dmg", "name": "镇岳·重", "desc": "镇岳印伤害 +30%"})
	pool.append({"id": "seal_cd", "name": "镇岳·频", "desc": "镇岳印冷却 -12%"})
	pool.append({"id": "seal_num", "name": "镇岳·分", "desc": "镇岳印数量 +1 (最多3)", "max": 2})
	pool.append({"id": "orbit_dmg", "name": "逐墨·锋", "desc": "环绕墨剑伤害 +30%"})
	pool.append({"id": "orbit_num", "name": "逐墨·环", "desc": "环绕墨剑 +1 (最多4)", "max": 2})
	pool.append({"id": "soul_dmg", "name": "摄魂·蚀", "desc": "摄魂链伤害 +30%"})
	pool.append({"id": "soul_jumps", "name": "摄魂·连", "desc": "摄魂跳跃 +1 (最多6)", "max": 3})
	pool.append({"id": "crit", "name": "观心·明", "desc": "暴击率+8% 暴伤+20%"})
	pool.append({"id": "move_spd", "name": "通玄·行", "desc": "移速 +8%"})
	pool.append({"id": "max_hp", "name": "养浩·体", "desc": "生命上限 +20 并回满20"})
	pool.append({"id": "pickup", "name": "观心·拾", "desc": "拾取范围 +35%"})
	pool.append({"id": "armor", "name": "墨守·御", "desc": "护甲 +2 减伤"})
	pool.append({"id": "heal", "name": "养浩·春", "desc": "立即回血 50%"})
	# filter maxed
	var filtered: Array = []
	for c in pool:
		var cid: String = String(c["id"])
		if cid == "sword_num" or cid == "seal_num" or cid == "orbit_num":
			var n: int = int(_taken_count.get(cid, 0))
			if n >= 2:
				continue
		if cid == "soul_jumps":
			if int(_taken_count.get(cid, 0)) >= 3:
				continue
		filtered.append(c)
	filtered.shuffle()
	var out: Array = filtered.slice(0, 2)
	if out.size() > 3:
		out.resize(3)
	# guarantee a new-weapon feel at Lv2: force sword_num in first level-up
	if level == 2 and not out.any(func(c): return c["id"] == "sword_num"):
		out[0] = {"id": "sword_num", "name": "青锋·双", "desc": "飞剑数量 +1 (最多3)", "max": 2}
	return out

func roll_chest_choices() -> Array:
	var pool: Array = []
	pool.append({"id": "sword_dmg", "name": "青锋·淬", "desc": "飞剑伤害 +25%"})
	pool.append({"id": "seal_dmg", "name": "镇岳·重", "desc": "镇岳印伤害 +30%"})
	pool.append({"id": "seal_num", "name": "镇岳·分", "desc": "镇岳印数量 +1", "max": 2})
	pool.append({"id": "orbit_num", "name": "逐墨·环", "desc": "环绕墨剑 +1", "max": 2})
	pool.append({"id": "soul_jumps", "name": "摄魂·连", "desc": "摄魂跳跃 +1", "max": 3})
	pool.append({"id": "soul_dmg", "name": "摄魂·蚀", "desc": " 摄魂伤害 +30%"})
	pool.append({"id": "sword_num", "name": "青锋·双", "desc": "飞剑数量 +1", "max": 2})
	pool.append({"id": "max_hp", "name": "养浩·体", "desc": "生命上限 +20 并回血"})
	pool.append({"id": "heal", "name": "续墨果", "desc": "回血 60%"})
	pool.append({"id": "armor", "name": "墨守·御", "desc": "护甲 +2"})
	var filtered: Array = []
	for c in pool:
		var cid2: String = String(c["id"])
		if cid2 == "sword_num" or cid2 == "seal_num":
			if int(_taken_count.get(cid2, 0)) >= 2:
				continue
		filtered.append(c)
	filtered.shuffle()
	var out2: Array = filtered.slice(0, 2)
	if out2.size() > 3:
		out2.resize(3)
	return out2

func mark_taken(id: String) -> void:
	_taken_count[id] = int(_taken_count.get(id, 0)) + 1
