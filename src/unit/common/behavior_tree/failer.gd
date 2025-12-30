@icon("res://src/unit/common/behavior_tree/icon/failer.svg")
class_name Failer
extends DecoratorNode

## 失败器：永远返回失败状态

func _enter() -> void:
	super()
	if child_nodes.size() > 0:
		child_nodes[0]._enter()

func _exit() -> void:
	if child_nodes.size() > 0:
		child_nodes[0]._exit()
	super()

func tick(delta: float) -> BTState:
	if child_nodes.size() > 0:
		child_nodes[0].tick(delta)
	return BTState.FAILURE
