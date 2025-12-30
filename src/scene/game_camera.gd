extends Camera2D

@export var shake_noise: FastNoiseLite = null
var shake_strength: float = 0.0
var shake_tween: Tween = null
var noise_index: float = 0.0: # 用于噪声震动的索引
	set(v):
		if not is_node_ready():
			return
		noise_index = v
		offset = Vector2(
			shake_strength * shake_noise.get_noise_2d(
				noise_index, 0.0
			),
			shake_strength * shake_noise.get_noise_2d(
				0.0, noise_index
			)
		)

@onready var shake_timer: Timer = $ShakeTimer

func _ready() -> void:
	Config.config_changed.connect(_handle_config)

func shake(strength: float, duration: float) -> void:
	if Config.close_shake:
		stop_shake()
		return
	shake_strength = strength
	shake_timer.start(duration)
	if (shake_tween != null
		and shake_tween.is_running()):
		shake_tween.kill()
	var target_index: float = noise_index + 100 * duration
	shake_tween = create_tween()
	shake_tween.set_parallel()
	shake_tween.tween_property(self, "noise_index", target_index, duration)
	shake_tween.tween_property(self, "shake_strength", 0, duration)
	shake_tween.finished.connect(stop_shake, CONNECT_ONE_SHOT)

func _handle_config(config_name: String) -> void:
	if config_name != "close_shake":
		return
	if Config.close_shake:
		stop_shake()

func stop_shake() -> void:
	if (shake_tween != null
		and shake_tween.is_running()):
		shake_tween.kill()
	set_deferred("offset", Vector2.ZERO)
