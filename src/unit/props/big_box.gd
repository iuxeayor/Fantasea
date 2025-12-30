extends StaticBody2D

signal completed

var health: int = 3

@onready var hit_timer: Timer = $HitTimer
@onready var particle_queue: ParticleQueue = $ParticleQueue
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hit_collision: CollisionShape2D = $Hitbox/HitCollision

func _ready() -> void:
	if Status.scene_status.story.get("main_break", false):
		queue_free()

func _process(_delta: float) -> void:
	if hit_timer.is_stopped():
		return
	sprite_2d.material.set_shader_parameter("flash_amount", sin(float(Time.get_ticks_msec()) / 40) * 0.25 + 0.25)

func reset_material() -> void:
	if health > 0:
		sprite_2d.material.set_shader_parameter("flash_amount", 0.0)


func _on_hit_timer_timeout() -> void:
	if health > 0:
		hit_collision.set_deferred("disabled", false)
		set_process(false)
		reset_material.call_deferred()


func _on_hitbox_collided(source: Hitbox.CollideSource, _damage: int, _location: Vector2) -> void:
	if source == Hitbox.CollideSource.PLAYER:
		if health <= 0:
			return
		hit_collision.set_deferred("disabled", true)
		health -= 1
		hit_timer.start()
		set_process(true)
		particle_queue.trigger(sprite_2d.global_position)
		if health <= 0:
			dead()
			return
		SoundManager.play_sfx("BreakableHit")

func dead() -> void:
	SoundManager.play_sfx("BreakableBreak")
	particle_queue.trigger(sprite_2d.global_position)
	hit_timer.stop()
	reset_material.call_deferred()
	sprite_2d.set_deferred("material", null)
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "self_modulate:a", 0, 0.5)
	await tween.finished
	completed.emit()
	Status.scene_status.story["main_break"] = true # 破坏剧情
	queue_free()
