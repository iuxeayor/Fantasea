extends Node2D

const MAX_LENGTH: int = 440

var obj_name: StringName = "bullet_hit"

@onready var hitbox: Hitbox = $Hitbox
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var laser: Line2D = $Hitbox/Laser
@onready var shoot_line: Line2D = $Hitbox/ShootLine
@onready var gunfire: Sprite2D = $Gunfire
@onready var timer: Timer = $Timer


var dir: Vector2 = Vector2.ZERO
var start: Vector2 = Vector2.ZERO
var end: Vector2 = Vector2.ZERO


func _ready() -> void:
	hitbox.disabled = true
	laser.hide()
	shoot_line.hide()
	gunfire.hide()
	collision_shape_2d.shape = collision_shape_2d.shape.duplicate(true)

func aim(start_point: Vector2, end_point: Vector2) -> void:
	global_position = start_point
	hitbox.disabled = true
	start = to_local(start_point)
	dir = (end_point - start_point).normalized()
	end = start + dir * MAX_LENGTH
	collision_shape_2d.shape.a = start
	collision_shape_2d.shape.b = end
	laser.points = [start, end]
	laser.show()
	shoot_line.points = [start, end]
	shoot_line.hide()
	gunfire.rotation = dir.angle()
	gunfire.hide()

func shoot() -> void:
	SoundManager.play_sfx("CaliforniaRollShoot")
	laser.hide()
	shoot_line.show()
	gunfire.show()
	hitbox.disabled = false
	timer.start()

	
func reset() -> void:
	hitbox.disabled = true
	shoot_line.hide()
	laser.hide()
	timer.stop()
	gunfire.hide()
	Game.get_game_scene().object_pool.recycle_object(obj_name, self)


func _on_timer_timeout() -> void:
	reset()
