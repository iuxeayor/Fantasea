extends Action

func enter() -> void:
	super ()
	character.velocity = Vector2.ZERO
	character.gravity = 0
	character.animation_play("hover")

func tick(_delta: float) -> BTState:
	if character.animation_player.is_playing() and character.animation_player.current_animation == "hover":
		return BTState.RUNNING
	return BTState.SUCCESS
