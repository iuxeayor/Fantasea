extends RigidBullet

func dead() -> void:
	var rum_explosion_bullet: CharacterBullet = Game.get_object("rum_explosion_bullet")
	if rum_explosion_bullet != null:
		rum_explosion_bullet.spawn(global_position, Vector2.ZERO)
	super()
