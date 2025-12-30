extends Action

@export var attack_top: bool = false ## 默认攻击前方
@export var attack_speed: float = 180

func enter() -> void:
	super ()
	if attack_top:
		character.animation_play("attack_top")
	else:
		character.animation_play("attack_front")
	var bullet: CharacterBullet = Game.get_object("ice_bullet")
	if bullet == null:
		return
	SoundManager.play_sfx("IceShootBullet")
	if attack_top:
		bullet.spawn(character.shoot_top_point.global_position, Vector2(0, -attack_speed))
	else:
		bullet.spawn(character.shoot_point.global_position, Vector2(attack_speed * character.direction, 0))

func tick(_delta: float) -> BTState:
	if character.animation_player.is_playing():
		return BTState.RUNNING
	return BTState.SUCCESS
