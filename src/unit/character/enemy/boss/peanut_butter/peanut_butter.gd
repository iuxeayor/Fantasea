extends Boss

const BIG_PEANUT_BUTTER_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/peanut_butter/big_peanut_butter_bullet.tscn")
const SMALL_PEANUT_BUTTER_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/peanut_butter/small_peanut_butter_bullet.tscn")


var just_hurt_by_attack: bool = false # 刚受到近战伤害，用于行为

var last_attack_direction: Constant.Direction = Constant.Direction.LEFT # 上次攻击方向

@onready var throw_point: Marker2D = $Graphics/ThrowPoint
@onready var spoon_point: Marker2D = $Graphics/SpoonPoint
@onready var trail: Trail = $Trail

func _ready() -> void:
	super()
	_register_object("big_peanut_butter_bullet", BIG_PEANUT_BUTTER_BULLET, 15)
	_register_object("small_peanut_butter_bullet", SMALL_PEANUT_BUTTER_BULLET, 100)

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()

func play_attack() -> void:
	SoundManager.play_sfx("PeanutButterAttack")
