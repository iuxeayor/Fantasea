@icon("res://src/unit/common/behavior_tree/icon/parallel.svg")
class_name Parallel
extends ControlNode

enum ParallelMode {
	AND = 0, ## 所有子节点都成功才返回成功
	OR = 1 ## 任意子节点成功就返回成功
}

## 模式
@export var mode: ParallelMode = ParallelMode.AND

var running_child: Array[bool] = []

func _ready() -> void:
	super ()
	for i: int in range(child_nodes.size()):
		running_child.append(false)

func tick(delta: float) -> BTState:
	# 成功的子节点数量
	var success_node_count: int = 0
	# 是否有正在运行的子节点
	var running: bool = false
	# 没有子节点直接返回失败
	if child_nodes.is_empty():
		return BTState.FAILURE
	for i: int in range(child_nodes.size()):
		var child: BehaviorTreeNode = child_nodes[i]
		# 如果当前子节点是新的子节点，那么需要进入
		if not running_child[i]:
			child._enter()
		var child_state: BTState = child.tick(delta)
		match child_state:
			BTState.RUNNING:
				running_child[i] = true
				running = true
			BTState.SUCCESS:
				success_node_count += 1
				child._exit()
				running_child[i] = false
			BTState.FAILURE:
				child._exit()
				running_child[i] = false
	if running:
		return BTState.RUNNING
	match mode:
		ParallelMode.AND:
			if success_node_count == child_nodes.size():
				return BTState.SUCCESS
		ParallelMode.OR:
			if success_node_count > 0:
				return BTState.SUCCESS
	return BTState.FAILURE

func reset() -> void:
	super ()
	for i: int in range(running_child.size()):
		if running_child[i]:
			child_nodes[i]._exit()
	running_child.fill(false)
