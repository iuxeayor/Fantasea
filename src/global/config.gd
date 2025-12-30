extends Node

const CONFIG_PATH: String = "user://config.ini"
const DEFAULT_VOLUME: float = 0.5

enum REFRESH_RATE {
	SIXTY,
	ONE_TWENTY,
	VSYNC,
	INFINITE,
}

enum ScreenFilter {
	NONE,
	CRT,
	GRAYSCALE,
}

signal config_changed(name: StringName)

# 分辨率
var window_sizes: Array[Vector2i] = [
	Vector2i(3840, 2160), # 4K UHD
	Vector2i(3200, 1800), # QHD+
	Vector2i(2560, 1440), # QHD
	Vector2i(1920, 1080), # Full HD
	Vector2i(1600, 900), # HD+
	Vector2i(1366, 768), # FWXGA
	Vector2i(1280, 720), # HD
	Vector2i(1024, 576), # WSVGA
	Vector2i(960, 540), # qHD
	Vector2i(854, 480), # FWVGA
	Vector2i(640, 360), # nHD
	Vector2i(448, 252), # 游戏本身分辨率
	Vector2i(180, 64), # 已验证的最小分辨率
]

# 辅助
var game_speed: float = 1.0: # 游戏速度
	set(v):
		game_speed = clampf(v, 0.5, 1.0)
		Engine.time_scale = game_speed
var easy_mode: bool = false # 简单模式
var auto_attack: bool = false # 按住自动攻击
var close_shake: bool = false: # 停止屏幕震动
	set(v):
		close_shake = v
		config_changed.emit("close_shake")

# 音频
var master_volume: float = DEFAULT_VOLUME: # 主音量
	set(v):
		master_volume = clampf(v, 0, 1)
		SoundManager.set_volume(Constant.Bus.MASTER, v)
var sfx_volume: float = DEFAULT_VOLUME: # 音效音量
	set(v):
		sfx_volume = clampf(v, 0, 1)
		SoundManager.set_volume(Constant.Bus.SFX, v)
var bgm_volume: float = DEFAULT_VOLUME: # 背景音乐音量
	set(v):
		bgm_volume = clampf(v, 0, 1)
		SoundManager.set_volume(Constant.Bus.BGM, v)

# 显示
var fullscreen: bool = false: # 全屏
	set(v):
		if Util.is_web_platform():
			return
		fullscreen = v
		if v:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			# 最大化bug，适用于Windows，未复现，但是保留记录
			# https://github.com/godotengine/godot/issues/70166
			# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			set_windowed()

var show_fps: bool = false: # 显示FPS
	set(v):
		show_fps = v
		config_changed.emit("show_fps")
	
var refresh_rate: REFRESH_RATE = REFRESH_RATE.VSYNC: # 帧率
	set(v):
		refresh_rate = v
		# 默认240的物理帧率，在低性能设备上表现不佳
		# 物理帧率低于显示帧率时会导致画面不流畅，因此，将物理帧率与显示帧率绑定，允许玩家根据需求选择
		match refresh_rate:
			REFRESH_RATE.SIXTY: # 大部分低性能设备，办公显示器
				Engine.max_fps = 60
				Engine.physics_ticks_per_second = 60
				Engine.max_physics_steps_per_frame = 8
				DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
			REFRESH_RATE.ONE_TWENTY: # 主流设备，高刷手机
				Engine.max_fps = 120
				Engine.physics_ticks_per_second = 120
				Engine.max_physics_steps_per_frame = 16
				DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
			REFRESH_RATE.VSYNC: 	# 基于用户显示器
				Engine.max_fps = 0
				Engine.physics_ticks_per_second = 240
				Engine.max_physics_steps_per_frame = 32
				DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ADAPTIVE)
			REFRESH_RATE.INFINITE:
				Engine.max_fps = 0
				Engine.physics_ticks_per_second = 240
				Engine.max_physics_steps_per_frame = 32
				DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
		config_changed.emit("frame_rate")

var screen_filter: ScreenFilter = ScreenFilter.NONE: # 屏幕滤镜
	set(v):
		screen_filter = v			
		config_changed.emit("screen_filter")

