@icon("res://src/unit/common/behavior_tree/icon/times_limiter.svg")
class_name TimesLimiter
extends DecoratorNode

## 次数限制器：在指定时间内执行子节点

@export var limit: int = 1 ## 次数限制
@export var random_offset: int = 0 ## 随机偏移
@export var ignore_child: bool = false ## 忽略子节点的状态

var current_count: int = 0

func _enter() -> void:
	super ()
	if child_nodes.size() > 0:
		child_nodes[0]._enter()
	current_count = 0


func _exit() -> void:
	if child_nodes.size() > 0:
		child_nodes[0]._exit()
	current_count = 0
	super ()

func tick(delta: float) -> BTState:
	# 只能有一个子节点
	if child_nodes.size() != 1:
		print("%s/%s has %d children, should have 1" % [get_path(), get_name(), child_nodes.size()])
		return BTState.FAILURE
	if current_count >= limit:
		child_nodes[0].reset()
		return BTState.FAILURE
	var child_state: BTState = child_nodes[0].tick(delta)
	if not ignore_child and child_state != BTState.RUNNING:
		return child_state
	if child_state != BTState.RUNNING:
		current_count += 1
	return BTState.RUNNING
