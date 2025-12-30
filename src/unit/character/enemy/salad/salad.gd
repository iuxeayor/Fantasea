extends Enemy

const LETTUCE_BULLET: PackedScene = preload("res://src/unit/character/enemy/salad/lettuce_bullet.tscn")
const CABBAGE_BULLET: PackedScene = preload("res://src/unit/character/enemy/salad/cabbage_bullet.tscn")
const TOMATO_BULLET: PackedScene = preload("res://src/unit/character/enemy/salad/tomato_bullet.tscn")
const EGG_BULLET: PackedScene = preload("res://src/unit/character/enemy/salad/egg_bullet.tscn")

var particle_colors: Array[Color] = [
	Color(0.11, 0.43, 0.31), # Lettuce
	Color(0.2, 0.59, 0.29), # Lettuce2
	Color(0.35, 0.77, 0.3), # Lettuce3
	Color(0.57, 0.21, 0.56), # Cabbage
	Color(0.76, 0.14, 0.18), # Tomato
	Color(0.97, 0.9, 0.81), # Egg
]
@onready var shoot_point: Marker2D = $ShootPoint
@onready var player_checker: Area2D = $PlayerChecker

func _ready() -> void:
	super()
	_register_object("lettuce_bullet", LETTUCE_BULLET, 10)
	_register_object("cabbage_bullet", CABBAGE_BULLET, 30)
	_register_object("tomato_bullet", TOMATO_BULLET, 6)
	_register_object("egg_bullet", EGG_BULLET, 10)

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	hurt_particle_queue.overwrite_color = particle_colors.pick_random()
	super(damage, damage_direction)
	
