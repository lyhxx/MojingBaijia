class_name OrbitInk
extends Node2D
## Zumo orbiting ink blade, child of player.

var angle: float = 0.0
var radius: float = 88.0
var spin: float = 2.8
var damage: float = 10.0
var _hit_cd: Dictionary = {}

func _process(delta: float) -> void:
	angle += spin * delta
	position = Vector2(cos(angle), sin(angle)) * radius
	# hit enemies with per-target 0.45s cd
	var main: Node = get_parent().get_parent()
	if main != null and main is MojingMain:
		var m: MojingMain = main as MojingMain
		var now: float = GameState.run_time
		for e in m.enemies.duplicate():
			if not is_instance_valid(e):
				continue
			var en: MojingEnemy = e as MojingEnemy
			if en == null:
				continue
			var rr: float = 46.0 if en.is_elite else 30.0
			# compare in global space
			if global_position.distance_squared_to(en.position) < rr * rr:
				var id: int = e.get_instance_id()
				var last: float = float(_hit_cd.get(id, -9.0))
				if now - last > 0.45:
					_hit_cd[id] = now
					var dmg: float = m.player.roll_damage(damage)
					m.spawn_dmgnum(en.position, dmg, dmg >= damage * 1.5)
					m.spawn_splash(en.position, Color(0.2, 0.4, 0.4, 0.4), 20.0)
					if en.take_damage(dmg):
						m.on_enemy_died(en)
	queue_redraw()

func _draw() -> void:
	# dark ink blade with teal edge
	draw_line(Vector2(-16, 0), Vector2(12, 0), Color(0.12, 0.12, 0.14), 7.0)
	draw_line(Vector2(-16, 0), Vector2(12, 0), Color(0.25, 0.55, 0.55), 2.5)
	draw_circle(Vector2(14, 0), 3.5, Color(0.1, 0.1, 0.12))
