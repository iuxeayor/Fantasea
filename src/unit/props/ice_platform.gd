extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var checker_collision: CollisionShape2D = $PlayerChecker/CollisionShape2D
@onready var breaking_timer: Timer = $BreakingTimer
@onready var break_timer: Timer = $BreakTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

# 流程
# 1.踩中时出现裂痕
# 2.即将破裂时，裂痕更明显
# 3.破裂后，消失，触发粒子
# 4.等待时间恢复，慢慢出现
# 5.出现时再次触发粒子

func _on_player_checker_body_entered(body: Node2D) -> void:
	if body is Player:
		checker_collision.set_deferred("disabled", true)
		sprite_2d.frame = 1
		breaking_timer.start()
		SoundManager.play_sfx("IcePlatformBreaking")

func _on_breaking_timer_timeout() -> void:
	sprite_2d.frame = 2
	break_timer.start()
	SoundManager.play_sfx("IcePlatformBreaking")


func _on_break_timer_timeout() -> void:
	sprite_2d.hide()
	sprite_2d.modulate.a = 0
	collision_shape_2d.set_deferred("disabled", true)
	gpu_particles_2d.restart()
	recovery_timer.start()
	SoundManager.play_sfx("IcePlatformChange")


func _on_recovery_timer_timeout() -> void:
	sprite_2d.frame = 1
	sprite_2d.show()
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 1, 1)
	await tween.finished
	gpu_particles_2d.restart()
	sprite_2d.frame = 0
	collision_shape_2d.set_deferred("disabled", false)
	checker_collision.set_deferred("disabled", false)
	SoundManager.play_sfx("IcePlatformChange")
