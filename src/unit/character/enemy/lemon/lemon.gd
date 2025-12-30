extends Enemy

const LEMON_BULLET: PackedScene = preload("res://src/unit/character/enemy/lemon/lemon_bullet.tscn")

func _ready() -> void:
	super()
	_register_object("lemon_bullet", LEMON_BULLET, 10)
	
@onready var shoot_point: Marker2D = $Graphics/ShootPoint
