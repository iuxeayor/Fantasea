extends Action

var timer: Timer = null
# 检测是否有新的伤害
var new_hurt_timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.wait_time = 4
	timer.one_shot = true
	add_child(timer)
	new_hurt_timer = Timer.new()
	new_hurt_timer.one_shot = true
	add_child(new_hurt_timer)

func enter() -> void:
	super ()
	character.animation_play("stun")
	character.velocity.x = 0
	timer.start()
	new_hurt_timer.start(character.hurt_timer.time_left + 0.1)

func exit() -> void:
	timer.stop()
	new_hurt_timer.stop()
	super ()

func tick(_delta: float) -> BTState:
	if (timer.is_stopped()
		or (new_hurt_timer.is_stopped()
		and not character.hurt_timer.is_stopped())):
		return BTState.SUCCESS
	return BTState.RUNNING
