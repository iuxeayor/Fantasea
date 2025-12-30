extends Action

@export var wait_time: float = 1
var timer: Timer = null

var aim_offset: Vector2 = Vector2(0, -8)

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	timer.start(wait_time)
	character.animation_play("seek")
	# 细镭射检查状态
	character.laser.width = 0.5
	character.laser.show()
	character.laser_checker.rotation = character.player_checker.to_local(Game.get_player().global_position + aim_offset).angle()

func exit() -> void:
	super ()
	# 准备发射，镭射变粗
	character.laser.width = 1
	
func tick(_delta: float) -> BTState:
	var player: Player = Game.get_player()
	character.player_checker.target_position = character.player_checker.to_local(player.global_position + aim_offset)
	if (character.player_checker.is_colliding()
		and character.player_checker.get_collider() is Player
		and not character.falling):
		if player.global_position.x < character.global_position.x:
			character.direction = Constant.Direction.LEFT
		elif player.global_position.x > character.global_position.x:
			character.direction = Constant.Direction.RIGHT
		character.laser_checker.rotation = character.player_checker.to_local(player.global_position + aim_offset).angle()
	if character.laser_checker.is_colliding():
		character.laser.points[1] = character.laser.to_local(character.laser_checker.get_collision_point())
	else:
		character.laser.points[1] = character.laser.to_local(player.global_position + aim_offset)
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
