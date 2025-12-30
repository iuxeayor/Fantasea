extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.velocity.x = 0
	if abs(character.global_position.x - Game.get_player().global_position.x) <= 56:
		character.animation_play("attack_3")
		timer.start(character.animation_player.get_animation("attack_3").length + 0.2)
	else:
		character.animation_play("idle")
		timer.start(0.1)

func exit() -> void:
	character.animation_play("idle")

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
