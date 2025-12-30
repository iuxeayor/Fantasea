extends RichTextLabel

@export_multiline var message: String = ""
@export var actions: Array[StringName] = []
var tween: Tween = null
@export var story_id: String = "" ## 相关故事完成后移除

@onready var area_collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	if story_id != "" and Status.scene_status.story.get(story_id, false):
		queue_free()
		return
	var collision_shape_2d: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collision_shape_2d != null:
		area_collision_shape.global_position = collision_shape_2d.global_position
		area_collision_shape.shape = collision_shape_2d.shape
	modulate.a = 0
	_update_text("language")
	Config.config_changed.connect(_update_text)
	InputManager.device_changed.connect(_update_text.bind("language"))

func _update_text(config_name: StringName) -> void:
	if config_name != "language":
		return
	if actions.is_empty():
		text = tr(message)
		return
	var actions_text: Array[String] = []
	for action: StringName in actions:
		actions_text.append(InputManager.action_to_text(action))
	text = tr(message) % actions_text

func show_tween(time: float) -> void:
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, time)

func hide_tween(time: float) -> void:
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, time)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		show_tween(0.5)
		if not actions.is_empty():
			UIManager.touchscreen.highlight(actions[0])


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		hide_tween(0.5)
