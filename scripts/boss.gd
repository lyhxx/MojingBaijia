class_name InkJudge
extends MojingEnemy
## Wuzhi Panguan: slow judge, radial bullets + summons. Kill = win.

var skill_burst_t: float = 2.5
var skill_summon_t: float = 6.0

func _draw() -> void:
	var r := 34.0
	# white page aura (erosion white)
	draw_circle(Vector2.ZERO, r + 12.0, Color(0.95, 0.93, 0.88, 0.35))
	# black robe
	draw_circle(Vector2.ZERO, r, Color(0.1, 0.09, 0.11))
	# white mask face
	draw_circle(Vector2(0, -8), 12, Color(0.92, 0.9, 0.85))
	draw_line(Vector2(-6, -10), Vector2(-2, -6), Color(0.1, 0.1, 0.1), 2.0)
	draw_line(Vector2(6, -10), Vector2(2, -6), Color(0.1, 0.1, 0.1), 2.0)
	# judge hat
	draw_rect(Rect2(-20, -38, 40, 12), Color(0.12, 0.1, 0.12))
	draw_rect(Rect2(-12, -50, 24, 14), Color(0.12, 0.1, 0.12))
	# red seal strokes
	draw_line(Vector2(-r, 12), Vector2(r, 12), Color(0.75, 0.15, 0.12), 3.0)
	draw_arc(Vector2.ZERO, r + 6.0, 0, TAU, 40, Color(0.75, 0.55, 0.2), 3.0)
	if hp < max_hp:
		var frac: float = clampf(hp / max_hp, 0.0, 1.0)
		draw_line(Vector2(-30, -56), Vector2(lerpf(-30.0, 30.0, frac), -56), Color(0.8, 0.15, 0.12), 5.0)
