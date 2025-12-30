extends Action

const ATTACK_SPEED: float = 600
const LEFT_X: float = 64
const RIGHT_X: float = 320
const MID_X: float = (LEFT_X + RIGHT_X) / 2
const TOP_Y: float = 48
const BOTTOM_Y: float = 160

enum Target {
	SPECIAL_TOP,
	SPECIAL_BOTTOM,
	FAR_TOP,
	CLOSE_BOTTOM,
}

@export var target: Target = Target.SPECIAL_TOP

var desired_x_speed: float = 0
var desired_y_speed: float = 0

func enter() -> void:
	Game.get_game_scene().special_hint_line.hide()
	character.hint_line.hide()
	SoundManager.play_sfx("HamAttack")
	var target_pos: Vector2 = character.global_position
	match target:
		Target.SPECIAL_TOP:
			target_pos = Vector2(character.global_position.x 
			+ character.direction * 32, TOP_Y)
		Target.SPECIAL_BOTTOM:
			target_pos = Vector2(character.global_position.x 
			+ character.direction * 32, BOTTOM_Y)
		Target.FAR_TOP:
			if Game.get_player().global_position.x < character.global_position.x:
				target_pos = Vector2(RIGHT_X, TOP_Y)
			else:
				target_pos = Vector2(LEFT_X, TOP_Y)
		Target.CLOSE_BOTTOM:
			if character.global_position.x < MID_X:
				target_pos = Vector2(LEFT_X, BOTTOM_Y)
			else:
				target_pos = Vector2(RIGHT_X, BOTTOM_Y)
	var direction: Vector2 = (target_pos - character.hint_line.global_position).normalized()
	character.attack_direction = direction
	character.velocity = character.attack_direction * ATTACK_SPEED
	character.trail_particle.emitting = true
	character.play_direction_animation(true)

func exit() -> void:
	character.velocity = Vector2.ZERO
	character.trail_particle.emitting = false

func tick(_delta: float) -> BTState:
	if (character.velocity.is_zero_approx()):
		return BTState.SUCCESS
	if ((character.attack_direction.y != 0
		and is_zero_approx(character.velocity.y)
		or (character.attack_direction.x != 0
		and is_zero_approx(character.velocity.x)))):
			return BTState.SUCCESS
	return BTState.RUNNING
	
func _hit_wall() -> bool:
	return ((character.attack_direction.y != 0
		and (character.is_on_floor() 
		or character.is_on_ceiling())
		and is_zero_approx(character.velocity.y))
		or (character.attack_direction.x != 0
		and (character.is_on_wall()))
		and is_zero_approx(character.velocity.x))
