extends Action

@export var hurt: bool = false

func enter() -> void:
	character.velocity.x = 0
	if hurt:
		character.animation_play("hurt")
	else:
		character.animation_play("idle")

func exit() -> void:
	character.velocity = Vector2.ZERO

func tick(delta: float) -> BTState:
	if character.is_on_floor():
		return BTState.SUCCESS
	character.velocity.y += Constant.gravity * delta
	return BTState.RUNNING
