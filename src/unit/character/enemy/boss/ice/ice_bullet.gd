extends CharacterBullet

@onready var trail_particle: GPUParticles2D = $TrailParticle

var tween: Tween = null

func spawn(location: Vector2, velo: Vector2) -> void:
	super (location, velo)
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	sprite_2d.scale = Vector2(0, 0)
	tween.tween_property(sprite_2d, "scale", Vector2.ONE, 0.2)
	trail_particle.restart()
