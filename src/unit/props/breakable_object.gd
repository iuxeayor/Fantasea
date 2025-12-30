extends TileMapLayer

signal completed


@export var can_break: bool = true ## 是否能被玩家击破
@export var particle_color: Color = Color.WHITE

var health: int = 3
var shoot_position: Vector2 = Vector2.ZERO

@onready var hit_timer: Timer = $HitTimer
@onready var particle_queue: ParticleQueue = $ParticleQueue
@onready var gpu_particles_2d: GPUParticles2D = $ParticleQueue/GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $ParticleQueue/GPUParticles2D2
@onready var gpu_particles_2d_3: GPUParticles2D = $ParticleQueue/GPUParticles2D3
@onready var color_rect: ColorRect = $ColorRect
@onready var hit_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var solid_fix_collision: CollisionShape2D = $SolidFix/CollisionShape2D


func _ready() -> void:
	# 粒子颜色
	particle_queue.overwrite_color = particle_color
	# 背景处理
	var tile_used_rect: Rect2i = Rect2i(
		get_used_rect().position * tile_set.tile_size,
		get_used_rect().size * tile_set.tile_size
		)
	var shape_size: Vector2 = get_used_rect().size * tile_set.tile_size
	if not can_break: # 不能被击破时显示背景
		color_rect.size = shape_size
		color_rect.color = particle_color
	else:
		color_rect.hide()
	# 设置碰撞形状
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = shape_size
	hit_collision.shape = shape
	hit_collision.position = Vector2(
		tile_used_rect.position.x * tile_set.tile_size.x + shape_size.x / 2,
		tile_used_rect.position.y * tile_set.tile_size.y + shape_size.y / 2
	)
	solid_fix_collision.shape = shape
	solid_fix_collision.position = Vector2(
		tile_used_rect.position.x * tile_set.tile_size.x + shape_size.x / 2,
		tile_used_rect.position.y * tile_set.tile_size.y + shape_size.y / 2
	)
	# 粒子数量
	var particle_amount: int = get_used_rect().size.x * get_used_rect().size.y * 3
	gpu_particles_2d.amount = particle_amount
	gpu_particles_2d_2.amount = particle_amount
	gpu_particles_2d_3.amount = particle_amount
	# 粒子发射位置
	shoot_position = to_global(tile_used_rect.position + tile_used_rect.size / 2)
	gpu_particles_2d.modulate = particle_color
	gpu_particles_2d.process_material.emission_box_extents = Vector3(
		float(tile_used_rect.size.x) / 2,
		float(tile_used_rect.size.y) / 2,
		0
	)

func _physics_process(_delta: float) -> void:
	if not hit_timer.is_stopped():
		material.set_shader_parameter("flash_amount", sin(float(Time.get_ticks_msec()) / 40) * 0.25 + 0.25)


func reset_material() -> void:
	if health > 0:
		material.set_shader_parameter("flash_amount", 0.0)


func _on_hit_timer_timeout() -> void:
	if health > 0:
		hit_collision.set_deferred("disabled", false)
		reset_material.call_deferred()


func _on_hitbox_collided(source: Hitbox.CollideSource, damage: int, _location: Vector2) -> void:
	if not can_break:
		return
	if Game.get_player() == null:
		return
	if damage != Game.get_player().status.attack: # 伤害不同说明不是玩家近身攻击而是远程攻击
		return
	if source == Hitbox.CollideSource.PLAYER:
		hit()

func hit() -> void:
	if health <= 0:
		return
	hit_collision.set_deferred("disabled", true)
	health -= 1
	hit_timer.start()
	particle_queue.trigger(shoot_position)
	if health <= 0:
		dead()
		return
	SoundManager.play_sfx("BreakableHit")

func dead() -> void:
	completed.emit()
	collision_enabled = false
	solid_fix_collision.set_deferred("disabled", true)
	SoundManager.play_sfx("BreakableBreak")
	particle_queue.trigger(shoot_position)
	hit_timer.stop()
	reset_material.call_deferred()
	set_deferred("material", null)
	color_rect.hide()
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate:a", 0, gpu_particles_2d.lifetime)
	await tween.finished
	queue_free()

func complete() -> void:
	queue_free()
