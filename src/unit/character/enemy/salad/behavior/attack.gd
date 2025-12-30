extends Action

const LETTUCE_Y_VELOCITY: float = -360.0
const CABBAGE_Y_VELOCITY: float = -400.0
const TOMATO_Y_VELOCITY: float = -400.0

func enter() -> void:
	match randi_range(1, 4):
		1:
			_lettuce_attack()
		2:
			_cabbage_attack()
		3:
			_tomato_attack()
		4:
			_egg_attack()

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS

func _lettuce_attack() -> void:
	# 一颗大型子弹
	var bullet: CharacterBullet = Game.get_object("lettuce_bullet")
	if bullet == null:
		return
	var speed: float = Util.calculate_x_velocity_parabola(character.shoot_point.global_position,
		Game.get_player().global_position,
		LETTUCE_Y_VELOCITY,
		bullet.gravity)
	bullet.spawn(character.shoot_point.global_position, Vector2(speed, LETTUCE_Y_VELOCITY))

func _cabbage_attack() -> void:
	# 一颗主子弹和两颗随机偏移子弹
	var bullet_1: CharacterBullet = Game.get_object("cabbage_bullet")
	if bullet_1 == null:
		return
	var speed_1: float = Util.calculate_x_velocity_parabola(character.shoot_point.global_position,
		Game.get_player().global_position,
		CABBAGE_Y_VELOCITY,
		bullet_1.gravity)
	var velo_1: Vector2 = Vector2(speed_1, CABBAGE_Y_VELOCITY)
	bullet_1.spawn(character.shoot_point.global_position, velo_1)
	for _i: int in range(2):
		var bullet_extra: CharacterBullet = Game.get_object("cabbage_bullet")
		if bullet_extra == null:
			return
		bullet_extra.spawn(character.shoot_point.global_position, 
			velo_1 + Vector2(randf_range(-120, 120), randf_range(-40, 40)))

func _tomato_attack() -> void:
	# 一颗高级子弹
	var bullet: RigidBullet = Game.get_object("tomato_bullet")
	if bullet == null:
		return
	var speed: float = Util.calculate_x_velocity_parabola(character.shoot_point.global_position,
		Game.get_player().global_position,
		TOMATO_Y_VELOCITY,
		randf_range(900, 1800))
	bullet.spawn(character.shoot_point.global_position, Vector2(speed, TOMATO_Y_VELOCITY))

func _egg_attack() -> void:
	# 一颗蛋子弹
	var bullet: CharacterBullet = Game.get_object("egg_bullet")
	if bullet == null:
		return
	bullet.spawn(character.shoot_point.global_position, Vector2(character.direction * 240, -180))
