extends Control

@onready var joystick: Node2D = $Button/Move/Joystick

func _ready() -> void:
	hide()
	InputManager.layout_changed.connect(update.bind(InputManager.current_touchscreen_layout))

func update(data: Dictionary) -> void:
	for touch_btn: TouchScreenButton in get_tree().get_nodes_in_group("touch_button"):
		if touch_btn.action_name in data:
			touch_btn.update(
				data[touch_btn.action_name].get("position", touch_btn.position),
				data[touch_btn.action_name].get("radius", touch_btn.radius)
			)
	# 单独处理虚拟摇杆
	if data.get("move", null) != null:
		joystick.update(
			data["move"].get("position", joystick.position),
			data["move"].get("radius", joystick.radius)
		)


func try_show() -> void:
	if Util.is_touchscreen_platform():
		show()

func highlight(action_name: StringName) -> void:
	match action_name:
		"move_left", "move_right", "drop":
			joystick.modulate = Color.YELLOW
		_:
			for touch_btn: TouchScreenButton in get_tree().get_nodes_in_group("touch_button"):
				if touch_btn.action_name == action_name:
					touch_btn.modulate = Color.YELLOW
					break
