extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	sprite_2d.hide()
	hitbox.disabled = true

func spawn(location: Vector2, damage: int) -> void:
	if animation_player.is_playing():
		return
	global_position = location
	hitbox.damage = damage
	sprite_2d.show()
	gpu_particles_2d.restart()
	SoundManager.play_sfx("PlayerExplosion")
	animation_player.play("explosion")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explosion":
		sprite_2d.hide()
		hitbox.disabled = true
