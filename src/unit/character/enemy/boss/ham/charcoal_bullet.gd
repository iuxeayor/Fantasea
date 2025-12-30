extends CharacterBullet

const LAND_Y: float = 176
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func spawn(location: Vector2, velo: Vector2) -> void:
	super(location, velo)
	gpu_particles_2d.restart()


func dead() -> void:
	if abs(global_position.y - LAND_Y) < 8:
		var fire_bullet: CharacterBullet = Game.get_object("fire_bullet")
		if fire_bullet != null:
			fire_bullet.spawn(Vector2(global_position.x, LAND_Y), Vector2.ZERO)
	gpu_particles_2d.emitting = false
	super()
