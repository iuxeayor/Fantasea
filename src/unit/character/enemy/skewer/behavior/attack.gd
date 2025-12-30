extends Action

var speed: float = 240
var target_velo: float = 0

func enter() -> void:
	super ()
	character.animation_play("attack")
	target_velo = character.direction * speed
	if character.direction == Constant.Direction.LEFT:
		character.left_attack_collision.set_deferred("disabled", false)
		character.right_attack_collision.set_deferred("disabled", true)
	elif character.direction == Constant.Direction.RIGHT:
		character.left_attack_collision.set_deferred("disabled", true)
		character.right_attack_collision.set_deferred("disabled", false)
	else:
		character.left_attack_collision.set_deferred("disabled", true)
		character.right_attack_collision.set_deferred("disabled", true)

func exit() -> void:
	super ()
	target_velo = 0
	character.velocity.x = 0
	character.left_attack_collision.set_deferred("disabled", true)
	character.right_attack_collision.set_deferred("disabled", true)

func tick(delta: float) -> BTState:
	if character.attack_checker.is_colliding():
		character.hit_wall_particle.restart()
		return BTState.SUCCESS
	character.velocity.x = move_toward(character.velocity.x, target_velo, speed * delta)
	return BTState.RUNNING
