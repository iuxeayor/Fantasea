class_name SubStateMachine
extends State

# 初始状态
@export var initial_state: State = null
# 打印状态切换日志
@export var enable_log: bool = false

# 当前状态
var current_state: State = null
# 上一个状态
var last_state: State = null

func _ready() -> void:
	super ()
	for child: State in get_children():
		child.change.connect(change_state)
	current_state = initial_state
	last_state = current_state

func enter() -> void:
	current_state = initial_state
	current_state.enter()

func exit() -> void:
	current_state.exit()

# 转到指定状态
func change_state(target: String) -> void:
	# 如果状态不存在，直接返回
	var state: State = get_node_or_null(target)
	if state == null:
		return
	# 退出上一个节点
	if current_state != null:
		last_state = current_state
		current_state.exit()
	current_state = state
	current_state.enter()
	if enable_log and character.enable_active_log:
		print("[%d]%s: %s -> %s" % [Engine.get_frames_drawn(), name, last_state.name, current_state.name])

func state_name() -> String:
	return current_state.name

func tick(delta: float) -> void:
	if current_state != null:
		current_state.tick(delta)
