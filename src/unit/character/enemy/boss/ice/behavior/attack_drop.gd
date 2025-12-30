extends Action

@export var attack_speed: float = 300

func enter() -> void:
	super ()
	character.animation_play("attack_top")
	var bullet: CharacterBullet = Game.get_object("drop_ice_bullet")
	if bullet == null:
		return
	bullet.spawn(character.shoot_top_point.global_position, Vector2(0, -attack_speed))

func tick(_delta: float) -> BTState:
	if character.animation_player.is_playing():
		return BTState.RUNNING
	return BTState.SUCCESS
