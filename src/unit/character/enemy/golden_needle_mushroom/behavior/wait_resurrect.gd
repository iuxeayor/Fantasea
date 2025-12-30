extends Action

func enter() -> void:
	character.animation_play("die")
	character.velocity.x = 0

func exit() -> void:
	character.hitbox.disabled = false
	character.hurtbox.disabled = false

func tick(_delta: float) -> BTState:
	if not character.resurrecting:
		return BTState.SUCCESS
	return BTState.RUNNING
