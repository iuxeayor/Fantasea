class_name Character
extends CharacterBody2D

## 是否启动行为日志
@export var enable_active_log: bool = false

@onready var status: CharacterStatus = $Status
@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Graphics/Sprite2D


# 受伤闪烁
func hurt_flash() -> void:
	sprite_2d.material.set_shader_parameter("flash_amount", sin(float(Time.get_ticks_msec()) / 40) * 0.5 + 0.5)

# 重置闪烁
func reset_flash() -> void:
	sprite_2d.material.set_shader_parameter("flash_amount", 0)

func animation_play(anim_name: StringName, overwrite_same: bool = false) -> void:
	if animation_player.current_animation == anim_name and not overwrite_same:
		animation_player.play(anim_name)
		return
	animation_player.play.call_deferred("RESET")
	animation_player.advance.call_deferred(0)
	animation_player.play.call_deferred(anim_name)
	animation_player.advance.call_deferred(0)
