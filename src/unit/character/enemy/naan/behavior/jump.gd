extends Action

func enter() -> void:
	character.velocity = Vector2(0, -300)
	character.animation_player.play("jump")

func tick(_delta: float) -> BTState:
	if character.velocity.y > 0:
		return BTState.SUCCESS
	return BTState.RUNNING
