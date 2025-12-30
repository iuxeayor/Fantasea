@icon("res://src/unit/common/behavior_tree/icon/behavior_tree_node.svg")
class_name BehaviorTreeNode
extends Node

## 行为树节点，行为树扩展的基类

enum BTState {
	RUNNING = 0,
	SUCCESS = 1,
	FAILURE = 2,
}

enum LogMode {
	INHERIT = 0,
	ENABLE = 1,
	DISABLE = 2,
}

## 是否不使用节点
@export var disabled: bool = false
## 节点日志模式
@export var log_mode: LogMode = LogMode.INHERIT:
	set(v):
		log_mode = v
		if is_node_ready():
			for child: BehaviorTreeNode in child_nodes:
				if child.log_mode == LogMode.INHERIT:
					child.log_mode = log_mode
# 控制角色
var character: Character = null:
	get():
		if character == null:
			character = owner
		return character

var child_nodes: Array[BehaviorTreeNode] = []

func _ready() -> void:
	for child: Node in get_children():
		if (child is BehaviorTreeNode
			and not child.disabled):
			if child.log_mode == LogMode.INHERIT:
				child.log_mode = log_mode
			child_nodes.append(child)

func _enter() -> void:
	if (Game.is_debugging
		and log_mode != LogMode.DISABLE
		and character.enable_active_log):
		GameLogger.btree_log("%s:%s" % [get_parent().name, name], true)
	enter()

func enter() -> void:
	pass

func _exit() -> void:
	if (Game.is_debugging
		and log_mode != LogMode.DISABLE
		and character.enable_active_log):
		GameLogger.btree_log("%s:%s" % [get_parent().name, name], false)
	exit()

func exit() -> void:
	pass

func tick(_delta: float) -> BTState:
	return BTState.RUNNING

# 重置节点
func reset() -> void:
	for child in child_nodes:
		child.reset()
