class_name MojingMain
extends Node2D
## Self-use desktop loop: spawn beasts, fire swords, gems, level-up pause.

const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const GolemScript = preload("res://scripts/golem.gd")
const CrowScript = preload("res://scripts/crow.gd")
const BossScript = preload("res://scripts/boss.gd")
const SwordScript = preload("res://scripts/sword.gd")
const SealScript = preload("res://scripts/seal.gd")
const SoulScript = preload("res://scripts/soul.gd")
const GemScript = preload("res://scripts/gem.gd")
const ChestScript = preload("res://scripts/chest.gd")
const BulletScript = preload("res://scripts/ebullet.gd")
const HudScript = preload("res://scripts/hud.gd")
const PaperScript = preload("res://scripts/paper_bg.gd")
const GroundScript = preload("res://scripts/ground_ink.gd")
const SplashScript = preload("res://scripts/splash.gd")
const DmgNumScript = preload("res://scripts/dmgnum.gd")

var player: MojingPlayer
var cam: Camera2D
var hud: MojingHUD
var enemies: Array = []
var gems: Array = []
var chests: Array = []
var ebullets: Array = []
var boss: InkJudge = null
var boss_spawned: bool = false
var victory: bool = false
const BOSS_TIME: float = 600.0  # 10:00判官登场，12:00前击杀
var _spawn_t: float = 0.0
var _crow_t: float = 20.0
var _golem_t: float = 45.0
var _debug_god: bool = false
var _shake: float = 0.0
var _ground: GroundInk

func _ready() -> void:
	GameState.reset_run()
	RenderingServer.set_default_clear_color(Color(0.92, 0.88, 0.78))
	# screen-space paper background
	var paper_layer := CanvasLayer.new()
	paper_layer.layer = -10
	add_child(paper_layer)
	var paper: PaperBG = PaperScript.new()
	paper_layer.add_child(paper)
	paper.refresh()
	_build_decor()
	player = PlayerScript.new()
	player.position = Vector2.ZERO
	add_child(player)
	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.make_current()
	add_child(cam)
	_ground = GroundScript.new()
	_ground.target = cam
	add_child(_ground)
	hud = HudScript.new()
	add_child(hud)
	GameState.hp_changed.emit(player.hp, player.max_hp)
	GameState.level_up.connect(_on_level_up)
	GameState.run_time_changed.emit(0.0)
	AudioMan.start_bgm()

func _build_decor() -> void:
	# archway label like 墨家书院 in ref image
	var arch := Label.new()
	arch.text = "墨 家 书 院"
	arch.add_theme_font_size_override("font_size", 64)
	arch.add_theme_color_override("font_color", Color(0.2, 0.18, 0.15, 0.55))
	arch.position = Vector2(-180, -560)
	var n := Node2D.new()
	n.add_child(arch)
	add_child(n)
	# scattered stones / bamboo hints
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in 40:
		var s := Node2D.new()
		s.position = Vector2(rng.randf_range(-1400, 1400), rng.randf_range(-1000, 1000))
		var poly := Polygon2D.new()
		poly.color = Color(0.5, 0.48, 0.42, 0.35)
		poly.polygon = PackedVector2Array([Vector2(-18, 8), Vector2(0, -10), Vector2(20, 6)])
		s.add_child(poly)
		add_child(s)

