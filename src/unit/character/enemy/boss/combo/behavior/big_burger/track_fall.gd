extends Action

const TRACK_SPEED: float = 120

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.animation_play("fall")
	timer.start()
	character.gravity = 600

func exit() -> void:
	character.velocity.x = 0
	character.gravity = Constant.gravity

func tick(delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	if timer.is_stopped():
		if Game.get_player().global_position.x > character.global_position.x:
			character.velocity.x = move_toward(
				character.velocity.x,
				TRACK_SPEED,
				TRACK_SPEED * 10 * delta
			)
			character.direction = Constant.Direction.RIGHT
		else:
			character.velocity.x = move_toward(
				character.velocity.x,
				-TRACK_SPEED,
				TRACK_SPEED * 10 * delta
			)
			character.direction = Constant.Direction.LEFT
	return BTState.RUNNING
