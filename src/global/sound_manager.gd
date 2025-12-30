extends Node

@onready var sound_effect: Node = $SoundEffect
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var rain_outside_loop: AudioStreamPlayer = $RainSoundEffect/RainOutsideLoop
@onready var rain_inside_loop: AudioStreamPlayer = $RainSoundEffect/RainInsideLoop

var loop_sfx: Dictionary[String, AudioStreamPlayer]

func _ready() -> void:
	for player: AudioStreamPlayer in sound_effect.get_children():
		player.bus = AudioServer.get_bus_name(Constant.Bus.SFX)
	rain_outside_loop.stream.loop = true
	rain_inside_loop.stream.loop = true
	

func play_sfx(sound_name: String) -> void:
	if not is_node_ready():
		return
	var player: AudioStreamPlayer = sound_effect.get_node_or_null(sound_name)
	if player == null:
		print("Sound \"%s\" not found" % sound_name)
		return
	if sound_name.ends_with("Loop"):
		loop_sfx[sound_name] = player
	player.play()

func stop_sfx(sound_name: String) -> void:
	var player: AudioStreamPlayer = sound_effect.get_node_or_null(sound_name)
	if player == null:
		return
	player.stop()

func stop_all_loop_sfx() -> void:
	for k: String in loop_sfx.keys():
		var player: AudioStreamPlayer = loop_sfx.get(k, null)
		if player == null:
			continue
		player.stop()
		loop_sfx.erase(k)
	stop_rain()

func play_bgm(stream: AudioStreamOggVorbis) -> void:
	if background_music.stream == stream:
		if background_music.playing:
			return
		background_music.stream_paused = false
	stream.loop = true
	background_music.stream = stream
	background_music.play()

func stop_bgm() -> void:
	if not is_node_ready():
		return
	background_music.stop()

# 夜晚时减小音量
func night_bgm(night: bool) -> void:
	if not is_node_ready():
		return
	if night and not Game.is_debugging:
		# 夜晚降低音量和声调
		background_music.volume_db = -10
		background_music.pitch_scale = 0.8
	else:
		background_music.volume_db = 0
		background_music.pitch_scale = 1

func play_rain(outside: bool) -> void:
	if outside:
		if not rain_outside_loop.playing:
			rain_outside_loop.play()
		rain_inside_loop.stop()
	else:
		if not rain_inside_loop.playing:
			rain_inside_loop.play()
		rain_outside_loop.stop()

func stop_rain() -> void:
	rain_outside_loop.stop()
	rain_inside_loop.stop()

func get_volume(bus_index: Constant.Bus) -> float:
	var db: float = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

func set_volume(bus_index: Constant.Bus, volume: float) -> void:
	var db: float = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db)