func _process(delta: float) -> void:
	if GameState.game_over:
		return
	if get_tree().paused:
		return
	GameState.run_time += delta
	GameState.run_time_changed.emit(GameState.run_time)
	# camera + shake
	if is_instance_valid(player):
		cam.position = cam.position.lerp(player.position, 8.0 * delta)
	if _shake > 0.0:
		_shake = maxf(0.0, _shake - delta * 2.5)
		cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake * 14.0
	else:
		cam.offset = Vector2.ZERO
	# spawn curve: 10 -> 80 cap for self-use perf
	_spawn_t -= delta
	var want_interval: float = lerpf(1.2, 0.28, clampf(GameState.run_time / 480.0, 0.0, 1.0))
	if _spawn_t <= 0.0 and enemies.size() < 80:
		_spawn_t = want_interval
		spawn_enemy(false)
		if GameState.run_time > 300.0 and randf() < 0.25:
			spawn_enemy(false)
	# golem elite every ~75s after 1:00, like stone statues in ref image
	_golem_t -= delta
	if _golem_t <= 0.0:
		_golem_t = 75.0
		if GameState.run_time > 50.0 and enemies.size() < 70:
			spawn_golem()
	# crows after 1:30, pack dives
	_crow_t -= delta
	if _crow_t <= 0.0:
		_crow_t = lerpf(9.0, 4.0, clampf(GameState.run_time / 600.0, 0.0, 1.0))
		if GameState.run_time > 90.0 and enemies.size() < 78:
			spawn_crow()
			if GameState.run_time > 300.0 and randf() < 0.5:
				spawn_crow()
	# boss at 10:00
	if not boss_spawned and GameState.run_time >= BOSS_TIME:
		boss_spawned = true
		spawn_boss()
	# boss skills
	if boss_spawned and is_instance_valid(boss):
		_boss_skills(delta)
	# move enemies toward player + contact damage
	if is_instance_valid(player) and player.alive:
		for e in enemies.duplicate():
			if not is_instance_valid(e):
				continue
			var em: MojingEnemy = e as MojingEnemy
			if em == null:
				continue
			if em.has_method("crow_move"):
				em.crow_move(delta, player.position)
			elif em is InkJudge:
				var dd: Vector2 = player.position - em.position
				if dd.length() > 120.0:
					em.position += dd.normalized() * em.speed * delta
			else:
				var d: Vector2 = player.position - em.position
				var dist0: float = d.length()
				if dist0 > 1.0:
					em.position += d.normalized() * em.speed * delta
			var dist: float = player.position.distance_to(em.position)
			var rad: float = 52.0 if em is InkJudge else (44.0 if em.is_elite else 26.0)
			if dist < rad and GameState.run_time - em.last_hit_t > 0.8:
				em.last_hit_t = GameState.run_time
				if not _debug_god:
					player.take_damage(em.damage)
					if not player.alive:
						_game_over()

func nearest_enemy(pos: Vector2, max_d: float = 900.0) -> MojingEnemy:
	var best: MojingEnemy = null
	var bd := max_d * max_d
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d: float = pos.distance_squared_to((e as Node2D).position)
		if d < bd:
			bd = d
			best = e
	return best

func fire_swords(count: int, dmg: float) -> void:
	if not is_instance_valid(player):
		return
	var tgt: MojingEnemy = nearest_enemy(player.position)
	var aim: Vector2 = tgt.position if tgt else player.position + Vector2.RIGHT * 100.0
	AudioMan.play("sword", -14.0)
	for i in count:
		var s: FlyingSword = SwordScript.new()
		add_child(s)
		var offset := Vector2(0, (i - (count - 1) * 0.5) * 26.0).rotated((aim - player.position).angle() + PI / 2.0)
		s.launch(player.position + offset, aim + offset * 2.0, player.roll_damage(dmg))

func fire_soul(jumps: int, dmg: float) -> void:
	if not is_instance_valid(player) or enemies.is_empty():
		return
	AudioMan.play("soul", -10.0)
	var visited: Dictionary = {}
	var pts := PackedVector2Array([player.position])
	var from: Vector2 = player.position
	var cur: MojingEnemy = nearest_enemy(from, 620.0)
	var total: int = mini(jumps + 1, 7)
	for i in total:
		if cur == null or not is_instance_valid(cur):
			break
		visited[cur.get_instance_id()] = true
		pts.append(cur.position)
		var real: float = player.roll_damage(dmg)
		spawn_dmgnum(cur.position, real, real >= dmg * 1.5)
		spawn_splash(cur.position, Color(0.5, 0.3, 0.7, 0.5), 24.0)
		if cur.take_damage(real):
			on_enemy_died(cur)
		# next: nearest to cur not visited
		var best: MojingEnemy = null
		var bd := 320.0 * 320.0
		for e in enemies:
			if not is_instance_valid(e) or visited.has((e as Node2D).get_instance_id()):
				continue
			var dd: float = cur.position.distance_squared_to((e as Node2D).position)
			if dd < bd:
				bd = dd
				best = e
		cur = best
	if pts.size() >= 2:
		var fx: SoulChainFx = SoulScript.new()
		add_child(fx)
		# fx points are global; convert to local of fx at origin
		fx.position = Vector2.ZERO
		fx.setup(pts)

func fire_seals(count: int, dmg: float) -> void:
	if not is_instance_valid(player):
		return
	for i in count:
		var tgt: MojingEnemy = nearest_enemy(player.position + Vector2(randf_range(-120, 120), randf_range(-120, 120)), 850.0)
		var pos: Vector2
		if tgt != null and is_instance_valid(tgt):
			pos = tgt.position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		else:
			pos = player.position + Vector2(randf_range(-250, 250), randf_range(-250, 250))
		var seal: FallingSeal = SealScript.new()
		add_child(seal)
		seal.launch_at(pos, dmg)

