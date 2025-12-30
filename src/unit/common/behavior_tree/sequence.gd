@icon("res://src/unit/common/behavior_tree/icon/sequence.svg")
class_name Sequence
extends ControlNode

## 依次执行所有子节点，直到有一个子节点返回失败，或者所有子节点都返回成功

## 是否随机选择子节点
@export var is_random: bool = false

var running_child_index: int = -1

func _ready() -> void:
	super ()
	# 打乱子节点顺序
	if is_random:
		child_nodes.shuffle()

func tick(delta: float) -> BTState:
	if child_nodes.is_empty():
		return BTState.FAILURE
	# 从上次的子节点继续执行，而不是每次都重新开始
	while current_child_index < child_nodes.size():
		var child: BehaviorTreeNode = child_nodes[current_child_index]
		# 如果当前子节点是新的子节点，那么需要进入
		if current_child_index != running_child_index:
			child._enter()
			running_child_index = current_child_index
		# 执行子节点
		var child_state: BTState = child.tick(delta)
		if child_state == BTState.RUNNING:
			return BTState.RUNNING
		else:
			child._exit()
			match child_state:
				# 成功则继续执行下一个子节点
				BTState.SUCCESS:
					current_child_index += 1
					# 已经执行完所有子节点
					if current_child_index >= child_nodes.size():
						current_child_index = 0
						running_child_index = -1
						if is_random:
							child_nodes.shuffle()
						return BTState.SUCCESS
				# 失败则重置
				BTState.FAILURE:
					current_child_index = 0
					running_child_index = -1
					if is_random:
						child_nodes.shuffle()
					return BTState.FAILURE
	return BTState.RUNNING

func reset() -> void:
	super ()
	if (running_child_index >= 0
		and current_child_index < child_nodes.size()):
		child_nodes[current_child_index]._exit()
	current_child_index = 0
	running_child_index = -1
	if is_random:
		child_nodes.shuffle()
