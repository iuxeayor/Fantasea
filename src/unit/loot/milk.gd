extends CharacterBody2D

func _ready() -> void:
	velocity.y = -100

func _physics_process(delta: float) -> void:
	if is_on_floor():
		return
	velocity.y += Constant.gravity * delta
	move_and_slide()

func _on_hitbox_collided(source: Hitbox.CollideSource, _damage: int, _location: Vector2) -> void:
	if source == Hitbox.CollideSource.PLAYER:
		Game.get_player().status.potion += 1
		SoundManager.play_sfx("MilkCollect")
		queue_free()