func _ready() -> void:
	game_speed = Engine.time_scale
	fullscreen = false

	
func store_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	# 语言
	config.set_value("locale", "language", TranslationServer.get_locale())
	# 辅助功能
	config.set_value("assist", "game_speed", game_speed)
	config.set_value("assist", "easy_mode", easy_mode)
	config.set_value("assist", "auto_attack", auto_attack)
	config.set_value("assist", "close_shake", close_shake)
	# 音频
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("audio", "bgm", bgm_volume)
	# 显示
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "show_fps", show_fps)
	config.set_value("display", "refresh_rate", refresh_rate)
	config.set_value("display", "screen_filter", screen_filter)
	# 键位
	for action: StringName in InputMap.get_actions():
		if InputManager.default_actions.has(action):
			config.set_value("input", action, InputManager.action_to_dict(action))
	# 布局
	for action: StringName in InputManager.current_touchscreen_layout:
		config.set_value("touchscreen", action, InputManager.action_to_layout_dict(action))
	config.save(CONFIG_PATH)


func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		# 没有配置，根据系统语言设置游戏语言
		set_language(OS.get_locale())
		# 音频，默认为50%
		master_volume = DEFAULT_VOLUME
		sfx_volume = DEFAULT_VOLUME
		bgm_volume = DEFAULT_VOLUME
	# 语言
	set_language(Util.get_value_from_config(config, "locale", "language", TranslationServer.get_locale()))
	# 辅助功能
	easy_mode = Util.get_value_from_config(config, "assist", "easy_mode", false)
	game_speed = Util.get_value_from_config(config, "assist", "game_speed", 1.0)
	auto_attack = Util.get_value_from_config(config, "assist", "auto_attack", false)
	close_shake = Util.get_value_from_config(config, "assist", "close_shake", false)
	# 音频，默认为50%
	master_volume = Util.get_value_from_config(config, "audio", "master", DEFAULT_VOLUME)
	sfx_volume = Util.get_value_from_config(config, "audio", "sfx", DEFAULT_VOLUME)
	bgm_volume = Util.get_value_from_config(config, "audio", "bgm", DEFAULT_VOLUME)
	# 显示
	fullscreen = Util.get_value_from_config(config, "display", "fullscreen", false)
	show_fps = Util.get_value_from_config(config, "display", "show_fps", false)
	refresh_rate = Util.get_value_from_config(config, "display", "refresh_rate", REFRESH_RATE.VSYNC)
	screen_filter = Util.get_value_from_config(config, "display", "screen_filter", ScreenFilter.NONE)
	# 键位
	for action: StringName in InputMap.get_actions():
		if InputManager.default_actions.has(action):
			InputManager.load_action(action, Util.get_value_from_config(config, "input", action, ""))
	# 触屏布局
	for action: StringName in InputManager.default_touchscreen_layout:
		InputManager.load_touchscreen_layout(
			action,
			Util.get_value_from_config(config, "touchscreen", action, "")
		)

# 语言设置
func set_language(locale: String) -> void:
	var lang: PackedStringArray = locale.split("_")
	if lang.size() < 1:
		TranslationServer.set_locale("en")
	else:
		match lang[0]:
			"zh":
				if lang.size() > 1:
					match lang[1]:
						"HK", "MO", "TW": # 港澳台使用繁体中文
							TranslationServer.set_locale("zh_HK")
						_:
							TranslationServer.set_locale("zh_CN")
				else:
					TranslationServer.set_locale("zh_CN")
			"en":
				TranslationServer.set_locale("en")
			_:
				TranslationServer.set_locale("en") # 默认英语
	config_changed.emit("language")
	

func set_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	for size: Vector2i in window_sizes:
		if size < DisplayServer.screen_get_size():
			DisplayServer.window_set_size(size)
			break
	# 居中临时方案
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var screen_position: Vector2i = DisplayServer.screen_get_position()
	var window_size: Vector2i = DisplayServer.window_get_size()
	var window_position: Vector2i = screen_position + (screen_size - window_size) / 2
	DisplayServer.window_set_position(window_position)