func deal_aoe(pos: Vector2, radius: float, dmg: float) -> void:
	spawn_splash(pos, Color(0.18, 0.64, 0.51, 0.55), radius)
	add_shake(0.35)
	AudioMan.play("seal", -8.0)
	for e in enemies.duplicate():
		if not is_instance_valid(e):
			continue
		if pos.distance_squared_to((e as Node2D).position) < radius * radius:
			var real: float = player.roll_damage(dmg) if is_instance_valid(player) else dmg
			spawn_dmgnum((e as Node2D).position, real, real >= dmg * 1.5)
			var dead: bool = (e as MojingEnemy).take_damage(real)
			if dead:
				on_enemy_died(e as MojingEnemy)

func spawn_enemy(elite: bool) -> void:
	var e: MojingEnemy = EnemyScript.new()
	var ang: float = randf() * TAU
	var r: float = randf_range(700, 1000)
	e.position = player.position + Vector2(cos(ang), sin(ang)) * r
	var t: float = GameState.run_time
	var hp: float = (18.0 + t * 0.09) * (8.0 if elite else 1.0)
	var spd: float = randf_range(85, 115) + minf(40.0, t * 0.03)
	var dmg: float = 8.0 + t * 0.008
	e.setup(hp, spd, dmg, 5 if elite else 1, elite)
	add_child(e)
	enemies.append(e)

func spawn_golem() -> void:
	var g: MojingGolem = GolemScript.new()
	var ang: float = randf() * TAU
	g.position = player.position + Vector2(cos(ang), sin(ang)) * 850.0
	var t: float = GameState.run_time
	g.setup(420.0 + t * 1.1, 48.0, 18.0 + t * 0.01, 20, true)
	add_child(g)
	enemies.append(g)

func spawn_crow() -> void:
	var c: InkCrow = CrowScript.new()
	var ang: float = randf() * TAU
	c.position = player.position + Vector2(cos(ang), sin(ang)) * randf_range(650, 900)
	var t: float = GameState.run_time
	c.setup(14.0 + t * 0.05, 120.0, 10.0 + t * 0.008, 2, false)
	add_child(c)
	enemies.append(c)

func spawn_boss() -> void:
	boss = BossScript.new()
	boss.position = player.position + Vector2(0, -800)
	boss.setup(9000.0, 55.0, 22.0, 100, true)
	add_child(boss)
	enemies.append(boss)
	AudioMan.play("boss", -4.0)
	add_shake(0.8)
	hud.show_boss("无字判官")
	# clear some bullets pressure: drop a chest near player
	var c: TreasureChest = ChestScript.new()
	c.position = player.position + Vector2(120, 60)
	add_child(c)
	chests.append(c)

func _boss_skills(delta: float) -> void:
	if not is_instance_valid(boss):
		return
	boss.skill_burst_t -= delta
	boss.skill_summon_t -= delta
	var enrage: bool = boss.hp < boss.max_hp * 0.3
	if boss.skill_burst_t <= 0.0:
		boss.skill_burst_t = 2.6 if enrage else 3.6
		var n: int = 12 if enrage else 8
		for i in n:
			var b: InkBullet = BulletScript.new()
			add_child(b)
			ebullets.append(b)
			b.launch(boss.position, Vector2.RIGHT.rotated(TAU * float(i) / float(n)), 170.0, 12.0)
			b.tree_exited.connect(func(): ebullets.erase(b))
	if boss.skill_summon_t <= 0.0:
		boss.skill_summon_t = 7.0 if enrage else 9.0
		for i in 3:
			spawn_enemy(false)
			if is_instance_valid(enemies.back()):
				(enemies.back() as Node2D).position = boss.position + Vector2(randf_range(-160, 160), randf_range(-160, 160))

func spawn_hit_fx(pos: Vector2) -> void:
	spawn_splash(pos, Color(0.2, 0.3, 0.6, 0.5), 26.0)

func spawn_splash(pos: Vector2, c: Color, r: float) -> void:
	var s: InkSplash = SplashScript.new()
	add_child(s)
	s.setup(pos, c, r)

func spawn_dmgnum(pos: Vector2, amount: float, crit: bool) -> void:
	if amount < 1.0:
		return
	var d: DmgNum = DmgNumScript.new()
	add_child(d)
	d.setup(pos, amount, crit)

func add_shake(v: float) -> void:
	_shake = minf(1.0, _shake + v)

