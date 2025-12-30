extends Action

@export var damage: int = 10 ## 伤害检测

var start_health: int = 0

func enter() -> void:
	super ()
	start_health = character.status.health
	
func exit() -> void:
	super ()
	start_health = 0

func tick(_delta: float) -> BTState:
	if character.status.health <= start_health - damage:
		return BTState.SUCCESS
	return BTState.RUNNING
