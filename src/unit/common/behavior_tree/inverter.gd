@icon("res://src/unit/common/behavior_tree/icon/inverter.svg")
class_name Inverter
extends DecoratorNode

## 反转器：永远返回子节点的相反状态

func _enter() -> void:
	super ()
	if child_nodes.size() > 0:
		child_nodes[0]._enter()

func _exit() -> void:
	if child_nodes.size() > 0:
		child_nodes[0]._exit()
	super ()

func tick(delta: float) -> BTState:
	# 只能有一个子节点
	if child_nodes.size() != 1:
		print("%s/%s has %d children, should have 1" % [get_path(), get_name(), child_nodes.size()])
		return BTState.FAILURE
	match child_nodes[0].tick(delta):
		BTState.SUCCESS:
			return BTState.FAILURE
		BTState.FAILURE:
			return BTState.SUCCESS
	return BTState.RUNNING
