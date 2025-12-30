extends Action

var timer: Timer = null

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.animation_play("transform")
	character.reset_random_speed()
	character.velocity.x = character.move_speed * character.move_direction
	character.velocity.y = character.jump_velocity
	timer.start(character.animation_player.get_animation("transform").length)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
