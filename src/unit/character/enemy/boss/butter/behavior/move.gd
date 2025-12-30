extends Action

@export var speed: float = 100 ## 速度
@export var time: float = 0.1 ## 持续时间

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	timer.start(time)
	character.velocity.x = speed * character.direction

func exit() -> void:
	character.velocity.x = 0
	timer.stop()
	super ()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
