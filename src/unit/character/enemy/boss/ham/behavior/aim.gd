extends Action

const LAND_Y: float = 159 # 往上一个像素防止横向检测
const LEFT_X: float = 48
const RIGHT_X: float = 336
const MID_X: float = (LEFT_X + RIGHT_X) / 2
const SKY_Y: float = 64
const BOTTOM_Y: float = 200

const HINT_LINE_LENGTH: float = 128

enum Target {
	PLAYER,
	PLAYER_TOP,
	PLAYER_BOTTOM,
	PLAYER_LAND,
	SPECIAL_TOP
}

enum DirectionRange {
	RIGHT,
	RIGHT_BOTTOM,
	BOTTOM,
	LEFT_BOTTOM,
	LEFT,
	LEFT_TOP,
	TOP,
	RIGHT_TOP,
}


@export var target: Target = Target.PLAYER

func enter() -> void:
	character.hint_line.hide()
	var target_pos: Vector2 = character.global_position
	var player_pos: Vector2 = Game.get_player().global_position
	match target:
		Target.PLAYER:
			target_pos = player_pos + Vector2(0, -8)
		Target.PLAYER_TOP:
			target_pos = Vector2(player_pos.x, SKY_Y)
		Target.PLAYER_BOTTOM:
			target_pos = Vector2(player_pos.x, BOTTOM_Y)
		Target.PLAYER_LAND:
			if player_pos.x < character.global_position.x:
				target_pos = Vector2(LEFT_X, LAND_Y)
			else:
				target_pos = Vector2(RIGHT_X, LAND_Y)
		Target.SPECIAL_TOP:
			if character.global_position.x < MID_X:
				target_pos = Vector2(96, 48)
			else:
				target_pos = Vector2(288, 48)
			Game.get_game_scene().special_hint_line.show()
	target_pos.x = clampf(target_pos.x, LEFT_X, RIGHT_X)
	target_pos.y = min(target_pos.y, LAND_Y)
	var direction: Vector2 = (target_pos - character.hint_line.global_position).normalized()
	character.attack_direction = direction
	var hint_point: Vector2 = character.hint_line.global_position + direction * HINT_LINE_LENGTH
	character.hint_line.points[1] = character.hint_line.to_local(hint_point)
	character.hint_line.show()
	if direction.x < 0:
		character.direction = Constant.Direction.LEFT
	else:
		character.direction = Constant.Direction.RIGHT
	character.play_direction_animation(false)
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
