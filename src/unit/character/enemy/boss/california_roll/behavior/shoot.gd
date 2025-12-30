extends Action

@export var offset: float = 0

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	Game.get_game_scene().bullet_shoot()
	character.animation_play("shoot", true)
	var wait_time: float = character.animation_player.get_animation("shoot").length + offset
	if wait_time > 0:
		timer.start(wait_time)
	character.gun_smoke_particle.trigger(character.shoot_point.global_position)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
