extends Action

@export var play_animation: bool = true

func enter() -> void:
	super ()
	character.velocity = Vector2.ZERO
	if play_animation:
		character.animation_play("idle")

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
