extends Action

const LEFT_LIMIT: float = 128
const RIGHT_LIMIT: float = 256

var timer: Timer
var target_velocity_x: float = 0.0

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	timer.start(randf_range(0.5, 1.5))
	if character.global_position.x <= LEFT_LIMIT:
		character.direction = Constant.Direction.RIGHT
	elif character.global_position.x >= RIGHT_LIMIT:
		character.direction = Constant.Direction.LEFT
	else:
		if randi() % 2 == 0:
			character.direction = Constant.Direction.LEFT
		else:
			character.direction = Constant.Direction.RIGHT
	target_velocity_x = character.direction * randf_range(40, 80)
	character.velocity.x = character.direction * 20
	character.animation_play("walk")

func exit() -> void:
	timer.stop()
	character.animation_play("idle")
	if character.velocity.is_zero_approx():
		character.direction = - character.direction
	character.velocity = Vector2.ZERO


func tick(delta: float) -> BTState:
	if timer.is_stopped() or character.velocity.is_zero_approx():
		return BTState.SUCCESS
	character.velocity.x = move_toward(
		character.velocity.x,
		target_velocity_x,
		abs(target_velocity_x) * 2 * delta)
	return BTState.RUNNING
