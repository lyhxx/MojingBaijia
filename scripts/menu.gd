extends Control
## Main menu: title, best record, start.

func _ready() -> void:
	AudioMan.start_bgm()
	var b: Dictionary = GameState.load_best()
	var t: float = float(b.get("time", 0.0))
	$VBox/Best.text = "最佳 %02d:%02d · 击杀%d · 等级%d" % [int(t) / 60, int(t) % 60, int(b.get("kills", 0)), int(b.get("level", 0))] if t > 0.0 else "新卷未书 · 落笔开始"
	$VBox/Start.grab_focus()

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ENTER:
		_on_start()
