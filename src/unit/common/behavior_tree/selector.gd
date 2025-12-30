@icon("res://src/unit/common/behavior_tree/icon/selector.svg")
class_name Selector
extends ControlNode

## 顺序执行子节点，直到其中一个子节点返回成功或全部运行失败

## 是否随机选择子节点
@export var is_random: bool = false

var running_child_index: int = -1

func _ready() -> void:
	super ()
	# 如果随机选择子节点，打乱子节点顺序
	if is_random:
		child_nodes.shuffle()

func tick(delta: float) -> BTState:
	# 没有子节点直接返回失败
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
		# 子节点仍在运行
		if child_state == BTState.RUNNING:
			return BTState.RUNNING
		else:
			child._exit()
			match child_state:
				# 成功则重置
				BTState.SUCCESS:
					# 重置
					current_child_index = 0
					running_child_index = -1
					if is_random:
						child_nodes.shuffle()
					return BTState.SUCCESS
				# 失败则继续执行下一个子节点
				BTState.FAILURE:
					current_child_index += 1
					# 所有子节点执行失败，返回失败
					if current_child_index >= child_nodes.size():
						current_child_index = 0
						running_child_index = -1
						if is_random:
							child_nodes.shuffle()
						return BTState.FAILURE
	return BTState.FAILURE

func reset() -> void:
	super ()
	if (running_child_index >= 0
		and current_child_index < child_nodes.size()):
		child_nodes[current_child_index]._exit()
	current_child_index = 0
	running_child_index = -1
	if is_random:
		child_nodes.shuffle()
