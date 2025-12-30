extends State

func enter() -> void:
	if Status.has_collection("fresh_milk"):
		character.healing_hint.play(Constant.HEAL_TIME_FAST)
	else:
		character.healing_hint.play(Constant.HEAL_TIME)
	character.velocity = Vector2(0, 0)
	character.auto_heal_timer.stop()
	# 动画
	if not character.front_edge_checker.is_colliding():
		character.animation_play("healing_edge_front")
	elif not character.back_edge_checker.is_colliding():
		character.animation_play("healing_edge_back")
	else:
		character.animation_play("healing")
		
func exit() -> void:
	character.healing_hint.stop()
	if Status.has_collection("straw_glasses"):
		character.auto_heal_timer.start()

func tick(_delta: float) -> void:
	# 松开回血键，转到Idle状态
	if not InputManager.is_action_pressed("heal"):
		change_to("Idle")
		return
