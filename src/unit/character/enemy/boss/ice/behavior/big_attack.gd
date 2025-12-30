extends Action

@export var attack_speed: float = 100

var height: float = 152

func enter() -> void:
	super ()
	var bullet: CharacterBullet = Game.get_object("big_ice_bullet")
	if bullet == null:
		return
	SoundManager.play_sfx("IceShootBigBullet")
	bullet.spawn(
		Vector2(character.shoot_point.global_position.x, height),
		Vector2(character.direction * attack_speed, 0))
	
func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
