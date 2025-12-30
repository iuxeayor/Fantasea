extends Node2D

@onready var line: Line2D = $Line
@onready var start_particle: GPUParticles2D = $StartParticle
@onready var end_particle: GPUParticles2D = $EndParticle
@onready var left_collision: CollisionShape2D = $Hitbox/LeftCollision
@onready var right_collision: CollisionShape2D = $Hitbox/RightCollision
@onready var top_collision: CollisionShape2D = $Hitbox/TopCollision
@onready var bottom_collision: CollisionShape2D = $Hitbox/BottomCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox
@onready var line_animation_player: AnimationPlayer = $Line/LineAnimationPlayer

func _ready() -> void: 
	hide()
	left_collision.shape.a = Vector2(-8, 0)
	right_collision.shape.a = Vector2(8, 0)
	top_collision.shape.a = Vector2(0, -8)
	bottom_collision.shape.a = Vector2(0, 8)

func update(target: Vector2) -> void:
	line.points[1] = to_local(target)
	end_particle.global_position = target
	left_collision.shape.b = to_local(target) + Vector2(-8, 0)
	right_collision.shape.b = to_local(target) + Vector2(8, 0)
	top_collision.shape.b = to_local(target) + Vector2(0, -8)
	bottom_collision.shape.b = to_local(target) + Vector2(0, 8)

func start() -> void:
	animation_player.play("start")
	line_animation_player.play("running")

func end() -> void:
	animation_player.play("end")
