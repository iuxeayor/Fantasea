extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	for _i in range(6):
		Game.get_game_scene().bullet_shoot()
	character.animation_play("shoot", true)
	timer.start(character.animation_player.get_animation("shoot").length)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
