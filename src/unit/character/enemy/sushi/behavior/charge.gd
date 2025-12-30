extends Action

func enter() -> void:
	character.animation_play("charge")
	character.velocity.x = 0
	character.counterattack_collision.set_deferred("disabled", false)
	character.hurtbox.disabled = true

func exit() -> void:
	character.counterattack_collision.set_deferred("disabled", true)
	character.hurtbox.disabled = false

func tick(_delta: float) -> BTState:
	if (not character.player_checker.is_colliding()
		and not character.seed_checker.has_overlapping_bodies()):
		return BTState.FAILURE
	if character.counterattack_checker.has_overlapping_areas():
		return BTState.SUCCESS
	return BTState.RUNNING
		
