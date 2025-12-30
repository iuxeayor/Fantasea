extends Boss

const CHARCOAL_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ham/charcoal_bullet.tscn")
const FIRE_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/ham/fire_bullet.tscn")
const SKEWER: PackedScene = preload("res://src/unit/character/enemy/skewer/skewer.tscn")

enum DirectionRange {
	RIGHT,
	RIGHT_BOTTOM,
	BOTTOM,
	LEFT_BOTTOM,
	LEFT,
	LEFT_TOP,
	TOP,
	RIGHT_TOP,
}

var attack_direction: Vector2 = Vector2.ZERO

@onready var hint_line: Line2D = $HintLine
@onready var trail_particle: GPUParticles2D = $Graphics/TrailParticle
@onready var throw_point: Marker2D = $ThrowPoint

func _ready() -> void:
	super()
	_register_object("charcoal_bullet", CHARCOAL_BULLET, 10)
	_register_object("fire_bullet", FIRE_BULLET, 10)
	gravity = 0
	trail_particle.emitting = false

func play_direction_animation(is_attack: bool) -> void:
	var angle: float = rad_to_deg(attack_direction.angle())
	while angle < 0:
		angle += 360
	var direction_range: DirectionRange = DirectionRange.RIGHT
	if (angle >= 0 and angle < 20) or (angle >= 340 and angle < 360):
		direction_range = DirectionRange.RIGHT
	elif angle >= 20 and angle < 70:
		direction_range = DirectionRange.RIGHT_BOTTOM
	elif angle >= 70 and angle < 110:
		direction_range = DirectionRange.BOTTOM
	elif angle >= 110 and angle < 160:
		direction_range = DirectionRange.LEFT_BOTTOM
	elif angle >= 160 and angle < 200:
		direction_range = DirectionRange.LEFT
	elif angle >= 200 and angle < 250:
		direction_range = DirectionRange.LEFT_TOP
	elif angle >= 250 and angle < 290:
		direction_range = DirectionRange.TOP
	elif angle >= 290 and angle < 340:
		direction_range = DirectionRange.RIGHT_TOP
	else:
		direction_range = DirectionRange.RIGHT
	match direction_range:
		DirectionRange.RIGHT, DirectionRange.LEFT:
			if is_attack:
				animation_play("attack_front")
			else:
				animation_play("charge_front")
		DirectionRange.RIGHT_BOTTOM, DirectionRange.LEFT_BOTTOM:
			if is_attack:
				animation_play("attack_front_bottom")
			else:
				animation_play("charge_front_bottom")
		DirectionRange.BOTTOM:
			if is_attack:
				animation_play("attack_bottom")
			else:
				animation_play("charge_bottom")
		DirectionRange.LEFT_TOP, DirectionRange.RIGHT_TOP:
			if is_attack:
				animation_play("attack_front_top")
			else:
				animation_play("charge_front_top")
		DirectionRange.TOP:
			if is_attack:
				animation_play("attack_top")
			else:
				animation_play("charge_top")
		_:
			animation_play("idle")

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()
