extends Node
class_name ControlManager

var control_direction: Constant.ControlDirection = Constant.ControlDirection.NONE # 控制方向
var control_buffer_timer: Dictionary = {
	"jump": null,
	"dash": null,
	"attack": null,
	"shoot": null,
	"throw": null,
}

var double_jumped: bool = false
var dashed: bool = false
var threw_jelly: bool = false

func _ready() -> void:
	# 初始化控制缓冲计时器
	for key: String in control_buffer_timer.keys():
		var timer: Timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 0.1
		control_buffer_timer[key] = timer
		add_child(timer)

func _physics_process(_delta: float) -> void:
	# 更新控制缓冲计时器
	for key: String in control_buffer_timer.keys():
		if InputManager.is_action_just_pressed(key):
			control_buffer_timer[key].start()
		# 自动攻击
		if Config.auto_attack:
			match key:
				"attack", "shoot":
					if InputManager.is_action_pressed(key):
						control_buffer_timer[key].start()
	
func control_request(action: String) -> bool:
	if control_buffer_timer.get(action) == null:
		return false
	return not control_buffer_timer.get(action).is_stopped()

func valid_dash_request() -> bool:
	return (control_request("dash")
		and not dashed
		and Game.get_player().dash_cd_timer.is_stopped())

func valid_double_jump_request() -> bool:
	return (control_request("jump")
		and not double_jumped)
