extends Node
## AudioMan autoload: procedural sfx + looping guqin-ish bgm.

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _idx: int = 0
var _bgm: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)
	_bgm = AudioStreamPlayer.new()
	_bgm.bus = "Master"
	_bgm.volume_db = -10.0
	add_child(_bgm)
	for n in ["sword", "seal", "pickup", "levelup", "chest", "hit", "soul", "boss", "nuke"]:
		var path: String = "res://audio/%s.wav" % n
		if ResourceLoader.exists(path):
			_streams[n] = load(path)
	if ResourceLoader.exists("res://audio/bgm.wav"):
		var bgm_stream: AudioStream = load("res://audio/bgm.wav")
		if bgm_stream is AudioStreamWAV:
			(bgm_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		_bgm.stream = bgm_stream

func play(n: String, vol: float = 0.0) -> void:
	if not _streams.has(n):
		return
	var p: AudioStreamPlayer = _players[_idx]
	_idx = (_idx + 1) % _players.size()
	p.stream = _streams[n]
	p.volume_db = vol
	p.play()

func start_bgm() -> void:
	if _bgm.stream != null and not _bgm.playing:
		_bgm.play()

func stop_bgm() -> void:
	if _bgm.playing:
		_bgm.stop()
