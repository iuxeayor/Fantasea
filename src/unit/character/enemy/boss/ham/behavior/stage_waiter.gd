extends Action

var timer: Timer = null

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	match character.battle_stage:
		0:
			timer.wait_time = 0.5
		1:
			timer.wait_time = 0.4
		_:
			timer.wait_time = 0.3
	timer.start() 

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
