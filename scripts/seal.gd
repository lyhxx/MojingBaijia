class_name FallingSeal
extends Node2D
## Zhenyue green seal: telegraph then smash AOE, like ref image cubes.

var damage: float = 26.0
var radius: float = 95.0
var target: Vector2 = Vector2.ZERO
var fall_t: float = 0.55
var smash_t: float = 0.0
var smashed: bool = false
var h: float = 260.0

func launch_at(pos: Vector2, dmg: float) -> void:
	target = pos
	damage = dmg
	position = pos
	z_index = 4

func _process(delta: float) -> void:
	if not smashed:
		fall_t -= delta
		h = lerpf(0.0, 260.0, clampf(fall_t / 0.55, 0.0, 1.0))
		if fall_t <= 0.0:
			smashed = true
			smash_t = 0.28
			var main: Node = get_parent()
			if main and main.has_method("deal_aoe"):
				main.deal_aoe(target, radius, damage)
		queue_redraw()
	else:
		smash_t -= delta
		if smash_t <= 0.0:
			queue_free()
			return
		queue_redraw()

func _draw() -> void:
	if not smashed:
		# shadow telegraph (red-ish faint) + falling cube height
		var k: float = 1.0 - clampf(fall_t / 0.55, 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius * 0.35 * k + 8.0, Color(0.8, 0.15, 0.12, 0.12))
		draw_circle(Vector2.ZERO, 10.0, Color(0, 0, 0, 0.15))
		# trail
		draw_line(Vector2(0, -h), Vector2.ZERO, Color(0.3, 0.7, 0.6, 0.35), 6.0)
		# green cube body
		var y0: float = -h
		var s: float = 16.0
		var pts := PackedVector2Array([Vector2(-s, y0 - s * 0.5), Vector2(0, y0 - s), Vector2(s, y0 - s * 0.5), Vector2(s, y0 + s * 0.5), Vector2(0, y0 + s), Vector2(-s, y0 + s * 0.5)])
		draw_colored_polygon(pts, Color(0.18, 0.64, 0.51))
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.08, 0.35, 0.28), 2.0)
	else:
		var k2: float = 1.0 - smash_t / 0.28
		draw_circle(Vector2.ZERO, radius * k2, Color(0.18, 0.64, 0.51, 0.5 * (1.0 - k2)))
		draw_arc(Vector2.ZERO, radius * k2, 0, TAU, 32, Color(0.1, 0.45, 0.38), 4.0)
