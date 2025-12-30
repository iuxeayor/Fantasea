extends MenuContainer

@onready var reset_button: Button = $ContentContainer/ResetButton
@onready var touch_screen_edit_button: Button = $ContentContainer/TouchScreenEditButton

func _ready() -> void:
	super()
	for key_btn: Button in get_tree().get_nodes_in_group("key_bind_button"):
		key_btn.focus_entered.connect(change_message.bind("SET_KEY_BIND_DESC"))

func refresh() -> void:
	for key_btn: Button in get_tree().get_nodes_in_group("key_bind_button"):
		key_btn.reset_display()
	touch_screen_edit_button.visible = Util.is_touchscreen_platform()

func _on_reset_button_focus_entered() -> void:
	change_message("SET_KEY_RESET_DESC")


func _on_reset_button_pressed() -> void:
	for action: String in InputManager.default_actions:
		InputManager.load_action(action, str(InputManager.default_actions[action]))
	for opt in get_tree().get_nodes_in_group("key_bind_button"):
		opt.reset_display()

func _on_touch_screen_edit_button_focus_entered() -> void:
	change_message("SET_TOUCHSCREEN_DESC")


func _on_touch_screen_edit_button_pressed() -> void:
	UIManager.touchscreen.hide() # 防止误触
	UIManager.touchscreen_editor.refresh()
	UIManager.touchscreen_editor.show()
