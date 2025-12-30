extends RigidBody2D
class_name RigidBullet
## 基于RigidBody2D的子弹，有独立的物理

signal finished

var disabled: bool = true:
	set(v):
		disabled = v
		if v:
			set_deferred("freeze", true) # 冻结物理
			linear_velocity = Vector2.ZERO
			angular_velocity = 0
			rotation = 0
			hitbox.disabled = true
			set_deferred("position", Vector2.ZERO)
			linear_velocity = Vector2.ZERO
			hide()
			life_timer.stop()
			friction_timer.stop()
			Game.get_game_scene().object_pool.recycle_object(obj_name, self)
			finished.emit()
		else:
			set_physics_process(true)
			hitbox.disabled = false
			show()
			life_timer.start()
			if rolling_friction:
				friction_timer.start()

@export var obj_name: StringName = "" ## 用于向对象池注册和回收
@export var dead_on_hit: bool = true ## 是否在接触玩家后消失
@export var rolling_friction: bool = false ## 启动滚动摩擦衰减

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var life_timer: Timer = $LifeTimer
@onready var particle_point: Marker2D = $ParticlePoint
@onready var particle_queue: ParticleQueue = $ParticleQueue
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var friction_timer: Timer = $FrictionTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	visible_on_screen_notifier_2d.show()
	if rolling_friction:
		if not collision_shape_2d.shape is CircleShape2D:
			push_error("RigidBullet: rolling_friction requires CircleShape2D")
		contact_monitor = true
		max_contacts_reported = 1

func _physics_process(_delta: float) -> void:
	if disabled:
		set_physics_process(false)
		return


func spawn(location: Vector2, velo: Vector2) -> void:
	set_deferred("freeze", false)
	disabled = false
	global_position = location
	linear_velocity = velo
	life_timer.start()

func dead() -> void:
	particle_queue.trigger(particle_point.global_position)
	disabled = true

func _on_life_timer_timeout() -> void:
	dead()

func _on_hitbox_collided(source: Hitbox.CollideSource, _damage: int, _location: Vector2) -> void:
	if dead_on_hit and source == Hitbox.CollideSource.PLAYER:
		disabled = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	disabled = true

func _on_friction_timer_timeout() -> void:
	if (rolling_friction
		and physics_material_override != null
		and get_contact_count() > 0):
		linear_velocity *= 1 - physics_material_override.friction
