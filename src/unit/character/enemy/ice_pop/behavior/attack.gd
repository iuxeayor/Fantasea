extends Action

const speed: float = 180

func exit() -> void:
	super ()
	# 子弹1，横向
	var bullet_1: CharacterBullet = Game.get_object("stick_bullet")
	if bullet_1 == null:
		return
	bullet_1.spawn(character.shoot_point.global_position, Vector2(character.direction * speed, 0))
	# 子弹2，向上45度发射
	var vertical_bullet: CharacterBullet = Game.get_object("stick_bullet")
	if vertical_bullet == null:
		return
	vertical_bullet.spawn(character.shoot_point.global_position, Vector2(character.direction * speed / sqrt(2), -speed / sqrt(2)))
	character.attack_cooldown_timer.start() # 启动攻击冷却计时器


func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
