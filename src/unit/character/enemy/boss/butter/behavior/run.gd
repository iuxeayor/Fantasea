extends Action

@export var min_speed: float = 40 ## 最小速度
@export var max_speed: float = 80 ## 最大速度
@export var min_time: float = 0.5 ## 最小持续时间
@export var max_time: float = 1 ## 最大持续时间

var desire_speed: float = 0
var desire_velocity_x: float = 0

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	timer.start(randf_range(min_time, max_time))
	character.animation_play("run")
	desire_speed = randf_range(min_speed, max_speed)
	desire_velocity_x = character.direction * desire_speed

func exit() -> void:
	character.velocity.x = 0
	timer.stop()
	desire_speed = 0
	desire_velocity_x = 0
	super ()

func tick(delta: float) -> BTState:
	if timer.is_stopped() or character.wall_checker.is_colliding():
		if character.velocity.x == 0:
			return BTState.SUCCESS
		character.velocity.x = move_toward(character.velocity.x, 0, desire_speed * 4 * delta)
		return BTState.RUNNING
	else:
		character.velocity.x = move_toward(character.velocity.x, desire_velocity_x, desire_speed * 4 * delta)
	return BTState.RUNNING
