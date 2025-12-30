extends Control
class_name MenuScreen

var message_tween: Tween = null

var current_menu: Constant.GameMenu = Constant.GameMenu.SETTING:
	set(v):
		current_menu = v
		if not is_node_ready():
			return
		main_container.scroll_vertical = 0
		for container: MenuContainer in get_tree().get_nodes_in_group("menu_container"):
			if container.menu_id == current_menu:
				# 刷新标题
				if current_menu == Constant.GameMenu.IN_GAME:
					# 游戏中显示场景名
					if Game.get_game_scene() != null:
						title_label.text = tr(Game.get_game_scene().scene_name)
				else:
					title_label.text = tr(container.title)
				container.opening = true
			else:
				container.opening = false
		
				
var opening: bool = false:
	set(v):
		opening = v
		if opening:
			get_tree().paused = true
			show()
			return_button.grab_focus.call_deferred()
		else:
			current_menu = Constant.GameMenu.NONE
			hide()
			get_tree().paused = false
			if UIManager.focusing != null:
				UIManager.focusing.grab_focus.call_deferred()

@onready var return_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/ReturnButton
@onready var title_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/TitleLabel
@onready var message_label: RichTextLabel = $PanelContainer/VBoxContainer/ContentContainer/MessageLabel
@onready var main_container: ScrollContainer = $PanelContainer/VBoxContainer/ContentContainer/MainContainer
@onready var setting_container: MenuContainer = $PanelContainer/VBoxContainer/ContentContainer/MainContainer/HBoxContainer/SubMenus/SettingContainer
@onready var touch_scroll: NinePatchRect = $PanelContainer/VBoxContainer/ContentContainer/MainContainer/HBoxContainer/TouchScroll

func _ready() -> void:
	Config.config_changed.connect(func(config_name: StringName) -> void:
		if config_name != "language":
			return
		if current_menu == Constant.GameMenu.SETTING:
			title_label.text = tr("TITLE_SETTING")
		)
	for option: Control in get_tree().get_nodes_in_group("menu_option"):
		option.mouse_entered.connect(option.grab_focus)
		option.focus_entered.connect(SoundManager.play_sfx.bind("MenuFocus"))
		if option is Button:
			option.pressed.connect(SoundManager.play_sfx.bind("MenuPress"))
	for container: MenuContainer in get_tree().get_nodes_in_group("menu_container"):
		container.message_changed.connect(_change_message)
		container.menu_change_to.connect(func(menu: Constant.GameMenu) -> void:
			current_menu = menu
			)
	return_button.grab_focus.call_deferred()
	touch_scroll.visible = Util.is_touchscreen_platform()

func _change_message(msg: String) -> void:
	message_label.text = tr(msg)
	message_label.visible_characters = 0
	if message_tween != null and message_tween.is_running():
		message_tween.kill()
	message_tween = create_tween()
	var time: float = max(message_label.text.length() / float(Util.get_char_per_second()), 0.1)
	message_tween.tween_property(message_label, "visible_characters", message_label.text.length(), time)

func _on_return_button_pressed() -> void:
	match current_menu:
		Constant.GameMenu.IN_GAME:
			opening = false
		Constant.GameMenu.SETTING:
			Config.store_config()
			if get_tree().current_scene is Scene:
				# 游戏中回到游戏菜单
				current_menu = Constant.GameMenu.IN_GAME
			else:
				# 非游戏中即在主菜单，直接关闭菜单
				opening = false
		_:
			if get_tree().current_scene is Scene:
				# 游戏中回到游戏菜单
				current_menu = Constant.GameMenu.IN_GAME
			else:
				opening = false
		

func _unhandled_input(event: InputEvent) -> void:
	if opening:
		get_viewport().set_input_as_handled()
		if event.is_action_pressed("ui_cancel"):
			if get_viewport().gui_get_focus_owner() == return_button:
				_on_return_button_pressed()
			else:
				return_button.grab_focus.call_deferred()
		

func _on_return_button_focus_entered() -> void:
	_change_message("")
