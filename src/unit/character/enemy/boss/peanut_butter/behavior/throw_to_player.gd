extends Action

@export var velo_y: float = -360

func exit() -> void:
	super ()
	var bullet: CharacterBullet = Game.get_object("big_peanut_butter_bullet")
	if bullet == null:
		return
	bullet.spawn(character.throw_point.global_position,
		Vector2(Util.calculate_x_velocity_parabola(
			character.throw_point.global_position,
			Game.get_player().global_position,
			velo_y,
			800),
			velo_y))
	
func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
