extends Action

var animate_timer: Timer = null
var timer: Timer = null

func _ready() -> void:
	super ()
	animate_timer = Timer.new()
	animate_timer.one_shot = true
	animate_timer.wait_time = 0.2
	add_child(animate_timer)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	if character.animation_player.current_animation == "zoom_in":
		character.animation_play("zoom_out")
		timer.start(2)
	elif character.animation_player.current_animation != "zoom_out":
		character.animation_play("hurt")
		timer.start(1)
	character.trail.hide()
	character.velocity.x = 0
	character.velocity.y = max(character.velocity.y, 0)
	character.gravity = Constant.gravity
	character.hitbox_collision.disabled = true
	animate_timer.start()

func exit() -> void:
	timer.stop()
	character.hitbox_collision.set_deferred("disabled", false)
	super ()

func tick(_delta: float) -> BTState:
	if animate_timer.is_stopped():
		if character.animation_player.current_animation != "hurt":
			character.animation_play("hurt")
			return BTState.RUNNING
		if character.is_on_floor() and character.velocity.y == 0:
			if timer.is_stopped():
				return BTState.SUCCESS
	return BTState.RUNNING
