extends Action

func enter() -> void:
	var bullet: CharacterBullet = Game.get_object("track_fry_bullet")
	if bullet == null:
		return
	bullet.spawn(character.shoot_point.global_position, Vector2(-180, -180))
	var bullet2: CharacterBullet = Game.get_object("track_fry_bullet")
	if bullet2 == null:
		return
	bullet2.spawn(character.shoot_point.global_position, Vector2(180, -180))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
		
