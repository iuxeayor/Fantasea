extends Boss

const ICE_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ice/ice_bullet.tscn")
const BIG_ICE_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ice/big_ice_bullet.tscn")
const DROP_ICE_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ice/drop_ice_bullet.tscn")
const TRAP_ICE_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ice/trap_ice_bullet.tscn")

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var shoot_point: Marker2D = $Graphics/ShootPoint
@onready var shoot_top_point: Marker2D = $Graphics/ShootTopPoint
@onready var charge_particle: GPUParticles2D = $Graphics/ChargeParticle

func _ready() -> void:
	super()
	charge_particle.emitting = false
	_register_object("ice_bullet", ICE_BULLET, 40)
	_register_object("big_ice_bullet", BIG_ICE_BULLET, 4)
	_register_object("drop_ice_bullet", DROP_ICE_BULLET, 10)
	_register_object("trap_ice_bullet", TRAP_ICE_BULLET, 10)

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		charge_particle.emitting = false
		defeated.emit()
