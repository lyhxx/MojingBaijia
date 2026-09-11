class_name SoulChainFx
extends Node2D
## Shehun purple chain visual, fades fast.

var pts: PackedVector2Array = PackedVector2Array()
var life: float = 0.35
var _t: float = 0.35

func setup(points: PackedVector2Array) -> void:
	pts = points
	_t = life
	z_index = 6

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if pts.size() < 2:
		return
	var a: float = clampf(_t / life, 0.0, 1.0)
	draw_polyline(pts, Color(0.45, 0.25, 0.6, 0.9 * a), 3.0)
	for p in pts:
		draw_circle(p - position, 5.0, Color(0.55, 0.35, 0.8, 0.7 * a))
