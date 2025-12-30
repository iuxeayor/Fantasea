extends Enemy

const CAN_RUM_BULLET: PackedScene = preload("res://src/unit/character/enemy/rum/can_rum_bullet.tscn")
const RUM_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/rum/rum_explosion_bullet.tscn")

@onready var attack_point: Marker2D = $Graphics/AttackPoint
@onready var left_checker: RayCast2D = $LeftChecker
@onready var right_checker: RayCast2D = $RightChecker

func _ready() -> void:
	super()
	_register_object("can_rum_bullet", CAN_RUM_BULLET, 10)
	_register_object("rum_explosion_bullet", RUM_EXPLOSION_BULLET, 10)


func seek_player() -> bool:
	return ((left_checker.is_colliding()
		and left_checker.get_collider() is Player)
		or (right_checker.is_colliding()
		and right_checker.get_collider() is Player))
