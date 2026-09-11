class_name DmgNum
extends Node2D

var text: String = "10"
var crit: bool = false
var life: float = 0.7
var _t: float = 0.7

func setup(pos: Vector2, amount: float, is_crit: bool) -> void:
	position = pos + Vector2(randf_range(-8, 8), -18)
	text = str(int(round(amount)))
	crit = is_crit
	_t = life
	z_index = 20

func _process(delta: float) -> void:
	_t -= delta
	position.y -= 55.0 * delta
	if _t <= 0.0:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var sz: int = 26 if crit else 18
	var col := Color(0.65, 0.12, 0.1) if crit else Color(0.2, 0.18, 0.16)
	var a: float = clampf(_t / life, 0.0, 1.0)
	draw_string(font, Vector2(-12, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(col.r, col.g, col.b, a))
