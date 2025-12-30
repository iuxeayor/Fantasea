extends Button

@export var action: StringName = ""
@export var no_text: bool = false ## 不显示文字

func _ready() -> void:
	InputManager.device_changed.connect(update)
	InputManager.action_bound.connect(update)
	update()

func update() -> void:
	if action == "" or no_text:
		return
	text = InputManager.action_to_text(action)

func _on_pressed() -> void:
	if action == "":
		return

func _on_button_down() -> void:
	if action == "":
		return
	InputManager.trigger_input(action, true)


func _on_button_up() -> void:
	if action == "":
		return
	InputManager.trigger_input(action, false)
