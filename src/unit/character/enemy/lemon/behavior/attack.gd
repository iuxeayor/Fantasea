extends Action

const SPEED: int = 180

func enter() -> void:
	var bullet: CharacterBullet = Game.get_object("lemon_bullet")
	if bullet == null:
		return
	bullet.spawn(character.shoot_point.global_position, 
		Vector2(character.direction * SPEED, 0))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
