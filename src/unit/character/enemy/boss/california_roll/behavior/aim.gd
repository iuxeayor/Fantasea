extends Action

@export var aim_time: float = 1

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	# 只能瞄准正前方，目标在身后时则随机瞄准前方
	var target: Vector2 = (character.shoot_point.global_position
		+ Vector2(character.direction * randf_range(4, 16), 
			randf_range(-8, 8)))
	var player_pos: Vector2 = Game.get_player().global_position + Vector2(0, -8)
	if ((character.direction == Constant.Direction.LEFT
		and player_pos.x < character.global_position.x)
		or (character.direction == Constant.Direction.RIGHT
		and player_pos.x > character.global_position.x)):
		target = player_pos
	Game.get_game_scene().bullet_aim(character.shoot_point.global_position, target)
	timer.start(aim_time)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
