class_name PaperBG
extends Node2D
## Static rice-paper + distant mountains + bamboo edges, screen space.

func _ready() -> void:
	z_index = -100

func _draw() -> void:
	var vs: Vector2 = get_viewport_rect().size
	if vs.x < 10.0:
		vs = Vector2(1920, 1080)
	# rice paper base
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.92, 0.88, 0.78))
	# paper fiber noise
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 260:
		var p := Vector2(rng.randf_range(0, vs.x), rng.randf_range(0, vs.y))
		draw_circle(p, rng.randf_range(1.0, 2.5), Color(0.6, 0.55, 0.45, 0.05))
	# far mountains (bluish gray wash)
	var hy: float = 200.0
	var far := PackedVector2Array([Vector2(0, hy)])
	for x in range(0, int(vs.x) + 160, 160):
		far.append(Vector2(x, hy - rng.randf_range(40, 130)))
	far.append(Vector2(vs.x, hy))
	far.append(Vector2(vs.x, 0))
	far.append(Vector2(0, 0))
	draw_colored_polygon(far, Color(0.55, 0.6, 0.62, 0.35))
	var near := PackedVector2Array([Vector2(0, hy + 40)])
	for x in range(0, int(vs.x) + 200, 200):
		near.append(Vector2(x, hy + 40 - rng.randf_range(20, 80)))
	near.append(Vector2(vs.x, hy + 40))
	near.append(Vector2(vs.x, 0))
	near.append(Vector2(0, 0))
	draw_colored_polygon(near, Color(0.45, 0.5, 0.52, 0.30))
	# bamboo clusters at edges
	_draw_bamboo(Vector2(40, vs.y * 0.35))
	_draw_bamboo(Vector2(vs.x - 60, vs.y * 0.45))
	_draw_bamboo(Vector2(90, vs.y * 0.75))
	_draw_bamboo(Vector2(vs.x - 110, vs.y * 0.8))
	# edge erosion vignette
	var e := 46.0
	draw_rect(Rect2(Vector2.ZERO, Vector2(vs.x, e)), Color(0.5, 0.45, 0.38, 0.18))
	draw_rect(Rect2(Vector2(0, vs.y - e), Vector2(vs.x, e)), Color(0.5, 0.45, 0.38, 0.22))
	draw_rect(Rect2(Vector2.ZERO, Vector2(e, vs.y)), Color(0.5, 0.45, 0.38, 0.18))
	draw_rect(Rect2(Vector2(vs.x - e, 0), Vector2(e, vs.y)), Color(0.5, 0.45, 0.38, 0.18))

func _draw_bamboo(base: Vector2) -> void:
	var stalk := Color(0.35, 0.4, 0.33, 0.6)
	var leaf := Color(0.3, 0.36, 0.3, 0.55)
	for s in 3:
		var x: float = base.x + s * 14.0
		draw_line(Vector2(x, base.y - 120), Vector2(x, base.y + 120), stalk, 4.0)
		for L in 5:
			var y: float = base.y - 100 + L * 44.0
			draw_line(Vector2(x, y), Vector2(x - 34, y - 16), leaf, 3.0)
			draw_line(Vector2(x, y + 10), Vector2(x + 34, y - 6), leaf, 3.0)

func refresh() -> void:
	queue_redraw()
