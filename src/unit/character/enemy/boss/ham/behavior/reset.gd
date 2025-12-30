extends Action

func enter() -> void:
	character.hint_line.hide()
	character.trail_particle.emitting = false

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
