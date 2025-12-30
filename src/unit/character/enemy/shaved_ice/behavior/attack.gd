extends Action

const X_SPEED: float = 70
const Y_SPEED: float = 140

func exit() -> void:
	for i: int in range(3):
		var bullet: CharacterBullet = Game.get_object("ice_powder_bullet")
		if bullet == null:
			break
		bullet.spawn(
			character.shoot_point.global_position,
			Vector2(randf_range(1, -1) * X_SPEED, randf_range(-1, -0.5) * Y_SPEED)
		)
func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
