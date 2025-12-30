extends CharacterBullet

@onready var floor_checker: RayCast2D = $FloorChecker

func _on_finished() -> void:
	if floor_checker.is_colliding():
		var bullet: CharacterBullet = Game.get_object("trap_ice_bullet")
		if bullet == null:
			return
		bullet.spawn(floor_checker.get_collision_point(), Vector2(0, gravity))
