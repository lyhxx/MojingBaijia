class_name InkBullet
extends Node2D
## Enemy red-black pellet from boss.

var vel: Vector2 = Vector2.ZERO
var damage: float = 12.0
var life: float = 5.0

func launch(from: Vector2, dir: Vector2, spd: float, dmg: float) -> void:
	position = from
	vel = dir.normalized() * spd
	damage = dmg
	z_index = 4

func _process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	position += vel * delta
	var main: Node = get_parent()
	if main != null and main is MojingMain:
		var m: MojingMain = main as MojingMain
		if is_instance_valid(m.player) and m.player.alive:
			if position.distance_squared_to(m.player.position) < 18.0 * 18.0:
				m.player.take_damage(damage)
				if not m.player.alive:
					m._game_over()
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6, Color(0.15, 0.1, 0.1))
	draw_arc(Vector2.ZERO, 6.0, 0, TAU, 12, Color(0.8, 0.15, 0.12), 2.5)
