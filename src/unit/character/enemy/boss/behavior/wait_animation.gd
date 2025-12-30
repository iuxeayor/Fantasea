extends Action

@export var animate_name: StringName = "" ## 动画名称
@export var wait_offset: float = 0 ## 等待动画结束的偏移时间
@export var sfx_name: StringName = "" ## 音效
@export var play_only: bool = false ## 仅播放，适用于不需要等待或重复动画

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	if sfx_name != "":
		SoundManager.play_sfx(sfx_name)
	if not play_only:
		timer.start(character.animation_player.get_animation(animate_name).length + wait_offset)
	character.animation_play(animate_name)

func exit() -> void:
	super ()
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
