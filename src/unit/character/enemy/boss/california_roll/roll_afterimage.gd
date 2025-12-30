extends Node2D

var tween: Tween = null

var obj_name: StringName = "roll_afterimage"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	hide()
	sprite_2d.modulate.a = 0.5

func spawn(pos: Vector2, direction: Constant.Direction, down: bool) -> void:
	global_position = pos
	if down:
		animation_player.play("down")
	else:
		animation_player.play("dash")
	sprite_2d.scale.x = direction
	sprite_2d.modulate.a = 0.5
	show()
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0, 0.2)
	tween.finished.connect((func() -> void:
		hide()
		Game.get_game_scene().object_pool.recycle_object(obj_name, self)
	), CONNECT_ONE_SHOT)
