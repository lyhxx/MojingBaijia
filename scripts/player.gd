class_name MojingPlayer
extends Node2D
## Scholar, WASD/arrows move, auto Qingfeng swords.

var max_hp: float = 120.0
var hp: float = 120.0
var base_speed: float = 300.0
var speed_mul: float = 1.0
var armor: float = 0.0
var pickup_radius: float = 110.0
var invuln_t: float = 0.0

# Qingfeng (flying swords)
var sword_damage: float = 12.0
var sword_cooldown: float = 0.9
var sword_count: int = 1
var _cd: float = 0.4
# Zhenyue (falling seals, green cubes in ref image)
var seal_damage: float = 26.0
var seal_cooldown: float = 3.2
var seal_count: int = 1
var _seal_cd: float = 1.5
# Zhumo (orbiting ink blades)
var orbit_damage: float = 10.0
var orbit_count: int = 2
# Shehun (chain soul drain)
var soul_damage: float = 18.0
var soul_cooldown: float = 2.6
var soul_jumps: int = 3
var _soul_cd: float = 2.0
# Passives: guanxin crit, tongxuan speed handled via speed_mul
var crit_chance: float = 0.05
var crit_mult: float = 1.6

const OrbitScript = preload("res://scripts/orbit.gd")

var alive: bool = true

func _ready() -> void:
	z_index = 10
	_ensure_orbits()

func _process(delta: float) -> void:
	if not alive or GameState.game_over:
		return
	if invuln_t > 0.0:
		invuln_t -= delta
	# --- move: arrows (ui_*) + WASD ---
	var dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_physical_key_pressed(KEY_W):
		dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		dir.y += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		dir.x += 1.0
	if dir.length() > 1.0:
		dir = dir.normalized()
	position += dir * base_speed * speed_mul * delta
	# --- auto attack ---
	_cd -= delta
	if _cd <= 0.0:
		_cd = sword_cooldown
		var main: Node = get_parent()
		if main and main.has_method("fire_swords"):
			main.fire_swords(sword_count, sword_damage)
	_seal_cd -= delta
	if _seal_cd <= 0.0:
		_seal_cd = seal_cooldown
		var main2: Node = get_parent()
		if main2 and main2.has_method("fire_seals"):
			main2.fire_seals(seal_count, seal_damage)
	_soul_cd -= delta
	if _soul_cd <= 0.0:
		_soul_cd = soul_cooldown
		var main3: Node = get_parent()
		if main3 and main3.has_method("fire_soul"):
			main3.fire_soul(soul_jumps, soul_damage)
	queue_redraw()

func roll_damage(base: float) -> float:
	if randf() < crit_chance:
		return base * crit_mult
	return base

func _ensure_orbits() -> void:
	# remove extras
	var kids: Array = []
	for c in get_children():
		if c is OrbitInk:
			kids.append(c)
	while kids.size() > orbit_count:
		var r: Node = kids.pop_back()
		r.queue_free()
	while kids.size() < orbit_count:
		var o: OrbitInk = OrbitScript.new()
		var n: int = kids.size()
		o.angle = TAU * float(n) / float(maxi(1, orbit_count))
		o.radius = 88.0
		o.damage = orbit_damage
		add_child(o)
		kids.append(o)
	# sync damage
	for k in kids:
		(k as OrbitInk).damage = orbit_damage

func take_damage(raw: float) -> void:
	if not alive or invuln_t > 0.0:
		return
	var dmg: float = maxf(1.0, raw - armor)
	hp -= dmg
	invuln_t = 0.35
	GameState.hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		hp = 0.0
		alive = false
		GameState.game_over = true

func apply_choice(id: String) -> void:
	match id:
		"sword_dmg":
			sword_damage *= 1.25
		"sword_cd":
			sword_cooldown = maxf(0.25, sword_cooldown * 0.9)
		"sword_num":
			sword_count = mini(3, sword_count + 1)
		"seal_dmg":
			seal_damage *= 1.3
		"seal_cd":
			seal_cooldown = maxf(1.2, seal_cooldown * 0.88)
		"seal_num":
			seal_count = mini(3, seal_count + 1)
		"orbit_dmg":
			orbit_damage *= 1.3
			_ensure_orbits()
		"orbit_num":
			orbit_count = mini(4, orbit_count + 1)
			_ensure_orbits()
		"soul_dmg":
			soul_damage *= 1.3
		"soul_jumps":
			soul_jumps = mini(6, soul_jumps + 1)
		"soul_cd":
			soul_cooldown = maxf(1.0, soul_cooldown * 0.88)
		"crit":
			crit_chance = minf(0.4, crit_chance + 0.08)
			crit_mult += 0.2
		"move_spd":
			speed_mul *= 1.08
		"max_hp":
			max_hp += 20.0
			hp = minf(max_hp, hp + 20.0)
			GameState.hp_changed.emit(hp, max_hp)
		"heal":
			hp = minf(max_hp, hp + max_hp * 0.6)
			GameState.hp_changed.emit(hp, max_hp)
		"pickup":
			pickup_radius *= 1.35
		"armor":
			armor += 2.0
	GameState.mark_taken(id)

func _draw() -> void:
	# shadow
	draw_circle(Vector2(0, 14), 16, Color(0, 0, 0, 0.12))
	# robe: dark blue body
	draw_circle(Vector2.ZERO, 14, Color(0.16, 0.22, 0.38))
	draw_circle(Vector2(0, -4), 9, Color(0.25, 0.42, 0.55))
	# hat
	draw_line(Vector2(-10, -10), Vector2(10, -10), Color(0.1, 0.1, 0.12), 4.0)
	# hp ring when hurt flashes
	if invuln_t > 0.0:
		draw_arc(Vector2.ZERO, 20, 0, TAU, 24, Color(0.8, 0.15, 0.12, 0.8), 2.0)
