extends Boss

const FRY_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/combo/fry_bullet.tscn")
const TRACK_FRY_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/combo/track_fry_bullet.tscn")

signal combo_attack
signal health_changed

var attack_signal: bool = false
var waiting_signal: bool = false
var is_defeated: bool = false

@onready var shoot_point: Marker2D = $ShootPoint
@onready var charge_particle: GPUParticles2D = $ChargeParticle

func _ready() -> void:
	super()
	_register_object("fry_bullet", FRY_BULLET, 400)
	_register_object("track_fry_bullet", TRACK_FRY_BULLET, 10)

func _physics_process(delta: float) -> void:
	if is_defeated:
		if is_on_floor() and is_zero_approx(velocity.y):
			velocity = Vector2.ZERO
			animation_play("stun")
			is_defeated = false
	super(delta)
	

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()
		set_collision_mask_value(2, false)
		set_collision_mask_value(20, false)
		if global_position.x < Game.get_player().global_position.x:
			direction = Constant.Direction.RIGHT
		else:
			direction = Constant.Direction.LEFT
		velocity = Vector2(-direction * 60, -120)
		animation_play("hurt")
		is_defeated = true

func is_dead() -> bool:
	return status.health <= 0

func _on_status_status_changed(_type_name: StringName, _value: Variant) -> void:
	health_changed.emit()

func _pass() -> void:
	combo_attack.emit()
