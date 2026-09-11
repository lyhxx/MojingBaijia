class_name InkCrow
extends MojingEnemy
## Duanju crow: fast dasher, telegraphs then dives.

var dash_state: float = 0.0  # time in current cycle
var dash_dir: Vector2 = Vector2.RIGHT
var telegraphing: bool = false

func crow_move(delta: float, player_pos: Vector2) -> void:
	dash_state += delta
	var to_p: Vector2 = player_pos - position
	if dash_state < 1.6:
		# approach slowly, wobble
		telegraphing = false
		position += to_p.normalized() * speed * 0.7 * delta
		position += Vector2(-to_p.y, to_p.x).normalized() * sin(wobble * 2.0) * 40.0 * delta
	elif dash_state < 2.0:
		# telegraph: shake in place
		telegraphing = true
		dash_dir = to_p.normalized()
	else:
		# dive!
		telegraphing = false
		position += dash_dir * 340.0 * delta
		if dash_state > 2.7:
			dash_state = 0.0

func _draw() -> void:
	var flap: float = sin(wobble * 8.0) * 6.0
	var body := Color(0.18, 0.15, 0.25)
	# wings
	draw_colored_polygon(PackedVector2Array([Vector2(-4, 0), Vector2(-18, -10 - flap), Vector2(-8, 2)]), body)
	draw_colored_polygon(PackedVector2Array([Vector2(4, 0), Vector2(18, -10 + flap), Vector2(8, 2)]), body)
	draw_circle(Vector2.ZERO, 7, body)
	draw_circle(Vector2(5, -2), 2.0, Color(0.7, 0.2, 0.15))
	if telegraphing:
		draw_arc(Vector2.ZERO, 14.0, 0, TAU, 16, Color(0.8, 0.15, 0.12), 2.0)
