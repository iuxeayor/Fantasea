extends CharacterBullet

@onready var floor_checker: RayCast2D = $FloorChecker
	
func _on_finished() -> void:
	if floor_checker.is_colliding():
		var melted_bullet: CharacterBullet = Game.get_object("melted_ice_cream_bullet")
		if melted_bullet == null:
			return
		melted_bullet.spawn(floor_checker.get_collision_point(), Vector2(0, gravity))
