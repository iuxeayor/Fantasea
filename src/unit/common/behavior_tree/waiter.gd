@icon("res://src/unit/common/behavior_tree/icon/waiter.svg")
class_name Waiter
extends BehaviorTreeNode

@export var time: float = 1.0 ## 等待时间
## 随机偏移
@export var random_offset: float = 0.0

var timer: Timer = null

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func _enter() -> void:
	super()
	timer.start(time + random_offset * randf_range(-1.0, 1.0))

func _exit() -> void:
	timer.stop()
	super()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
