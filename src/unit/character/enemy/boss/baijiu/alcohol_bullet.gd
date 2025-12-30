extends CharacterBullet

func dead() -> void:
	var alcohol_explosion_bullet: CharacterBullet = Game.get_object("alcohol_explosion_bullet")
	if alcohol_explosion_bullet != null:
		alcohol_explosion_bullet.spawn(global_position, Vector2.ZERO)
	super()
