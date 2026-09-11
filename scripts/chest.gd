class_name TreasureChest
extends Node2D
## Gold chest from golem, touch to open 1-of-3.

var opened: bool = false
var bob: float = 0.0

func _ready() -> void:
	z_index = 3

func _process(delta: float) -> void:
	bob += delta * 3.0
	var main: Node = get_parent()
	if main == null or not (main is MojingMain):
		return
	var m: MojingMain = main as MojingMain
	if opened or not is_instance_valid(m.player):
		return
	if position.distance_to(m.player.position) < 42.0:
		opened = true
		m.open_chest(self)
	queue_redraw()

func _draw() -> void:
	var dy: float = sin(bob) * 2.0
	# glow ring like ref image
	draw_arc(Vector2(0, 6), 26.0, 0, TAU, 32, Color(0.75, 0.6, 0.25, 0.5), 2.0)
	# box body
	draw_rect(Rect2(-16, -6 + dy, 32, 18), Color(0.45, 0.3, 0.12))
	draw_rect(Rect2(-16, -6 + dy, 32, 18), Color(0.75, 0.55, 0.2), false, 2.0)
	# lid
	draw_arc(Vector2(0, -6 + dy), 16.0, PI, TAU, 16, Color(0.55, 0.38, 0.16), 8.0)
	draw_arc(Vector2(0, -6 + dy), 16.0, PI, TAU, 16, Color(0.85, 0.68, 0.3), 2.0)
	draw_circle(Vector2(0, 2 + dy), 3.0, Color(0.9, 0.75, 0.35))
