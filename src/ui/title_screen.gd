extends Control

@export var bgm: AudioStreamOggVorbis = null

@onready var options: VBoxContainer = $HBoxContainer/VBoxContainer/PanelContainer/Options
@onready var continue_btn: Button = $HBoxContainer/VBoxContainer/PanelContainer/Options/Continue
@onready var new_game_btn: Button = $HBoxContainer/VBoxContainer/PanelContainer/Options/NewGame
@onready var setting_btn: Button = $HBoxContainer/VBoxContainer/PanelContainer/Options/Setting
@onready var copyright: Label = $Copyright

@onready var forest_background: CanvasLayer = $Background/Forest
@onready var island_background: CanvasLayer = $Background/Island
@onready var snowfield_background: CanvasLayer = $Background/Snowfield
@onready var desert_background: CanvasLayer = $Background/Desert
@onready var cave_background: CanvasLayer = $Background/Cave
@onready var ship_background: CanvasLayer = $Background/Ship

func _ready() -> void:
	SoundManager.stop_bgm()
	SoundManager.stop_all_loop_sfx()
	SoundManager.night_bgm(false)
	UIManager.touchscreen.hide()   
	Status.reset_status()
	copyright.text = "V%d.%d.%d open" % Game.VERSION
	continue_btn.disabled = not Util.is_has_save_file() # 有存档文件则启用继续游戏按钮
	# 鼠标移动到时切换焦点
	for opt in options.get_children():
		if opt is Button:
			opt.mouse_entered.connect(opt.grab_focus)
			opt.focus_entered.connect(SoundManager.play_sfx.bind("MenuFocus"))
			opt.focus_entered.connect(func() -> void:
				UIManager.focusing = opt
			)
			opt.pressed.connect(SoundManager.play_sfx.bind("MenuPress"))
	SoundManager.play_bgm(bgm)
	_change_theme_by_save_file()
	if continue_btn.disabled:
		new_game_btn.grab_focus.call_deferred()
	else:
		continue_btn.grab_focus.call_deferred()
	UIManager.special_effect.cover_out()
	UIManager.special_effect.fade_out(0)
	UIManager.special_effect.movie_out(0)
	
func _change_theme_by_save_file() -> void:
	# 隐藏所有背景
	forest_background.hide()
	island_background.hide()
	snowfield_background.hide()
	desert_background.hide()
	cave_background.hide()
	ship_background.hide()
	# 读取存档，找到保存时期最新的存档，获取它的场景
	var save_names: Array[String] = ["save0", "save1", "save2", "save3", "save4"]
	var current_max_time: int = 0
	var scene_env: Constant.SceneEnvironment = Constant.SceneEnvironment.FOREST
	for save_name: String in save_names:
		var save: ConfigFile = ConfigFile.new()
		if save.load(Game.SAVE_PATH % save_name) == OK:
			var save_time_unix: int = Util.get_value_from_config(save, "system", "time", 0)
			if save_time_unix > current_max_time:
				current_max_time = save_time_unix
				scene_env = Util.get_value_from_config(save, "status", "scene_environment", Constant.SceneEnvironment.FOREST)
	theme = UIManager.get_scene_theme(scene_env)
	# 修补森林主题，因为默认空主题是岛屿主题，但是游戏标题会使用森林主题
	var is_forest: bool = false 
	match scene_env:
		Constant.SceneEnvironment.FOREST:
			forest_background.show()
			is_forest = true
		Constant.SceneEnvironment.ISLAND:
			island_background.show()
		Constant.SceneEnvironment.SNOWFIELD:
			snowfield_background.show()
		Constant.SceneEnvironment.DESERT:
			desert_background.show()
		Constant.SceneEnvironment.CAVE:
			cave_background.show()
		Constant.SceneEnvironment.SHIP:
			ship_background.show()
		_:
			forest_background.show()
			theme = UIManager.MENU_THEME_FOREST
			is_forest = true
	if is_forest:
		UIManager.change_theme_by_scene(Constant.SceneEnvironment.FOREST)
	else:
		UIManager.change_theme_by_scene(scene_env)

func _on_continue_pressed() -> void:
	get_tree().paused = true
	UIManager.menu_screen.opening = true
	UIManager.menu_screen.current_menu = Constant.GameMenu.LOAD_SAVE

func _on_new_game_pressed() -> void:
	get_tree().paused = true
	UIManager.menu_screen.opening = true
	UIManager.menu_screen.current_menu = Constant.GameMenu.NEW_GAME

func _on_setting_pressed() -> void:
	get_tree().paused = true
	UIManager.menu_screen.opening = true
	UIManager.menu_screen.current_menu = Constant.GameMenu.SETTING
	
func _on_exit_pressed() -> void:
	if Util.is_web_platform():
		JavaScriptBridge.eval("location.reload()")
	else:
		get_tree().quit()


func _on_discord_pressed() -> void:
	OS.shell_open("https://github.com/iuxeayor/Fantasea")


func _on_steam_pressed() -> void:
	OS.shell_open("https://github.com/iuxeayor/Fantasea")


func _on_itch_pressed() -> void:
	OS.shell_open("https://github.com/iuxeayor/Fantasea")


func _on_qq_pressed() -> void:
	OS.shell_open("https://github.com/iuxeayor/Fantasea")
