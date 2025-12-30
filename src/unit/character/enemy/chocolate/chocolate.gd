extends Enemy

const CHOCOLATE_CHUCK: PackedScene = preload("res://src/unit/character/enemy/chocolate/chocolate_chuck.tscn")
@onready var separate_particle: GPUParticles2D = $SeparateParticle

func _ready() -> void:
	super ()
	_register_object("chocolate_chuck", CHOCOLATE_CHUCK, 4)

func die() -> void:
	super ()
	await get_tree().create_timer(0.2).timeout
	gravity = 0
	velocity = Vector2.ZERO
	sprite_2d.hide()
	health_bar.hide()
	separate_particle.emitting = true
	for i: int in range(4):
		var chocolate_chuck: Enemy = Game.get_object("chocolate_chuck")
		if chocolate_chuck == null:
			return
		chocolate_chuck.disabled = false
		chocolate_chuck.global_position = separate_particle.global_position
		chocolate_chuck.velocity = Vector2(randf_range(-50, 50), -200)
		

func _on_separate_particle_finished() -> void:
	queue_free()
