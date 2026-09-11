class_name GroundInk
extends Node2D
## World-space courtyard slabs + faint script grid, follows camera snapped.

var target: Camera2D
var _chars: Array = []

func _ready() -> void:
	z_index = -50
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in 26:
		_chars.append(Vector2(rng.randf_range(-700, 700), rng.randf_range(-450, 450)))

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		var snap: Vector2 = target.get_screen_center_position() / 160.0
		position = Vector2(floor(snap.x) * 160.0, floor(snap.y) * 160.0)
		queue_redraw()

func _draw() -> void:
	# slab grid 160px
	var line_c := Color(0.45, 0.42, 0.36, 0.25)
	for gx in range(-5, 6):
		draw_line(Vector2(gx * 160, -560), Vector2(gx * 160, 560), line_c, 2.0)
	for gy in range(-4, 5):
		draw_line(Vector2(-800, gy * 160), Vector2(800, gy * 160), line_c, 2.0)
	# courtyard center slabs
	draw_rect(Rect2(Vector2(-320, -240), Vector2(640, 480)), Color(0.5, 0.47, 0.4, 0.12))
	# faint script strokes (pseudo characters)
	var ink := Color(0.4, 0.38, 0.34, 0.20)
	for c in _chars:
		draw_line(c + Vector2(-10, 0), c + Vector2(10, 0), ink, 2.0)
		draw_line(c + Vector2(0, -12), c + Vector2(0, 12), ink, 2.0)
		draw_line(c + Vector2(-6, -12), c + Vector2(6, -12), ink, 1.5)
