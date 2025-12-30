@icon("res://src/unit/common/behavior_tree/icon/delayer.svg")
class_name Delayer
extends DecoratorNode

## 延迟器：延迟一段时间后执行子节点

## 延迟时间
@export var delay: float = 1.0
## 随机偏移
@export var random_offset: float = 0.0
var timer: Timer = null
# 执行子节点的标记
var child_is_running: bool = false

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func _enter() -> void:
	super ()
	child_is_running = false
	timer.start(delay + random_offset * randf_range(-1.0, 1.0))

func _exit() -> void:
	timer.stop()
	# 如果正在运行子节点，需要退出
	if child_is_running:
		if child_nodes.size() > 0:
			child_nodes[0].exit()
	super ()

func tick(delta: float) -> BTState:
	# 只能有一个子节点
	if child_nodes.size() != 1:
		print("%s/%s has %d children, should have 1" % [get_path(), get_name(), child_nodes.size()])
		return BTState.FAILURE
	# 如果定时器还在运行，不执行子节点
	if not timer.is_stopped():
		return BTState.RUNNING
	if not child_is_running:
		child_is_running = true
		child_nodes[0].enter()
	return child_nodes[0].tick(delta)
