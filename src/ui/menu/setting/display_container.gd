extends MenuContainer

@onready var fullscreen_check: CheckButton = $ContentContainer/FullscreenCheck
@onready var show_fps_check: CheckButton = $ContentContainer/ShowFPSCheck
@onready var refresh_rate_option: OptionButton = $ContentContainer/GridContainer/RefreshRateOption
@onready var filter_option: OptionButton = $ContentContainer/GridContainer/FilterOption

func _ready() -> void:
	super()
	Config.config_changed.connect(_handle_refresh_rate)
	Config.config_changed.connect(_handle_filter)

func refresh() -> void:
	if Util.is_web_platform():
		fullscreen_check.hide()
	fullscreen_check.button_pressed = Config.fullscreen
	show_fps_check.button_pressed = Config.show_fps
	_handle_refresh_rate("refresh_rate")
	_handle_filter("screen_filter")

func _handle_refresh_rate(config_name: StringName) -> void:
	if config_name != "refresh_rate":
		return
	match Config.refresh_rate:
		Config.REFRESH_RATE.SIXTY:
			refresh_rate_option.selected = 0
		Config.REFRESH_RATE.ONE_TWENTY:
			refresh_rate_option.selected = 1
		Config.REFRESH_RATE.VSYNC:
			refresh_rate_option.selected = 2
		Config.REFRESH_RATE.INFINITE:
			refresh_rate_option.selected = 3

func _handle_filter(config_name: StringName) -> void:
	if config_name != "screen_filter":
		return
	match Config.screen_filter:
		Config.ScreenFilter.NONE:
			filter_option.selected = 0
		Config.ScreenFilter.CRT:
			filter_option.selected = 1
		Config.ScreenFilter.GRAYSCALE:
			filter_option.selected = 2
		

func _on_fullscreen_check_focus_entered() -> void:
	change_message("SET_DISPLAY_FULLSCREEN_DESC")

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Config.fullscreen = toggled_on
	await get_tree().process_frame
	fullscreen_check.grab_focus.call_deferred()

func _on_performance_check_focus_entered() -> void:
	change_message("SET_DISPLAY_PERFORMANCE_DESC")


func _on_show_fps_check_focus_entered() -> void:
	change_message("SET_DISPLAY_SHOW_FPS_DESC")


func _on_show_fps_check_toggled(toggled_on: bool) -> void:
	Config.show_fps = toggled_on

func _on_refresh_rate_option_focus_entered() -> void:
	change_message("SET_DISPLAY_REFRESH_RATE_DESC")


func _on_refresh_rate_option_item_selected(index: int) -> void:
	match index:
		0: # 60 FPS
			Config.refresh_rate = Config.REFRESH_RATE.SIXTY
		1: # 120 FPS
			Config.refresh_rate = Config.REFRESH_RATE.ONE_TWENTY
		2: # VSYNC
			Config.refresh_rate = Config.REFRESH_RATE.VSYNC
		3: # INFINITE
			Config.refresh_rate = Config.REFRESH_RATE.INFINITE


func _on_filter_option_focus_entered() -> void:
	change_message("SET_DISPLAY_FILTER_DESC")

func _on_filter_option_item_selected(index: int) -> void:
	match index:
		0: # NONE
			Config.screen_filter = Config.ScreenFilter.NONE
		1: # CRT
			Config.screen_filter = Config.ScreenFilter.CRT
		2: # GRAYSCALE
			Config.screen_filter = Config.ScreenFilter.GRAYSCALE
