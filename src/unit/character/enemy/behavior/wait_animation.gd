extends Action

@export var animation_name: StringName = ""
@export var wait_offset: float = 0
@export var play_only: bool = false
var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	if not play_only:
		timer.start(character.animation_player.get_animation(animation_name).length + wait_offset)
	character.animation_play(animation_name)

func exit() -> void:
	super ()
	timer.stop()

func tick(_delta: float) -> BTState:
	if play_only or timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
