class_name FlyingSword
extends Node2D
## Homing ink sword, manual hit check against main.enemies.

var damage: float = 12.0
var speed: float = 750.0
var pierce: int = 1
var life: float = 1.6
var vel: Vector2 = Vector2.RIGHT
var _hit_ids: Dictionary = {}

func launch(from: Vector2, target_pos: Vector2, dmg: float) -> void:
	position = from
	damage = dmg
	var d: Vector2 = target_pos - from
	if d.length() < 1.0:
		d = Vector2.RIGHT
	vel = d.normalized() * speed
	rotation = vel.angle()
	z_index = 5

func _process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	position += vel * delta
	rotation = vel.angle()
	# homing slight steer to nearest not-yet-hit enemy
	var main: Node = get_parent()
	if main == null or not (main is MojingMain):
		return
	var best: MojingEnemy = null
	var best_d := 1e9
	for e in (main as MojingMain).enemies:
		if not is_instance_valid(e) or _hit_ids.has(e.get_instance_id()):
			continue
		var d: float = position.distance_squared_to(e.position)
		if d < best_d:
			best_d = d
			best = e
	if best != null and best_d < 220.0 * 220.0:
		var want: Vector2 = (best.position - position).normalized() * speed
		vel = vel.lerp(want, 8.0 * delta)
	# hit check
	for e in (main as MojingMain).enemies.duplicate():
		if not is_instance_valid(e) or _hit_ids.has(e.get_instance_id()):
			continue
		var rr: float = 20.0 if not e.is_elite else 30.0
		if position.distance_squared_to(e.position) < rr * rr:
			_hit_ids[e.get_instance_id()] = true
			var dead: bool = e.take_damage(damage)
			var m: MojingMain = main as MojingMain
			m.spawn_splash(position, Color(0.2, 0.3, 0.6, 0.5), 26.0)
			m.spawn_dmgnum(position, damage, damage >= 30.0)
			if dead:
				m.on_enemy_died(e)
			pierce -= 1
			if pierce < 0:
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	# indigo blade like ref image
	draw_line(Vector2(-14, 0), Vector2(10, 0), Color(0.2, 0.3, 0.6), 5.0)
	draw_line(Vector2(-14, 0), Vector2(-22, 0), Color(0.85, 0.9, 1.0, 0.6), 2.0)
	draw_circle(Vector2(12, 0), 3.0, Color(0.15, 0.2, 0.4))
