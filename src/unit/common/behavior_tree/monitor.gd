@icon("res://src/unit/common/behavior_tree/icon/monitor.svg")
class_name Monitor
extends ControlNode

## 同时执行两个节点，直到节点一返回目标状态

@export var target_state: BTState = BTState.SUCCESS

func _enter() -> void:
	super ()
	if child_nodes.size() != 2:
		print("%s/%s has %d children, should have 2" % [get_path(), get_name(), child_nodes.size()])
		return
	child_nodes[0]._enter()
	child_nodes[1]._enter()

func _exit() -> void:
	if child_nodes.size() != 2:
		print("%s/%s has %d children, should have 2" % [get_path(), get_name(), child_nodes.size()])
		return
	child_nodes[0]._exit()
	child_nodes[1]._exit()
	super ()

func tick(delta: float) -> BTState:
	if child_nodes.size() != 2:
		print("%s/%s has %d children, should have 2" % [get_path(), get_name(), child_nodes.size()])
		return BTState.FAILURE
	# 执行第一个子节点
	var first_child_state: BTState = child_nodes[0].tick(delta)
	if first_child_state == target_state:
		# 如果第一个子节点不是目标状态，直接返回其状态
		child_nodes[1].reset()
		return first_child_state
	# 执行第二个子节点
	child_nodes[1].tick(delta)
	return BTState.RUNNING
