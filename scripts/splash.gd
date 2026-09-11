class_name InkSplash
extends Node2D

var color: Color = Color(0.2, 0.3, 0.6, 0.5)
var max_r: float = 34.0
var life: float = 0.35
var _t: float = 0.35

func setup(pos: Vector2, c: Color, r: float) -> void:
	position = pos
	color = c
	max_r = r
	_t = life
	z_index = 3

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var k: float = 1.0 - _t / life
	draw_circle(Vector2.ZERO, max_r * k, Color(color.r, color.g, color.b, 0.45 * (1.0 - k)))
	draw_arc(Vector2.ZERO, max_r * k, 0, TAU, 24, Color(color.r, color.g, color.b, 0.8 * (1.0 - k * 0.5)), 2.5)
