extends Action

@export var time: float = 1 ## 持续时间

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	character.velocity = Vector2.ZERO
	timer.start(time)
	character.gravity = 0
	character.animation_play("on_wall")

func exit() -> void:
	timer.stop()
	super ()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
