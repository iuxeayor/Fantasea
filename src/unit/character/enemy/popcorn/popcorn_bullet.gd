extends RigidBullet

@onready var change_collision_timer: Timer = $ChangeCollisionTimer

func spawn(location: Vector2, velo: Vector2) -> void:
	super(location, velo)
	set_collision_mask_value(2, true)
	change_collision_timer.start()

func _on_change_collision_timer_timeout() -> void:
	set_collision_mask_value(2, false)
