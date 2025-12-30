extends ColorRect

var current_button: Node2D = null:
	set(v):
		if v == null:
			action_label.hide()
			size_container.hide()
		if current_button != null:
			# 如果之前有选中的按钮，重置其颜色
			current_button.modulate = Color.WHITE
		current_button = v
		if current_button != null:
			current_button.modulate = Color.YELLOW
			if current_button == joystick: # 虚拟摇杆是独立的设计
				action_label.text = "MOVE"
			else:
				action_label.text = InputManager.action_to_text(current_button.action_name, InputManager.Device.TOUCHSCREEN)
			action_label.show()
			size_slider.value = current_button.radius
			size_label.text = "%2d" % current_button.radius
			size_container.show()

@onready var option_container: VBoxContainer = $PanelContainer/HBoxContainer/OptionContainer
@onready var action_label: Label = $PanelContainer/HBoxContainer/OptionContainer/ActionLabel
@onready var size_container: HBoxContainer = $PanelContainer/HBoxContainer/OptionContainer/SizeContainer
@onready var size_slider: HSlider = $PanelContainer/HBoxContainer/OptionContainer/SizeContainer/SizeSlider
@onready var size_label: Label = $PanelContainer/HBoxContainer/OptionContainer/SizeContainer/SizeLabel
@onready var switch_button: Button = $PanelContainer/HBoxContainer/SwitchButton

@onready var joystick: Node2D = $JoyStick/Joystick

func _ready() -> void:
	refresh()
	for btn_editor: Node2D in get_tree().get_nodes_in_group("touch_button_editor"):
		btn_editor.selected.connect(_button_selected.bind(btn_editor))

func _input(event: InputEvent) -> void:
	if (not Util.is_touchscreen_platform()
		or not is_visible_in_tree()):
		return
	if event.is_action_pressed("ui_cancel"):
		_exit_editor()
		get_viewport().set_input_as_handled()

func _exit_editor() -> void:
	for btn_editor: Node2D in get_tree().get_nodes_in_group("touch_button_editor"):
		InputManager.set_touchscreen_layout(
			btn_editor.action_name,
			btn_editor.position,
			btn_editor.radius
		)
	if Game.get_game_scene() != null: # 在游戏中时恢复触控
		UIManager.touchscreen.try_show()
	hide()

func refresh() -> void:
	option_container.hide()
	action_label.hide()
	size_container.hide()
	for btn_editor: Node2D in get_tree().get_nodes_in_group("touch_button_editor"):
		btn_editor.modulate = Color.WHITE
		if btn_editor.action_name in InputManager.current_touchscreen_layout:
			var data: Dictionary = InputManager.current_touchscreen_layout[btn_editor.action_name]
			btn_editor.update(data.get("position", btn_editor.position),
				data.get("radius", btn_editor.radius))

func _button_selected(btn: Node2D) -> void:
	current_button = btn

func _on_reset_button_pressed() -> void:
	current_button = null
	for btn_editor: Node2D in get_tree().get_nodes_in_group("touch_button_editor"):
		btn_editor.modulate = Color.WHITE
		if btn_editor.action_name in InputManager.default_touchscreen_layout:
			var data: Dictionary = InputManager.default_touchscreen_layout[btn_editor.action_name]
			btn_editor.update(data.get("position", btn_editor.position),
				data.get("radius", btn_editor.radius))


func _on_switch_button_pressed() -> void:
	if option_container.visible:
		option_container.hide()
		switch_button.text = "→"
	else:
		option_container.show()
		switch_button.text = "←"

func _on_exit_button_pressed() -> void:
	_exit_editor()

func _on_size_slider_value_changed(value: float) -> void:
	size_label.text = "%2d" % value
	if current_button != null:
		if current_button.radius != value:
			current_button.radius = value
