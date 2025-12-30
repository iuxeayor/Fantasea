extends CharacterBullet

@onready var attack_timer: Timer = $AttackTimer
@onready var ready_timer: Timer = $ReadyTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func spawn(location: Vector2, _velo: Vector2) -> void:
	sprite_2d.modulate.a = 0
	sprite_2d.rotation = randf_range(0, TAU)
	sprite_2d.frame = randi_range(0, 3)
	animation_player.play("run")
	super(location, Vector2.ZERO)
	hitbox.disabled = true
	ready_timer.start()
	attack_timer.start()
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0.5, 0.5)

func dead() -> void:
	super()
	animation_player.stop()

func _on_attack_timer_timeout() -> void:
	hitbox.disabled = true
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0, 1)


func _on_ready_timer_timeout() -> void:
	hitbox.disabled = false
	sprite_2d.modulate.a = 0.5
	
	
