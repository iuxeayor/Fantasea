extends Node

enum Device {
	INVALID,
	KEYBOARD_AND_MOUSE,
	JOYPAD,
	TOUCHSCREEN,
}

signal device_changed
signal action_bound
signal layout_changed

# 游戏动作默认值
var default_actions: Dictionary[StringName, Dictionary] = {
	"move_left": {
		"key": {
			"keyboard": KEY_A,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_INVALID,
			"axis": JOY_AXIS_LEFT_X,
			"direction": - 1,
		},
	},
	"move_right": {
		"key": {
			"keyboard": KEY_D,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_INVALID,
			"axis": JOY_AXIS_LEFT_X,
			"direction": 1,
		},
	},
	"interact": {
		"key": {
			"keyboard": KEY_W,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_Y,
			"axis": JOY_AXIS_INVALID,
			"direction": 0,
		},
	},
	"drop": {
		"key": {
			"keyboard": KEY_S,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_INVALID,
			"axis": JOY_AXIS_LEFT_Y,
			"direction": 1,
		},
	},
	"jump": {
		"key": {
			"keyboard": KEY_SPACE,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_RIGHT_SHOULDER,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"attack": {
		"key": {
			"keyboard": KEY_J,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_X,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"shoot": {
		"key": {
			"keyboard": KEY_K,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_A,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"throw": {
		"key": {
			"keyboard": KEY_I,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_Y,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"heal": {
		"key": {
			"keyboard": KEY_L,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_B,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"dash": {
		"key": {
			"keyboard": KEY_CTRL,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_LEFT_SHOULDER,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"inventory": {
		"key": {
			"keyboard": KEY_TAB,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_START,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_left": {
		"key": {
			"keyboard": KEY_LEFT,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_DPAD_LEFT,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_right": {
		"key": {
			"keyboard": KEY_RIGHT,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_DPAD_RIGHT,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_up": {
		"key": {
			"keyboard": KEY_UP,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_DPAD_UP,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_down": {
		"key": {
			"keyboard": KEY_DOWN,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_DPAD_DOWN,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_accept": {
		"key": {
			"keyboard": KEY_SPACE,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_A,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
	"ui_cancel": {
		"key": {
			"keyboard": KEY_ESCAPE,
			"mouse": MOUSE_BUTTON_NONE
		},
		"joypad": {
			"button": JOY_BUTTON_B,
			"axis": JOY_AXIS_INVALID,
			"direction": 0.0,
		},
	},
}

# 默认触摸屏布局
var default_touchscreen_layout: Dictionary[StringName, Dictionary] = {
	# 移动，虚拟摇杆
	"move": {
		"position": Vector2(48, -48),
		"radius": 32,
	},
	# 菜单
	"menu": {
		"position": Vector2(-16, 16),
		"radius": 8,
	},
	"inventory": {
		"position": Vector2(-16, 40),
		"radius": 8,
	},
	"interact": {
		"position": Vector2(-16, 64),
		"radius": 8,
	},
	# 动作
	"jump": {
		"position": Vector2(-32, -32),
		"radius": 16,
	},
	"attack": {
		"position": Vector2(-56, -56),
		"radius": 16,
	},
	"shoot": {
		"position": Vector2(-24, -64),
		"radius": 12,
	},
	"throw": {
		"position": Vector2(-88, -40),
		"radius": 12,
	},
	"heal": {
		"position": Vector2(-104, -16),
		"radius": 12,
	},
	"dash": {
		"position": Vector2(-64, -24),
		"radius": 12,
	},
}

# 当前触摸屏布局
var current_touchscreen_layout: Dictionary[StringName, Dictionary] = {
	# 移动，虚拟摇杆
	"move": {
		"position": Vector2(48, -48),
		"radius": 32,
	},
	# 菜单
	"menu": {
		"position": Vector2(-16, 16),
		"radius": 8,
	},
	"inventory": {
		"position": Vector2(-16, 40),
		"radius": 8,
	},
	"interact": {
		"position": Vector2(-16, 64),
		"radius": 8,
	},
	# 动作
	"jump": {
		"position": Vector2(-32, -32),
		"radius": 16,
	},
	"attack": {
		"position": Vector2(-56, -56),
		"radius": 16,
	},
	"shoot": {
		"position": Vector2(-24, -64),
		"radius": 12,
	},
	"throw": {
		"position": Vector2(-88, -40),
		"radius": 12,
	},
	"heal": {
		"position": Vector2(-104, -16),
		"radius": 12,
	},
	"dash": {
		"position": Vector2(-64, -24),
		"radius": 12,
	},
}

var disabled: bool = false # 取消控制
var current_device: Device = Device.KEYBOARD_AND_MOUSE: # 当前输入设备
	set(v):
		if current_device != v:
			current_device = v
			device_changed.emit()


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventScreenTouch:
			current_device = Device.TOUCHSCREEN
		elif event is InputEventKey or (
			# 触摸屏会模拟鼠标点击事件导致识别为键鼠，因此在触摸屏上不处理鼠标事件
			 event is InputEventMouseButton
			 and not Util.is_touchscreen_platform()):
			current_device = Device.KEYBOARD_AND_MOUSE
		elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
			current_device = Device.JOYPAD

# Input.is_action_just_pressed的封装
func is_action_just_pressed(action: String, override_disable: bool = false) -> bool:
	if disabled and not override_disable:
		return false
	return Input.is_action_just_pressed(action)

# Input.is_action_pressed的封装
func is_action_pressed(action: String, override_disable: bool = false) -> bool:
	if disabled and not override_disable:
		return false
	return Input.is_action_pressed(action)

# Input.is_action_just_released的封装
func is_action_just_released(action: String, override_disable: bool = false) -> bool:
	if disabled and not override_disable:
		return false
	return Input.is_action_just_released(action)

# Input.get_axis的封装
func get_axis(negative_action: String, positive_action: String, override_disable: bool = false) -> float:
	if disabled and not override_disable:
		return 0
	return Input.get_axis(negative_action, positive_action)

# 读取键位
func load_action(action: String, data_string: String) -> void:
	if data_string == "":
		return
	var json: JSON = JSON.new()
	if json.parse(data_string) != OK:
		return
	var dict: Dictionary = json.data
	# 尝试读取键位，如果失败则使用默认键位
	var action_keyboard_mouse: InputEvent = dict_to_keyboard_mouse_event(dict)
	if action_keyboard_mouse == null:
		action_keyboard_mouse = dict_to_keyboard_mouse_event(default_actions[action])
	set_action_binding(action, action_keyboard_mouse)
	var action_joypad: InputEvent = dict_to_joypad_event(dict)
	if action_joypad == null:
		action_joypad = dict_to_joypad_event(default_actions[action])
	set_action_binding(action, action_joypad)

# 键位转换为字典
func action_to_dict(action: StringName) -> String:
	var result: Dictionary[StringName, Dictionary] = {
		"key": {"keyboard": KEY_NONE, "mouse": MOUSE_BUTTON_NONE},
		"joypad": {"button": JOY_BUTTON_INVALID, "axis": JOY_AXIS_INVALID, "direction": 0},
	}
	if InputMap.has_action(action):
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				result["key"]["keyboard"] = event.physical_keycode
			elif event is InputEventMouseButton:
				result["key"]["mouse"] = event.button_index
			elif event is InputEventJoypadButton:
				result["joypad"]["button"] = event.button_index
			elif event is InputEventJoypadMotion:
				result["joypad"]["axis"] = event.axis
				result["joypad"]["direction"] = event.axis_value
	return JSON.stringify(result)

# 转换键鼠键位
func dict_to_keyboard_mouse_event(dict: Dictionary) -> InputEvent:
	var result: InputEvent = null
	if dict.get("key", null) != null:
		if dict["key"].get("keyboard", KEY_NONE) != KEY_NONE:
			result = InputEventKey.new()
			result.physical_keycode = dict["key"].get("keyboard", KEY_NONE)
		elif dict["key"].get("mouse") != MOUSE_BUTTON_NONE:
			result = InputEventMouseButton.new()
			result.button_index = dict["key"].get("mouse", MOUSE_BUTTON_NONE)
	return result

# 转换手柄键位
func dict_to_joypad_event(dict: Dictionary) -> InputEvent:
	var result: InputEvent = null
	if dict.get("joypad", null) != null:
		if dict["joypad"].get("button", JOY_BUTTON_INVALID) != JOY_BUTTON_INVALID:
			result = InputEventJoypadButton.new()
			result.button_index = dict["joypad"].get("button", JOY_BUTTON_INVALID)
		elif dict["joypad"].get("axis", JOY_AXIS_INVALID) != JOY_AXIS_INVALID:
			result = InputEventJoypadMotion.new()
			result.axis = dict["joypad"].get("axis", JOY_AXIS_INVALID)
			result.axis_value = dict["joypad"].get("direction", 0)
	return result

# 将键鼠按键转换为文本
func event_to_text(event: InputEvent) -> String:
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_LEFT:
				return "←"
			KEY_UP:
				return "↑"
			KEY_RIGHT:
				return "→"
			KEY_DOWN:
				return "↓"
			_:
				var result: String = event.as_text()
				if result.split(" (").size() > 1:
					result = result.split(" (")[0]
				return result
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				return "LMB"
			MOUSE_BUTTON_RIGHT:
				return "RMB"
			MOUSE_BUTTON_MIDDLE:
				return "MMB"
			MOUSE_BUTTON_WHEEL_UP:
				return "MW↑"
			MOUSE_BUTTON_WHEEL_DOWN:
				return "MW↓"
			_:
				var result: String = event.as_text()
				if result.split(" (").size() > 1:
					result = result.split(" (")[0]
				return result
	elif event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_A:
				return "Ⓐ/ⓧ/Ⓑ"
			JOY_BUTTON_B:
				return "Ⓑ/ⓞ/Ⓐ"
			JOY_BUTTON_X:
				return "Ⓧ/ⓢ/Ⓨ"
			JOY_BUTTON_Y:
				return "Ⓨ/ⓣ/Ⓧ"
			JOY_BUTTON_BACK:
				return "Back/Select/-"
			JOY_BUTTON_GUIDE:
				return "Home"
			JOY_BUTTON_START:
				return "Menu/Options/+"
			JOY_BUTTON_LEFT_STICK:
				return "LS/L3"
			JOY_BUTTON_RIGHT_STICK:
				return "RS/R3"
			JOY_BUTTON_LEFT_SHOULDER:
				return "LB/L1"
			JOY_BUTTON_RIGHT_SHOULDER:
				return "RB/R1"
			JOY_BUTTON_DPAD_UP:
				return "↑"
			JOY_BUTTON_DPAD_DOWN:
				return "↓"
			JOY_BUTTON_DPAD_LEFT:
				return "←"
			JOY_BUTTON_DPAD_RIGHT:
				return "→"
			JOY_BUTTON_MISC1:
				return "Share/Mic/Screenshot"
			_:
				var result: String = event.as_text()
				# 没有平台信息
				if result.split(" (").size() < 2:
					return result
				# 有平台信息
				result = result.split(" (")[1].split(")")[0].replace(", ", "/")
				return result
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X:
				if event.axis_value > 0:
					return "LS→"
				elif event.axis_value < 0:
					return "LS←"
				else:
					return "LS"
			JOY_AXIS_LEFT_Y:
				if event.axis_value > 0:
					return "LS↓"
				elif event.axis_value < 0:
					return "LS↑"
				else:
					return "LS"
			JOY_AXIS_RIGHT_X:
				if event.axis_value > 0:
					return "RS→"
				elif event.axis_value < 0:
					return "RS←"
				else:
					return "RS"
			JOY_AXIS_RIGHT_Y:
				if event.axis_value > 0:
					return "RS↓"
				elif event.axis_value < 0:
					return "RS↑"
				else:
					return "RS"
			JOY_AXIS_TRIGGER_LEFT:
				return "LT"
			JOY_AXIS_TRIGGER_RIGHT:
				return "RT"
			_:
				var result: String = event.as_text()
				# 没有平台信息
				if result.split(" (").size() < 2:
					return result
				# 有平台信息
				result = result.split(" (")[1].split(")")[0].replace(", ", "/")
				return result
	return event.as_text()

# 返回动作在两种输入设备上的文本
# 键鼠手柄
func action_to_text(action: StringName, device: Device = Device.INVALID) -> String:
	if device == Device.INVALID:
		device = current_device
	if InputMap.has_action(action):
		# 触摸屏没有指定的按键，返回动作名称本身
		if device == Device.TOUCHSCREEN:
			return action.to_upper().replace("_", " ")
		var keyboard_mouse_text: String = ""
		var joypad_text: String = ""
		for event in InputMap.action_get_events(action):
			if event is InputEventKey or event is InputEventMouseButton:
				keyboard_mouse_text = event_to_text(event)
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				joypad_text = event_to_text(event)
		match device:
			Device.KEYBOARD_AND_MOUSE:
				return keyboard_mouse_text
			Device.JOYPAD:
				return joypad_text
	return ""

# 设置键位
func set_action_binding(action: StringName, input: InputEvent) -> Error:
	if not InputMap.has_action(action):
		return FAILED
	# 保留已有的按键
	var action_keyboard_mouse: InputEvent = null
	var action_joypad: InputEvent = null
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for e: InputEvent in events:
		if e is InputEventKey or e is InputEventMouseButton:
			action_keyboard_mouse = e
		elif e is InputEventJoypadButton or e is InputEventJoypadMotion:
			action_joypad = e
	# 判断输入
	if (input is InputEventKey
		or input is InputEventMouseButton):
		action_keyboard_mouse = input
	elif input is InputEventJoypadButton:
		action_joypad = input
	elif input is InputEventJoypadMotion: # 摇杆需要处理力度
		if abs(input.axis_value) < 0.5: # 死区判断
			return FAILED
		# 力度转换到1或-1
		if input.axis_value > 0:
			input.axis_value = 1
		elif input.axis_value < 0:
			input.axis_value = -1
		action_joypad = input
	if (action_keyboard_mouse != null
		or action_joypad != null):
		InputMap.action_erase_events(action)
		if action_keyboard_mouse != null:
			InputMap.action_add_event(action, action_keyboard_mouse)
		if action_joypad != null:
			InputMap.action_add_event(action, action_joypad)
		action_bound.emit()
		return OK
	return FAILED

func trigger_input(action: StringName, pressed: bool) -> void:
	var event: InputEvent = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)

func trigger_input_one_time(action: StringName) -> void:
	trigger_input(action, true)
	trigger_input.call_deferred(action, false)

func set_touchscreen_layout(action: StringName, pos: Vector2, radius: float) -> void:
	current_touchscreen_layout[action] = {
		"position": pos,
		"radius": radius
	}
	layout_changed.emit()

func action_to_layout_dict(action: StringName) -> String:
	var result: Dictionary = {
		"x": 0,
		"y": 0,
		"radius": 8,
	}
	if current_touchscreen_layout.has(action):
		result["x"] = current_touchscreen_layout[action].get("position", Vector2.ZERO).x
		result["y"] = current_touchscreen_layout[action].get("position", Vector2.ZERO).y
		result["radius"] = current_touchscreen_layout[action].get("radius", 8)
	elif default_touchscreen_layout.has(action):
			result["x"] = default_touchscreen_layout[action].get("position", Vector2.ZERO).x
			result["y"] = default_touchscreen_layout[action].get("position", Vector2.ZERO).y
			result["radius"] = default_touchscreen_layout[action].get("radius", 8)
	return JSON.stringify(result)

func load_touchscreen_layout(action: StringName, data_string: String) -> void:
	if data_string == "":
		return
	var json: JSON = JSON.new()
	if json.parse(data_string) != OK:
		return
	var dict: Dictionary = json.data
	var pos: Vector2 = Vector2(
		dict.get("x", 0),
		dict.get("y", 0)
	)
	var radius: float = dict.get("radius", 8.0)
	set_touchscreen_layout(action, pos, radius)
