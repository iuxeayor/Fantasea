extends Action


func enter() -> void:
	for _i: int in range(randi_range(5, 10)):
		var bullet: CharacterBullet = Game.get_object("fry_bullet")
		if bullet == null:
			return
		bullet.spawn(character.shoot_point.global_position, Vector2(
			randf_range(-60, 60),
			randf_range(-180, -300)))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
		
