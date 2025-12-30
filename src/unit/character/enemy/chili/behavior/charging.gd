extends Action


var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	timer.start(character.animation_player.get_animation("charge").length)
	character.animation_play("charge")
	character.velocity.x = 0

func exit() -> void:
	super ()
	character.animation_play("idle")
	character.reset_flash.call_deferred()

func tick(_delta: float) -> BTState:
	# 玩家离开范围
	if (Game.get_player() != null
		and Game.get_player().global_position.distance_to(character.global_position) > 32):
		return BTState.SUCCESS
	# 玩家在范围内，爆炸
	if timer.is_stopped():
		var bullet: CharacterBullet = Game.get_object("chili_explosion_bullet")
		if bullet == null:
			return BTState.SUCCESS
		bullet.spawn(character.explosion_point.global_position, Vector2.ZERO)
		character.queue_free()
		return BTState.FAILURE
	return BTState.RUNNING
