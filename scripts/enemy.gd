class_name MojingEnemy
extends Node2D
## Ink beast chaser. Manual movement, no physics.

var max_hp: float = 18.0
var hp: float = 18.0
var speed: float = 95.0
var damage: float = 8.0
var xp_value: int = 1
var is_elite: bool = false
var last_hit_t: float = -9.0
var wobble: float = 0.0

func setup(p_hp: float, p_speed: float, p_dmg: float, p_xp: int, elite: bool) -> void:
	max_hp = p_hp
	hp = p_hp
	speed = p_speed
	damage = p_dmg
	xp_value = p_xp
	is_elite = elite
	if elite:
		scale = Vector2(2.2, 2.2)

func _process(delta: float) -> void:
	wobble += delta * 6.0
	queue_redraw()

func take_damage(v: float) -> bool:
	hp -= v
	return hp <= 0.0

func _draw() -> void:
	var body := Color(0.12, 0.1, 0.12)
	var edge := Color(0.35, 0.3, 0.45)
	var r := 12.0
	# blob with wobble spikes
	draw_circle(Vector2.ZERO, r, body)
	draw_circle(Vector2(cos(wobble) * 3.0, sin(wobble) * 3.0), r * 0.7, edge)
	draw_circle(Vector2(-4, -3), 2.5, Color(0.7, 0.2, 0.15))
	draw_circle(Vector2(4, -3), 2.5, Color(0.7, 0.2, 0.15))
	if is_elite:
		# ochre gold ring like the stone golem elite in ref image
		draw_arc(Vector2.ZERO, r + 5.0, 0, TAU, 32, Color(0.75, 0.55, 0.2), 3.0)
	if hp < max_hp:
		var frac: float = clampf(hp / max_hp, 0.0, 1.0)
		draw_line(Vector2(-12, -16), Vector2(lerpf(-12.0, 12.0, frac), -16), Color(0.8, 0.15, 0.12), 3.0)
