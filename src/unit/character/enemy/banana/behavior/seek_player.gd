extends Action

@export var wait_time: float = 0.1:
	set(v):
		wait_time = max(0.1, v)
var timer: Timer = null

@export var player_checker: Area2D = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	# 随机转向一个方向
	character.direction = Constant.Direction.LEFT if randi_range(0, 1) == 0 else Constant.Direction.RIGHT
	timer.start(wait_time)
	character.animation_play("seek")
	character.velocity.x = 0
	# 如果发现玩家则朝向玩家
	if player_checker.has_overlapping_bodies():
		var player: Player = Game.get_player()
		if player.global_position.x < character.global_position.x:
			character.direction = Constant.Direction.LEFT
		elif player.global_position.x > character.global_position.x:
			character.direction = Constant.Direction.RIGHT

func exit() -> void:
	timer.stop()
	# 如果发现玩家则朝向玩家
	if player_checker.has_overlapping_bodies():
		var player: Player = Game.get_player()
		if player.global_position.x < character.global_position.x:
			character.direction = Constant.Direction.LEFT
		elif player.global_position.x > character.global_position.x:
			character.direction = Constant.Direction.RIGHT

func tick(_delta: float) -> BTState:
	if (player_checker.has_overlapping_bodies()
		and not character.falling):
		return BTState.SUCCESS
	if timer.is_stopped():
		return BTState.FAILURE
	return BTState.RUNNING
