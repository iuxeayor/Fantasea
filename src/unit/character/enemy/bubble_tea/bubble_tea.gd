extends Enemy

const BOBA_BULLET: PackedScene = preload("res://src/unit/character/enemy/bubble_tea/boba_bullet.tscn")

@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var laser_checker: RayCast2D = $Graphics/PlayerChecker/LaserChecker
@onready var laser: Line2D = $Graphics/PlayerChecker/Laser
@onready var shoot_point: Marker2D = $Graphics/ShootPoint

func _ready() -> void:
	super ()
	laser.hide()
	_register_object("boba_bullet", BOBA_BULLET, 3)

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	laser.hide()
	super (damage, damage_direction)
