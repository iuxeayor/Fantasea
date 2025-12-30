extends CharacterBullet

var move_direction: Constant.Direction = Constant.Direction.LEFT
var move_speed: float = 200
var jump_velocity: float = -360
var rotate_speed: float = PI

@onready var left_wall_checker: RayCast2D = $LeftWallChecker
@onready var right_wall_checker: RayCast2D = $RightWallChecker
@onready var ground_checker: RayCast2D = $GroundChecker
@onready var left_hit_particle: GPUParticles2D = $LeftWallChecker/LeftHitParticle
@onready var right_hit_particle: GPUParticles2D = $RightWallChecker/RightHitParticle
@onready var ground_hit_particle: GPUParticles2D = $GroundChecker/GroundHitParticle
@onready var explosion_timer: Timer = $ExplosionTimer

func _process(delta: float) -> void:
	super(delta)
	sprite_2d.rotate(rotate_speed * delta * move_direction)
	if explosion_timer.is_stopped():
		hint_flash()

func _physics_process(delta: float) -> void:
	if disabled:
		return
	move_and_slide()
	velocity.y = min(Constant.MAX_FALL_VELOCITY, velocity.y + gravity * delta)
	left_wall_checker.enabled = true
	right_wall_checker.enabled = true
	ground_checker.enabled = true
	if is_on_floor() and ground_checker.is_colliding():
		velocity.y = jump_velocity
		ground_checker.enabled = false
		ground_hit_particle.restart()
	if is_on_wall() and left_wall_checker.is_colliding():
		move_direction = Constant.Direction.RIGHT
		velocity.x = move_speed * move_direction
		left_wall_checker.enabled = false
		left_hit_particle.restart()
	elif is_on_wall() and right_wall_checker.is_colliding():
		move_direction = Constant.Direction.LEFT
		velocity.x = move_speed * move_direction
		right_wall_checker.enabled = false
		right_hit_particle.restart()

func hint_flash() -> void:
	sprite_2d.material.set_shader_parameter("flash_amount", sin(float(Time.get_ticks_msec()) / 40) * 0.5 + 0.5)

# 重置闪烁
func reset_flash() -> void:
	sprite_2d.material.set_shader_parameter("flash_amount", 0)

func spawn(location: Vector2, _velo: Vector2) -> void:
	reset_flash()
	left_wall_checker.enabled = true
	right_wall_checker.enabled = true
	ground_checker.enabled = true
	move_speed = randf_range(120, 240)
	jump_velocity = randf_range(-340, -400)
	rotate_speed = PI * move_speed / 100
	if randi() % 2 == 0:
		move_direction = -move_direction as Constant.Direction
	explosion_timer.start()
	super(location, Vector2(move_direction * move_speed, jump_velocity))

func dead() -> void:
	reset_flash()
	explosion_timer.stop()
	var bullet: CharacterBullet = Game.get_object("mushroom_explosion_bullet")
	if bullet != null:
		bullet.spawn(global_position, Vector2.ZERO)
	super()

func _on_hurtbox_collided(source: Hitbox.CollideSource, damage: int, _location: Vector2) -> void:
	if source == Hitbox.CollideSource.PLAYER and damage == Game.get_player().status.attack:
		dead()
