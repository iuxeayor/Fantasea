extends Action

const ATTACK_LENGTH: float = 96
const ATTACK_SPEED: float = 720
const START_ATTACK_SPEED: float = 20

var origin_pos: Vector2 = Vector2.ZERO
var desired_x_speed: float = 0
var desired_y_speed: float = 0

func enter() -> void:
	character.hint_line.hide()
	SoundManager.play_sfx("HamAttack")
	origin_pos = character.global_position
	character.velocity = character.attack_direction * START_ATTACK_SPEED
	desired_x_speed = abs(character.attack_direction.x * ATTACK_SPEED)
	desired_y_speed = abs(character.attack_direction.y * ATTACK_SPEED)
	character.play_direction_animation(true)
	character.trail_particle.emitting = true

func exit() -> void:
	character.velocity = Vector2.ZERO
	character.trail_particle.emitting = false

func tick(delta: float) -> BTState:
	if (character.velocity.is_zero_approx()):
		return BTState.SUCCESS
	# 停止条件：达到攻击距离，碰到地面/天花板/墙壁
	# 并不会直接停止，而是减速
	if (origin_pos.distance_to(character.global_position) >= ATTACK_LENGTH
		or _hit_wall()):
		var acc_multi: float = 5
		if _hit_wall():
			acc_multi = 15
		character.velocity.x = move_toward(
			character.velocity.x,
			0,
			desired_x_speed * acc_multi * delta
		)
		character.velocity.y = move_toward(
			character.velocity.y,
			0,
			desired_y_speed * acc_multi * delta
		)
	else:
		character.velocity.x = move_toward(
			character.velocity.x,
			character.attack_direction.x * ATTACK_SPEED,
			desired_x_speed * 5 * delta
		)
		character.velocity.y = move_toward(
			character.velocity.y,
			character.attack_direction.y * ATTACK_SPEED,
			desired_y_speed * 5 * delta
		)
	return BTState.RUNNING
	
func _hit_wall() -> bool:
	return ((character.attack_direction.y != 0
		and (character.is_on_floor() 
		or character.is_on_ceiling())
		and is_zero_approx(character.velocity.y))
		or (character.attack_direction.x != 0
		and (character.is_on_wall()))
		and is_zero_approx(character.velocity.x))
