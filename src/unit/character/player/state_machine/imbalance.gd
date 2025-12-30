extends State

func enter() -> void:
	if randi() % 2 == 0:
		character.animation_play("idle_edge_front")
	else:
		character.animation_play("idle_edge_back")
	character.imbalance_timer.start()
	character.velocity.x = 0

func tick(delta: float) -> void:
	if character.imbalance_timer.is_stopped():
		change_to("AttackSubFSM")
		return
	if not character.is_on_floor():
		character.move(delta,
		- character.face_direction,
		0,
		0,
		Constant.gravity)
