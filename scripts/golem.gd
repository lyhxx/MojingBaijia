class_name MojingGolem
extends MojingEnemy
## Stone golem elite: slow tank with ripple ring, drops chest.

var ripple_t: float = 0.0

func _process(delta: float) -> void:
	ripple_t += delta * 2.2
	super._process(delta)

func _draw() -> void:
	var r := 26.0
	# water ripple like ref image
	var rr: float = r + 10.0 + sin(ripple_t * 2.0) * 4.0
	draw_arc(Vector2(0, 10), rr, 0, TAU, 40, Color(0.9, 0.9, 0.88, 0.5), 2.0)
	draw_arc(Vector2(0, 10), rr - 8.0, 0, TAU, 40, Color(0.9, 0.9, 0.88, 0.3), 1.5)
	# rock body: stacked gray blocks with ink script lines
	draw_circle(Vector2.ZERO, r, Color(0.55, 0.53, 0.48))
	draw_circle(Vector2(-8, -6), 14, Color(0.62, 0.6, 0.55))
	draw_circle(Vector2(9, -4), 12, Color(0.5, 0.48, 0.44))
	draw_rect(Rect2(-10, -14, 20, 10), Color(0.4, 0.38, 0.35))
	draw_circle(Vector2.ZERO, 5, Color(0.15, 0.12, 0.1))
	# ink script strokes
	draw_line(Vector2(-14, 6), Vector2(14, 6), Color(0.25, 0.23, 0.2, 0.7), 1.5)
	draw_line(Vector2(-12, 12), Vector2(12, 12), Color(0.25, 0.23, 0.2, 0.5), 1.0)
	# ochre gold elite ring
	draw_arc(Vector2.ZERO, r + 6.0, 0, TAU, 32, Color(0.75, 0.55, 0.2), 3.0)
	# hp bar
	if hp < max_hp:
		var frac: float = clampf(hp / max_hp, 0.0, 1.0)
		draw_line(Vector2(-24, -34), Vector2(lerpf(-24.0, 24.0, frac), -34), Color(0.8, 0.15, 0.12), 4.0)
