class_name MojingHUD
extends CanvasLayer
## Top-left level/xp, top-center timer, bottom bars, level-up panel.

var _lvl_label: Label
var _xp_bar: ProgressBar
var _time_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _panel: PanelContainer
var _panel_title: Label
var _choice_btns: Array[Button] = []
var _pending: Array = []
var _hint: Label
var _bl: Label
var _br: Label
var _boss_bar: ProgressBar
var _boss_label: Label
var _end_panel: PanelContainer
var _end_label: Label
var _rr_label: Label
var _nuke_label: Label
var _pause_panel: PanelContainer
var _reroll_btn: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	# --- top-left ---
	var tl := VBoxContainer.new()
	tl.position = Vector2(24, 16)
	tl.add_theme_constant_override("separation", 4)
	add_child(tl)
	_lvl_label = Label.new()
	_lvl_label.add_theme_font_size_override("font_size", 28)
	_lvl_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	tl.add_child(_lvl_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(360, 14)
	_xp_bar.show_percentage = false
	tl.add_child(_xp_bar)
	# --- top-center time ---
	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", 40)
	_time_label.add_theme_color_override("font_color", Color(0.12, 0.1, 0.08))
	_time_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_time_label.position = Vector2(-80, 8)
	_time_label.custom_minimum_size = Vector2(160, 50)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_time_label)
	# --- player hp (screen-bottom center, follows loosely) ---
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(220, 12)
	_hp_bar.show_percentage = false
	_hp_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hp_bar.position = Vector2(-110, -90)
	add_child(_hp_bar)
	_hp_label = Label.new()
	_hp_label.add_theme_font_size_override("font_size", 16)
	_hp_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hp_label.position = Vector2(-110, -70)
	_hp_label.custom_minimum_size = Vector2(220, 22)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_hp_label)
	# --- bottom-left weapons / bottom-right relics (text placeholders) ---
	_bl = Label.new()
	_bl.text = "1 青锋印   2 镇岳印   3 逐墨印   4 摄魂印"
	_bl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_bl.position = Vector2(24, -48)
	add_child(_bl)
	_br = Label.new()
	_br.text = "养浩0 墨守0 观心0 通玄0"
	_br.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_br.position = Vector2(-420, -48)
	add_child(_br)
	# --- boss bar top ---
	_boss_label = Label.new()
	_boss_label.text = ""
	_boss_label.add_theme_font_size_override("font_size", 22)
	_boss_label.add_theme_color_override("font_color", Color(0.5, 0.1, 0.1))
	_boss_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_label.position = Vector2(-200, 62)
	_boss_label.custom_minimum_size = Vector2(400, 28)
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_boss_label)
	_boss_bar = ProgressBar.new()
	_boss_bar.custom_minimum_size = Vector2(600, 12)
	_boss_bar.show_percentage = false
	_boss_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_bar.position = Vector2(-300, 92)
	_boss_bar.visible = false
	add_child(_boss_bar)
	# --- top-right reroll/nuke like ref image ---
	_rr_label = Label.new()
	_rr_label.add_theme_font_size_override("font_size", 24)
	_rr_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_rr_label.position = Vector2(-220, 16)
	_rr_label.custom_minimum_size = Vector2(200, 30)
	_rr_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_rr_label)
	_nuke_label = Label.new()
	_nuke_label.add_theme_font_size_override("font_size", 24)
	_nuke_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_nuke_label.position = Vector2(-220, 50)
	_nuke_label.custom_minimum_size = Vector2(200, 30)
	_nuke_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_nuke_label)
	refresh_items()
	# --- pause panel ---
	_pause_panel = PanelContainer.new()
	_pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	_pause_panel.position = Vector2(-200, -120)
	_pause_panel.custom_minimum_size = Vector2(400, 240)
	_pause_panel.visible = false
	add_child(_pause_panel)
	var pv := VBoxContainer.new()
	_pause_panel.add_child(pv)
	var pt := Label.new()
	pt.text = "暂停 · Esc继续"
	pt.add_theme_font_size_override("font_size", 26)
	pv.add_child(pt)
	var resume_b := Button.new()
	resume_b.text = "继续 (Esc)"
	resume_b.pressed.connect(func(): get_parent().toggle_pause())
	pv.add_child(resume_b)
	var restart_b := Button.new()
	restart_b.text = "重开 (R)"
	restart_b.pressed.connect(func(): get_parent().restart_run())
	pv.add_child(restart_b)
	var menu_b := Button.new()
	menu_b.text = "回主菜单"
	menu_b.pressed.connect(func(): get_parent().to_menu())
	pv.add_child(menu_b)
	# --- end panel ---
	_end_panel = PanelContainer.new()
	_end_panel.set_anchors_preset(Control.PRESET_CENTER)
	_end_panel.position = Vector2(-260, -120)
	_end_panel.custom_minimum_size = Vector2(520, 240)
	_end_panel.visible = false
	add_child(_end_panel)
	var ev := VBoxContainer.new()
	_end_panel.add_child(ev)
	_end_label = Label.new()
	_end_label.add_theme_font_size_override("font_size", 26)
	ev.add_child(_end_label)
	var rh := Label.new()
	rh.text = "按R重开 · F1无敌"
	ev.add_child(rh)
	_hint = Label.new()
	_hint.text = "WASD/方向键移动 · 自动攻击 · 1/2/3 升级 · F1 无敌调试"
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint.position = Vector2(24, -80)
	_hint.add_theme_font_size_override("font_size", 14)
	add_child(_hint)
	# --- level-up panel ---
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.position = Vector2(-260, -140)
	_panel.custom_minimum_size = Vector2(520, 280)
	_panel.visible = false
	add_child(_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	_panel.add_child(vb)
	var title := Label.new()
	title.text = "升级 · 三选一 (按 1/2/3)"
	title.add_theme_font_size_override("font_size", 24)
	vb.add_child(title)
	_panel_title = title
	for i in 3:
		var b := Button.new()
		b.custom_minimum_size = Vector2(480, 56)
		b.pressed.connect(_on_pick.bind(i))
		vb.add_child(b)
		_choice_btns.append(b)
	_reroll_btn = Button.new()
	_reroll_btn.text = "重写换一批 (Q)"
	_reroll_btn.pressed.connect(func(): get_parent().reroll_choices())
	vb.add_child(_reroll_btn)
	GameState.xp_changed.connect(_on_xp)
	GameState.hp_changed.connect(_on_hp)
	GameState.run_time_changed.connect(_on_time)
	_on_xp(GameState.level, GameState.xp, GameState.xp_next)

func _process(_delta: float) -> void:
	var main: Node = get_parent()
	if main != null and main is MojingMain:
		var m: MojingMain = main as MojingMain
		if m.boss_spawned and is_instance_valid(m.boss):
			_boss_bar.max_value = m.boss.max_hp
			_boss_bar.value = maxf(0.0, m.boss.hp)

func _on_xp(lv: int, cur: int, nxt: int) -> void:
	_lvl_label.text = "等级 %d   经验 %d/%d" % [lv, cur, nxt]
	_xp_bar.max_value = nxt
	_xp_bar.value = cur
	refresh_passives()

func refresh_passives() -> void:
	var t: Dictionary = GameState._taken_count
	var yang: int = int(t.get("max_hp", 0)) + int(t.get("heal", 0))
	var mo: int = int(t.get("armor", 0))
	var guan: int = int(t.get("pickup", 0)) + int(t.get("crit", 0))
	var tong: int = int(t.get("move_spd", 0))
	_br.text = "养浩%d 墨守%d 观心%d 通玄%d" % [yang, mo, guan, tong]
	var main: Node = get_parent()
	if main != null and main is MojingMain and is_instance_valid((main as MojingMain).player):
		var p: MojingPlayer = (main as MojingMain).player
		_bl.text = "1青锋x%d 2镇岳x%d 3逐墨x%d 4摄魂x%d" % [p.sword_count, p.seal_count, p.orbit_count, p.soul_jumps]

func show_boss(bname: String) -> void:
	_boss_label.text = bname
	_boss_bar.visible = true
	_boss_bar.max_value = 9000.0
	_boss_bar.value = 9000.0

func hide_boss() -> void:
	_boss_bar.visible = false
	_boss_label.text = ""

func show_end(win: bool, sec: float, kills: int, lv: int) -> void:
	_panel.visible = false
	var m: int = int(sec) / 60
	var s: int = int(sec) % 60
	_end_label.text = "%s · %02d:%02d · 击杀%d · 等级%d" % ["大胜·墨守成卷" if win else "墨尽·卷散", m, s, kills, lv]
	_end_panel.visible = true

func _on_hp(hp: float, mhp: float) -> void:
	_hp_bar.max_value = mhp
	_hp_bar.value = hp
	_hp_label.text = "%d/%d" % [int(hp), int(mhp)]

func _on_time(sec: float) -> void:
	var m: int = int(sec) / 60
	var s: int = int(sec) % 60
	_time_label.text = "%02d:%02d" % [m, s]

func show_choices(choices: Array, title_text: String = "升级 · 三选一 (按 1/2/3)") -> void:
	_pending = choices
	_panel_title.text = title_text
	for i in 3:
		if i < choices.size():
			var c: Dictionary = choices[i]
			_choice_btns[i].text = "%d. %s — %s" % [i + 1, c["name"], c["desc"]]
		else:
			_choice_btns[i].text = "—"
	_panel.visible = true
	refresh_items()

func refresh_items() -> void:
	_rr_label.text = "重写 %d/2 · Q" % GameState.rerolls
	_nuke_label.text = "禁咒 %d/1 · X" % GameState.nukes

func show_pause(v: bool) -> void:
	_pause_panel.visible = v

func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: int = (event as InputEventKey).keycode
		if k == KEY_1 or k == KEY_KP_1:
			_on_pick(0)
		elif k == KEY_2 or k == KEY_KP_2:
			_on_pick(1)
		elif k == KEY_3 or k == KEY_KP_3:
			_on_pick(2)
		elif k == KEY_Q:
			get_parent().reroll_choices()

func _on_pick(i: int) -> void:
	if not _panel.visible or i >= _pending.size():
		return
	var c: Dictionary = _pending[i]
	_panel.visible = false
	_pending = []
	var main: Node = get_parent()
	if main and main.has_method("apply_upgrade"):
		main.apply_upgrade(String(c["id"]))
