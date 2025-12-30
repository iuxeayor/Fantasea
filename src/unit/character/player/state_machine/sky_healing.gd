extends State

func enter() -> void:
	if Status.has_collection("fresh_milk"):
		character.healing_hint.play(Constant.HEAL_TIME_FAST)
	else:
		character.healing_hint.play(Constant.HEAL_TIME)
	character.velocity = Vector2(0, 0)
	character.auto_heal_timer.stop()
	character.animation_play("sky_healing")
		
func exit() -> void:
	character.healing_hint.stop()
	if Status.has_collection("straw_glasses"):
		character.auto_heal_timer.start()

func tick(_delta: float) -> void:
	# 松开回血键，转到Fall状态
	if not InputManager.is_action_pressed("heal"):
		change_to("Fall")
		return
