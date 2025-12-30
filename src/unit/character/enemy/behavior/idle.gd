extends Action

@export var play_animation: bool = true ## 是否播放动画

func enter() -> void:
	character.velocity = Vector2.ZERO
	if play_animation:
		character.animation_play("idle")
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
