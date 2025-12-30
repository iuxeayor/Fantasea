extends Action

@export var walk_top: bool = false ## 默认面对前方
@export var speed: float = 100
@export var time: float = 1
@export var random_offset: float = 0.0 ## 随机偏移

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	if walk_top:
		character.animation_play("walk_top")
	else:
		character.animation_play("walk")
	timer.start(time + randf_range(-random_offset, random_offset))

func exit() -> void:
	super ()
	timer.stop()

func tick(delta: float) -> BTState:
	character.velocity.x = move_toward(character.velocity.x, speed * character.direction, speed * 4 * delta)
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
