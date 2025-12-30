@icon("res://src/unit/common/behavior_tree/icon/succeeder.svg")
class_name Succeeder
extends DecoratorNode

## 装饰器节点
# 成功器：永远返回成功状态

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
	return BTState.SUCCESS
