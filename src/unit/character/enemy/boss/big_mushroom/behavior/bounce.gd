extends Action

var timer: Timer = null
var last_jump: bool = false

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.animation_play("roll")
	character.bouncing = true
	character.just_hurt = false
	character.direction = Constant.Direction.LEFT
	timer.start(randf_range(4, 6))
	last_jump = false

func exit() -> void:
	character.velocity.x = 0
	character.bouncing = false
	character.just_hurt = false
	character.sprite_2d.rotation = 0
	if character.battle_stage >= 2:
		Game.get_player().imbalance(0.1)
		_hit_block(2)
	else:
		_hit_block(1)

func tick(_delta: float) -> BTState:
	character.ground_checker.enabled = true
	character.left_wall_checker.enabled = true
	character.right_wall_checker.enabled = true
	if character.just_hurt:
		character.move_direction = Game.get_player().face_direction
		character.velocity.x = character.move_direction * 180
		character.velocity.y = -240
		character.just_hurt = false
		return BTState.RUNNING
	if character.is_on_wall():
		if character.left_wall_checker.is_colliding():
			character.move_direction = Constant.Direction.RIGHT
			character.velocity.x = character.move_speed * character.move_direction
			character.left_wall_checker.enabled = false
			character.left_hit_particle.restart()
			_hit_block(1)
		elif character.right_wall_checker.is_colliding():
			character.move_direction = Constant.Direction.LEFT
			character.velocity.x = character.move_speed * character.move_direction
			character.right_wall_checker.enabled = false
			character.right_hit_particle.restart()
			_hit_block(1)
	if (timer.is_stopped()
		and character.is_on_floor()
		and character.velocity.y == 0):
		return BTState.SUCCESS
	if (character.is_on_floor() and character.ground_checker.is_colliding()):
		character.velocity.y = character.jump_velocity
		character.ground_checker.enabled = false
		character.ground_hit_particle.restart()
		if character.battle_stage >= 2:
			Game.get_player().imbalance(0.1)
			_hit_block(2)
		else:
			_hit_block(1)
	return BTState.RUNNING

func _hit_block(strength: float) -> void:
	SoundManager.play_sfx("BigMushroomBounce")
	Game.get_game_scene().game_camera.shake(strength, 0.3)
