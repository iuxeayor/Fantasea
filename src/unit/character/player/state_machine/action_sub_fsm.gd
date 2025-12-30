extends SubStateMachine

@onready var idle: Node = $Idle
@onready var fall: Node = $Fall
@onready var run: Node = $Run

func enter() -> void:
	if character.is_on_floor():
		if character.velocity.x == 0:
			current_state = idle
		else:
			current_state = run
	else:
		current_state = fall
	current_state.enter()

func tick(delta: float) -> void:
	super (delta)
	# 攻击
	if (character.status.attack > 0
		and character.control_manager.control_request("attack")
		and character.attack_cd_timer.is_stopped()):
		change_to("Attack")
		return
	if character.control_manager.control_request("shoot"):
		if (Status.has_collection("watermelon_seed")
			and character.shoot_cd_timer.is_stopped()):
			change_to("Shoot")
			return
	if character.control_manager.control_request("throw"):
		if (Status.has_collection("jelly")
			and not character.control_manager.threw_jelly):
			change_to("Throw")
			return
	# 冲刺
	if (Status.has_collection("club_soda")
		and character.control_manager.valid_dash_request()):
		change_to("Dash")
		return
