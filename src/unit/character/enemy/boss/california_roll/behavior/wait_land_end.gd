extends Action

@export var wait_time: float = 3

var timer: Timer = null
var current_health: int = 0

func _ready() -> void:
	super()
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.animation_play("land")
	timer.start()
	SoundManager.play_sfx("RollLand")
	current_health = character.status.health
	var bullet: CharacterBullet = Game.get_object("shock_bullet")
	if bullet == null:
		return
	bullet.spawn(character.global_position, Vector2.ZERO)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped() or character.status.health < current_health:
		return BTState.SUCCESS
	return BTState.RUNNING
