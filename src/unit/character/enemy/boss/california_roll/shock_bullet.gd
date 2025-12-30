extends CharacterBullet

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func spawn(location: Vector2, _velo: Vector2) -> void:
	sprite_2d.show()
	Game.get_game_scene().game_camera.shake(2, 0.4)
	animation_player.play("shock")
	disabled = false
	global_position = location
	gpu_particles_2d.restart()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	hitbox.disabled = true
	sprite_2d.hide()
