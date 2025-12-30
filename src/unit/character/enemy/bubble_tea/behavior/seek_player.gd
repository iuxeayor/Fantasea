extends Action

@export var wait_time: float = 0.1:
	set(v):
		wait_time = max(0.1, v)
var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	timer.start(wait_time)
	character.animation_play("seek")
	character.velocity.x = 0
	character.direction = Constant.Direction.LEFT if randi_range(0, 1) == 0 else Constant.Direction.RIGHT

func exit() -> void:
	super ()
	timer.stop()
	if (character.player_checker.is_colliding()
		and character.player_checker.get_collider() is Player
		and not character.falling):
		var player: Player = Game.get_player()
		if player.global_position.x < character.global_position.x:
			character.direction = Constant.Direction.LEFT
		elif player.global_position.x > character.global_position.x:
			character.direction = Constant.Direction.RIGHT

func tick(_delta: float) -> BTState:
	character.player_checker.target_position = character.player_checker.to_local(Game.get_player().global_position + Vector2(0, -8))
	if (character.player_checker.is_colliding()
		and character.player_checker.get_collider() is Player
		and not character.falling):
		return BTState.SUCCESS
	if timer.is_stopped():
		return BTState.FAILURE
	return BTState.RUNNING
