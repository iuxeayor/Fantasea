extends Boss

const MUSHROOM_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/big_mushroom/mushroom_bullet.tscn")
const MUSHROOM_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/black_mushroom/mushroom_explosion_bullet.tscn")
const NORMAL_PARTICLE_COLOR: Color = Color(0.96, 0.79, 0.62)
const BOUNCING_PARTICLE_COLOR: Color = Color(0.22, 0.12, 0.12)

var move_speed: float = 200
var move_direction: Constant.Direction = Constant.Direction.LEFT
var jump_velocity: float = -400
var turn_speed: float = PI
var bouncing: bool = false: # 弹跳状态中
	set(v):
		bouncing = v
		set_process(bouncing)
		if bouncing:
			hurt_particle.overwrite_color = BOUNCING_PARTICLE_COLOR
		else:
			hurt_particle.overwrite_color = NORMAL_PARTICLE_COLOR
var just_hurt: bool = false # 刚受伤状态中，用于通知行为树

@onready var left_wall_checker: RayCast2D = $LeftWallChecker
@onready var right_wall_checker: RayCast2D = $RightWallChecker
@onready var ground_checker: RayCast2D = $GroundChecker
@onready var left_hit_particle: GPUParticles2D = $LeftWallChecker/LeftHitParticle
@onready var right_hit_particle: GPUParticles2D = $RightWallChecker/RightHitParticle
@onready var ground_hit_particle: GPUParticles2D = $GroundChecker/GroundHitParticle
@onready var land_particle: GPUParticles2D = $LandParticle
@onready var land_particle_2: GPUParticles2D = $LandParticle2

func _ready() -> void:
	super()
	_register_object("mushroom_bullet", MUSHROOM_BULLET, 4)
	_register_object("mushroom_explosion_bullet", MUSHROOM_EXPLOSION_BULLET, 4)

func _process(delta: float) -> void:
	if not hurt_timer.is_stopped():
		hurt_flash()
	if bouncing:
		sprite_2d.rotate(turn_speed * -move_direction * delta)

func reset_random_speed() -> void:
	move_direction = direction
	var prefer: int = randi() % 3
	# 速度范围：横向[160, 220, 280]，纵向[-340, -400, -460]
	match prefer:
		0:
			# 倾向横向移动
			move_speed = randf_range(220, 280)
			jump_velocity = randf_range(-340, -400)
		1:
			# 倾向纵向跳跃
			move_speed = randf_range(160, 220)
			jump_velocity = randf_range(-400, -460)
		2:
			# 均衡
			move_speed = randf_range(180, 260)
			jump_velocity = randf_range(-360, -440)
	turn_speed = move_speed / 100 * PI

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	# 弹跳时被近战攻击会触发特殊效果
	if bouncing and damage == Game.get_player().status.attack:
		just_hurt = true
	if status.health <= 0:
		stop_battle()
		defeated.emit()

func _on_hurt_timer_timeout() -> void:
	super()
	set_process(bouncing)
