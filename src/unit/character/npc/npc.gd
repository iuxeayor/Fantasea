@tool
extends Character
class_name Npc

signal updated(context: String)
signal completed

## 角色的朝向
@export var direction: Constant.Direction = Constant.Direction.LEFT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction
@export var turn: bool = true ## 对话时是否转身
@export var animation_name: StringName = "" ## 默认动画，为空不播放

@onready var dialog: Node2D = $Dialog
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if animation_name != "":
		animation_player.play(animation_name)

func trigger() -> void:
	if turn:
		var player: Player = Game.get_player()
		if player.global_position.x < global_position.x:
			direction = Constant.Direction.LEFT
		elif player.global_position.x > global_position.x:
			direction = Constant.Direction.RIGHT
	dialog.disabled = false

func wait_updated_context(context: String) -> void:
	while true:
		var ctx: String = await updated
		if ctx == context:
			return

func _pass() -> void:
	completed.emit()
