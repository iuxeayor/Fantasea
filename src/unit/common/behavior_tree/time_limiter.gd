@icon("res://src/unit/common/behavior_tree/icon/time_limiter.svg")
class_name TimeLimiter
extends DecoratorNode

## 时间限制器：在指定时间内执行子节点

@export var time_limit: float = 1.0 ## 时间限制
@export var random_offset: float = 0.0 ## 随机偏移
@export var ignore_child: bool = false ## 忽略子节点的状态
var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func _enter() -> void:
	super ()
	if child_nodes.size() > 0:
		child_nodes[0]._enter()
	timer.start(time_limit + random_offset * randf_range(-1.0, 1.0))

func _exit() -> void:
	timer.stop()
	if child_nodes.size() > 0:
		child_nodes[0]._exit()
	super ()

func tick(delta: float) -> BTState:
	# 只能有一个子节点
	if child_nodes.size() != 1:
		print("%s/%s has %d children, should have 1" % [get_path(), get_name(), child_nodes.size()])
		return BTState.FAILURE
	var child_state: BTState = child_nodes[0].tick(delta)
	if not ignore_child and child_state != BTState.RUNNING:
		timer.stop()
		return child_state
	if timer.is_stopped():
		child_nodes[0].reset()
		return BTState.FAILURE
	return BTState.RUNNING
