extends Enemy

const YOGURT_BULLET: PackedScene = preload("res://src/unit/character/enemy/yogurt/yogurt_bullet.tscn")

@onready var shoot_point: Marker2D = $Graphics/ShootPoint
@onready var player_checker: Area2D = $Graphics/PlayerChecker
@onready var player_see_checker: RayCast2D = $PlayerSeeChecker

var attacking: bool = false

func _ready() -> void:
	super ()
	_register_object("yogurt_bullet", YOGURT_BULLET, 10)

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	super.hurt(damage, damage_direction)
	shoot_1()
	attacking = false

func animation_play(anim_name: StringName, overwrite_same: bool = false) -> void:
	if anim_name == "attack":
		attacking = true
	else:
		attacking = false
	super.animation_play(anim_name, overwrite_same)

func _shoot_yogurt(speed: float, velo_y: float) -> void:
	var bullet: CharacterBullet = Game.get_object("yogurt_bullet")
	if bullet == null:
		return
	bullet.spawn(shoot_point.global_position, Vector2(speed * direction, velo_y))

func shoot_1() -> void:
	_shoot_yogurt(60, -140)

func shoot_2() -> void:
	_shoot_yogurt(100, -160)

func shoot_3() -> void:
	_shoot_yogurt(140, -180)

func shoot_4() -> void:
	_shoot_yogurt(180, -200)

func shoot_5() -> void:
	_shoot_yogurt(220, -220)


func _on_see_player_timer_timeout() -> void:
	player_see_checker.target_position = player_see_checker.to_local(Game.get_player().global_position + Vector2(0, -8))
