class_name XPGem
extends Node2D

var value: int = 1
var vel: Vector2 = Vector2.ZERO

func _ready() -> void:
	z_index = 2
	vel = Vector2(randf_range(-60, 60), randf_range(-60, 60))

func _process(delta: float) -> void:
	var main: Node = get_parent()
	if main == null or not (main is MojingMain):
		return
	var m: MojingMain = main as MojingMain
	var p: Vector2 = m.player.position if is_instance_valid(m.player) else Vector2.ZERO
	var d: Vector2 = p - position
	var dist: float = d.length()
	if dist < m.player.pickup_radius + 20.0:
		# magnet
		position += d.normalized() * lerpf(500.0, 120.0, clampf(dist / 300.0, 0.0, 1.0)) * delta
	else:
		position += vel * delta
		vel *= 0.92
	if dist < 20.0:
		GameState.add_xp(value)
		AudioMan.play("pickup", -12.0)
		m.unregister_gem(self)
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 7, Color(0.35, 0.65, 1.0, 0.35))
	draw_circle(Vector2.ZERO, 4, Color(0.4, 0.75, 1.0))
