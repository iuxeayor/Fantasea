extends Node
class_name ParticleQueue


@export var random: bool = false ## 是否随机选择粒子效果
@export var overwrite_color: Color = Color.WHITE

var queue: Array[GPUParticles2D] = []
var index: int = 0
var can_trigger: bool = false

func _ready() -> void:
	for node: GPUParticles2D in get_children():
		queue.append(node)

func trigger(location: Vector2, color: Color = overwrite_color) -> void:
	can_trigger = false
	if queue.is_empty():
		return
	if random:
		index = randi() % queue.size()
	var particle: GPUParticles2D = queue[index]
	particle.self_modulate = color
	particle.global_position = location
	particle.restart()
	if not random:
		index += 1
		if index >= queue.size():
			index = 0