func on_enemy_died(e: MojingEnemy) -> void:
	enemies.erase(e)
	GameState.kills += 1
	if e is InkJudge:
		var bp: Vector2 = e.position
		e.queue_free()
		boss = null
		hud.hide_boss()
		# shower gems + victory
		for i in 12:
			var gv: XPGem = GemScript.new()
			gv.position = bp + Vector2(randf_range(-120, 120), randf_range(-120, 120))
			gv.value = 10
			add_child(gv)
			gems.append(gv)
		_victory()
		return
	var is_golem: bool = e is MojingGolem
	var is_crow: bool = e is InkCrow
	var pos: Vector2 = e.position
	var xp_v: int = e.xp_value
	spawn_splash(pos, Color(0.15, 0.12, 0.14, 0.5), 30.0 if not is_golem else 70.0)
	e.queue_free()
	if is_golem:
		var c: TreasureChest = ChestScript.new()
		c.position = pos
		add_child(c)
		chests.append(c)
		# golem also drops some gems
		for i in 3:
			var g2: XPGem = GemScript.new()
			g2.position = pos + Vector2(randf_range(-40, 40), randf_range(-40, 40))
			g2.value = 5
			add_child(g2)
			gems.append(g2)
		return
	# drop gem(s)
	var g: XPGem = GemScript.new()
	g.position = pos
	g.value = xp_v
	add_child(g)
	gems.append(g)

func open_chest(c: TreasureChest) -> void:
	chests.erase(c)
	c.queue_free()
	AudioMan.play("chest", -6.0)
	# heal small + 1-of-3 chest rewards
	if is_instance_valid(player):
		player.hp = minf(player.max_hp, player.hp + player.max_hp * 0.15)
		GameState.hp_changed.emit(player.hp, player.max_hp)
	get_tree().paused = true
	hud.show_choices(GameState.roll_chest_choices(), "宝箱 · 三选一")

func unregister_gem(g: XPGem) -> void:
	gems.erase(g)

func _on_level_up(choices: Array) -> void:
	AudioMan.play("levelup", -8.0)
	get_tree().paused = true
	hud.show_choices(choices)

func apply_upgrade(id: String) -> void:
	if is_instance_valid(player):
		player.apply_choice(id)
	get_tree().paused = false
	# chain pending levels (from multi-kill xp overflow)
	if GameState.pending_levels > 0:
		GameState.pending_levels -= 1
		_on_level_up(GameState.roll_choices())

func _game_over() -> void:
	if GameState.game_over and victory:
		return
	GameState.game_over = true
	GameState.save_best()
	get_tree().paused = true
	hud.show_end(false, GameState.run_time, GameState.kills, GameState.level)

func _victory() -> void:
	if victory:
		return
	victory = true
	GameState.game_over = true
	GameState.save_best()
	get_tree().paused = true
	hud.show_end(true, GameState.run_time, GameState.kills, GameState.level)

func reroll_choices() -> void:
	if not hud._panel.visible or GameState.rerolls <= 0:
		return
	GameState.rerolls -= 1
	AudioMan.play("pickup", -8.0)
	hud.show_choices(GameState.roll_choices(), hud._panel_title.text)

func cast_nuke() -> void:
	if GameState.game_over or get_tree().paused or GameState.nukes <= 0:
		return
	GameState.nukes -= 1
	AudioMan.play("nuke", -4.0)
	add_shake(1.0)
	var bp: Vector2 = player.position
	spawn_splash(bp, Color(0.75, 0.15, 0.12, 0.6), 420.0)
	for e in enemies.duplicate():
		if not is_instance_valid(e):
			continue
		var en: MojingEnemy = e as MojingEnemy
		if en is InkJudge:
			en.take_damage(en.max_hp * 0.15)
		elif en.is_elite:
			if en.take_damage(en.max_hp * 0.35):
				on_enemy_died(en)
		else:
			if en.take_damage(9999.0):
				on_enemy_died(en)
	hud.refresh_items()

func toggle_pause() -> void:
	if GameState.game_over:
		return
	if hud._panel.visible:
		return
	get_tree().paused = not get_tree().paused
	hud.show_pause(get_tree().paused)

func restart_run() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = (event as InputEventKey).keycode
		if kc == KEY_F1:
			_debug_god = not _debug_god
		if kc == KEY_X:
			cast_nuke()
		if kc == KEY_ESCAPE:
			toggle_pause()
		if kc == KEY_R and (GameState.game_over or hud._end_panel.visible):
			restart_run()
