extends Action

func enter() -> void:
	var bullet: CharacterBullet = Game.get_object("mushroom_bullet")
	if bullet == null:
		return
	bullet.spawn(character.global_position + Vector2(0, -32), Vector2.ZERO)

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
	
