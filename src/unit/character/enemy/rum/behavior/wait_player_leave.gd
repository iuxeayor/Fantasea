extends Action

var timer: Timer = null

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	timer.start(randf_range(1.5, 2))
func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if not character.seek_player() or timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
