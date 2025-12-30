extends CharacterBody2D
class_name CharacterBullet
## 基于CharacterBody2D的子弹

enum DeadOnCollideMode {
	NO,
	ON_FLOOR,
	ON_WALL,
	ON_CEILING,
	ANY
}

signal finished

var disabled: bool = true:
	set(v):
		if v == disabled:
			return
		disabled = v
		if v:
			set_process(false)
			set_physics_process(false)
			finished.emit()
			hitbox.disabled = true
			set_deferred("position", Vector2.ZERO)
			velocity = Vector2.ZERO
			rotation = 0
			hide()
			life_timer.stop()
			Game.get_game_scene().object_pool.recycle_object(obj_name, self)
		else:
			set_process(true)
			set_physics_process(true)
			hitbox.disabled = false
			show()
			life_timer.start()

@export var obj_name: StringName = "" ## 用于向对象池注册和回收
@export var gravity: float = 0 ## 重力
@export var rotation_speed: float = 0 ## 旋转速度，仅是视觉效果
@export var rotate_with_velocity: bool = false ## 是否根据速度旋转，启动后rotation_speed无效
@export var dead_on_collide: DeadOnCollideMode = DeadOnCollideMode.ANY ## 是否在碰撞后消失
@export var dead_on_hit: bool = true ## 是否在击中玩家后消失
@export var hit_sfx: String = "" ## 击中玩家时播放的音效

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var particle_point: Marker2D = $ParticlePoint
@onready var particle_queue: ParticleQueue = $ParticleQueue
@onready var life_timer: Timer = $LifeTimer
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	hide()
	visible_on_screen_notifier_2d.show()

func spawn(location: Vector2, velo: Vector2) -> void:
	disabled = false
	global_position = location
	velocity = velo
	if rotate_with_velocity:
		rotation = velocity.angle()
		
func _process(delta: float) -> void:
	if disabled:
		return
	if (not rotate_with_velocity
		and rotation_speed != 0 ):
		sprite_2d.rotation += rotation_speed * TAU * delta

func _physics_process(delta: float) -> void:
	if disabled:
		return
	move_and_slide()
	if rotate_with_velocity:
		rotation = velocity.angle()
	velocity.y = min(Constant.MAX_FALL_VELOCITY, velocity.y + gravity * delta)
	if dead_on_collide != DeadOnCollideMode.NO:
		match dead_on_collide:
			DeadOnCollideMode.ON_FLOOR:
				if is_on_floor():
					dead()
			DeadOnCollideMode.ON_WALL:
				if is_on_wall():
					dead()
			DeadOnCollideMode.ON_CEILING:
				if is_on_ceiling():
					dead()
			DeadOnCollideMode.ANY:
				if is_on_wall() or is_on_floor() or is_on_ceiling():
					dead()

func dead() -> void:
	particle_queue.trigger(particle_point.global_position)
	if hit_sfx != "":
		SoundManager.play_sfx(hit_sfx)
	disabled = true
	
func _on_hitbox_collided(source: Hitbox.CollideSource, _damage: int, _position: Vector2) -> void:
	if dead_on_hit and source == Hitbox.CollideSource.PLAYER:
		disabled = true

func _on_life_timer_timeout() -> void:
	dead()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	disabled = true
