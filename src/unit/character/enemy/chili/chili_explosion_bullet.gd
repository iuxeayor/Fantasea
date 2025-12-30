extends CharacterBullet

@onready var explosion_particle: GPUParticles2D = $ExplosionParticle
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	sprite_2d.scale = Vector2.ZERO

func spawn(location: Vector2, velo: Vector2) -> void:
	super (location, velo)
	explosion_particle.restart()
	animation_player.play("explosion")
	SoundManager.play_sfx("ExplosionShort")
	Game.get_game_scene().game_camera.shake(1, 0.2)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explosion":
		dead()
