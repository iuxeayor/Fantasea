extends Action

func enter() -> void:
	var bullet: CharacterBullet = Game.get_object("track_fry_bullet")
	if bullet == null:
		return
	bullet.spawn(character.shoot_point.global_position, Vector2(
		randf_range(-180, 180),
		-180))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
		
