extends StaticBody2D

signal finished

enum PlatformStatus {
	START,
	GOING,
	END,
	BACK
}

@export var go_velocity: Vector2 = Vector2.ZERO
@export var back_velocity: Vector2 = Vector2.ZERO
@export var only_open: bool = false
@export var complete_position: Vector2 = Vector2.ZERO
@export var loop: bool = false ## 是否循环移动
var start_position: Vector2 = Vector2.ZERO

var opened: bool = false
var status: PlatformStatus = PlatformStatus.START:
	set(v):
		status = v
		match status:
			PlatformStatus.START, PlatformStatus.BACK:
				opened = false
			PlatformStatus.GOING, PlatformStatus.END:
				opened = true

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var moving_tile: TileMapLayer = $MovingTile
@onready var animatable_body_2d: AnimatableBody2D = $AnimatableBody2D
@onready var animatable_collision: CollisionShape2D = $AnimatableBody2D/AnimatableCollision

func _ready() -> void:
	if complete_position == Vector2.ZERO and not loop:
		push_warning("Complete position is 0, perhaps overlooked")
	start_position = global_position
	var tile_used_rect: Rect2i = Rect2i(
		moving_tile.get_used_rect().position * moving_tile.tile_set.tile_size,
		moving_tile.get_used_rect().size * moving_tile.tile_set.tile_size
	)   
	var shape_size: Vector2 = moving_tile.get_used_rect().size * moving_tile.tile_set.tile_size
	shape_size -= Vector2(0.1, 0.1)  # 
	# 设置碰撞形状
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = shape_size
	collision_shape_2d.shape = shape
	collision_shape_2d.position = Vector2(
		tile_used_rect.position.x * moving_tile.tile_set.tile_size.x + shape_size.x / 2,
		tile_used_rect.position.y * moving_tile.tile_set.tile_size.y + shape_size.y / 2
	)
	animatable_collision.shape = shape
	animatable_collision.position = collision_shape_2d.position
	if not loop and complete_position == Vector2.ZERO:
		print("%s:%s: complete_position may not set" % [get_parent().name, name])
	if loop:
		open()



func complete() -> void:
	if only_open:
		global_position = complete_position

func open() -> void:
	match status:
		PlatformStatus.START, PlatformStatus.BACK:
			status = PlatformStatus.GOING
		PlatformStatus.GOING, PlatformStatus.END:
			return

func close() -> void:
	if only_open:
		return
	match status:
		PlatformStatus.START, PlatformStatus.BACK:
			return
		PlatformStatus.GOING, PlatformStatus.END:
			status = PlatformStatus.BACK

func _physics_process(delta: float) -> void:
	match status:
		PlatformStatus.START, PlatformStatus.END:
			return
		PlatformStatus.GOING:
			var collider: KinematicCollision2D = move_and_collide(go_velocity * delta)
			if (collider != null
				and collider.get_collider().is_in_group("railway")):
				if loop:
					status = PlatformStatus.BACK
				else:
					status = PlatformStatus.END
					global_position = complete_position
					finished.emit()
		PlatformStatus.BACK:
			var collider: KinematicCollision2D = move_and_collide(back_velocity * delta)
			if (collider != null
				and collider.get_collider().is_in_group("railway")):
				if loop:
					status = PlatformStatus.GOING
				else:
					status = PlatformStatus.START
					global_position = start_position
					finished.emit()
