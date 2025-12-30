extends Button

const WAIT_TIME: int = 9

## 是否允许更改
@export var can_change: bool = true
## 绑定的动作
@export var action: StringName = ""
## 绑定的设备
@export var device: InputManager.Device = InputManager.Device.KEYBOARD_AND_MOUSE

var wait_time: int = WAIT_TIME
var wait_input: bool = false

@onready var wait_timer: Timer = $WaitTimer

func _ready() -> void:
	reset_display()

# 重置显示
func reset_display() -> void:
	disabled = true
	text = InputManager.action_to_text(action, device)
	await get_tree().create_timer(1).timeout
	if can_change:
		disabled = false

func _on_pressed() -> void:
	text = "[%d]%s" % [wait_time, tr("SET_KEY_BINDING")]
	wait_time = WAIT_TIME
	wait_input = true
	wait_timer.start()
	
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if wait_input:
		if not event.is_echo():
			match device:
				InputManager.Device.KEYBOARD_AND_MOUSE:
					if (event is InputEventKey
						or (event is InputEventMouseButton
						and not Util.is_touchscreen_platform())):
						_bind_new_key(event)	
				InputManager.Device.JOYPAD:
					if (event is InputEventJoypadButton
						or event is InputEventJoypadMotion):
						_bind_new_key(event)
		get_viewport().set_input_as_handled()

func _bind_new_key(input: InputEvent) -> void:
	if InputManager.set_action_binding(action, input) == OK:
		reset_display()
		wait_input = false
		wait_timer.stop()
		wait_time = WAIT_TIME

func _on_mouse_entered() -> void:
	grab_focus.call_deferred()


func _on_wait_timer_timeout() -> void:
	wait_time -= 1
	text = "[%d]%s" % [wait_time, tr("SET_KEY_BINDING")]
	if wait_time <= 0:
		wait_input = false
		wait_timer.stop()
		reset_display()
