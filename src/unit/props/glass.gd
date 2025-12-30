extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var glass: Sprite2D = $Glass
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func glass_break() -> void:
	gpu_particles_2d.restart()
	SoundManager.play_sfx("IcePlatformChange")
	collision_shape_2d.set_deferred("disabled", true)
	glass.hide()
