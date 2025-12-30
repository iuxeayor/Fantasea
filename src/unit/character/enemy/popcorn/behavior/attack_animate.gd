extends Action

@export var wait_time: float = 0.1:
	set(v):
		wait_time = max(0.1, v)
var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	character.velocity.x = 0
	timer.start(wait_time)
	character.animation_play("attack")

func exit() -> void:
	super ()
	timer.stop()
	
func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
