extends Action

var offset: Vector2 = Vector2(0, -8)

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.4
	add_child(timer)

func enter() -> void:
	super ()
	character.dash_target = Vector2(Game.get_player().global_position.x, Game.get_game_scene().land_y)
	Game.get_game_scene().line_aim(character.global_position + offset, character.dash_target + offset)
	timer.start()

func exit() -> void:
	timer.stop()
	super ()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
