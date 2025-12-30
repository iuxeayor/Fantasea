extends GPUParticles2D

@export var ignore_story: bool = false

func _ready() -> void:
	if (not ignore_story
		and Status.scene_status.story.get("main_sleep", false)):
		SoundManager.stop_rain()
		queue_free()
	else:
		await owner.ready
		SoundManager.play_rain(true)

func _exit_tree() -> void:
	SoundManager.stop_rain()
