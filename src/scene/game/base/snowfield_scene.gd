extends Scene

var high_snow_count_per_block: int = 20
var low_snow_count_per_block: int = 40
var high_snow_lifetime_per_block: float = 8
var low_snow_lifetime_per_block: float = 6

@export var close_normal_snow: bool = false ## 关闭默认的雪花

@onready var snow: Node2D = $Background/Prop/Snow
@onready var high_snow_particle: GPUParticles2D = $Background/Prop/Snow/HighSnowParticle
@onready var low_snow_particle: GPUParticles2D = $Background/Prop/Snow/LowSnowParticle

func _before_ready() -> void:
	# 计算雪花
	_cal_snow()
	if close_normal_snow:
		high_snow_particle.emitting = false
		high_snow_particle.hide()
		low_snow_particle.emitting = false
		low_snow_particle.hide()

func _cal_snow() -> void:
	if close_normal_snow:
		return
	var block_count: int = (block_end.x - block_start.x) * (block_end.y - block_start.y)
	high_snow_particle.amount = high_snow_count_per_block * block_count
	low_snow_particle.amount = low_snow_count_per_block * block_count
	var screen_start: Vector2 = Vector2(
		block_start.x * ProjectSettings.get_setting("display/window/size/viewport_width"),
		block_start.y * ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var screen_end: Vector2 = Vector2(
		block_end.x * ProjectSettings.get_setting("display/window/size/viewport_width"),
		block_end.y * ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	# 雪花位置在屏幕中间，往上一点点
	snow.global_position = Vector2(
		screen_start.x + (screen_end.x - screen_start.x) / 2,
		screen_start.y - 8
	)
	# 略微延伸屏幕一半宽度
	var spawn_extend: float = (screen_end.x - screen_start.x) / 2 + 8
	(high_snow_particle.process_material as ParticleProcessMaterial).emission_box_extents.x = spawn_extend
	(low_snow_particle.process_material as ParticleProcessMaterial).emission_box_extents.x = spawn_extend
	# 根据高度增长延长雪花生命周期
	var block_height: float = block_end.y - block_start.y
	high_snow_particle.lifetime = high_snow_lifetime_per_block * block_height
	high_snow_particle.preprocess = high_snow_particle.lifetime
	low_snow_particle.lifetime = low_snow_lifetime_per_block * block_height
	low_snow_particle.preprocess = low_snow_particle.lifetime
