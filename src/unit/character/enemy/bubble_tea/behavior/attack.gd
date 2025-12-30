extends Action

var speed: float = 400

func exit() -> void:
	super ()
	character.laser.hide()
	character.animation_play("attack")
	var bullet: CharacterBullet = Game.get_object("boba_bullet")
	if bullet == null:
		return
	var direction: Vector2 = Vector2.from_angle(character.laser_checker.rotation)
	if character.direction == Constant.Direction.LEFT:
		direction.x = - direction.x
	bullet.spawn(character.shoot_point.global_position, direction * speed)
	
func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
