extends StaticBody2D
class_name Item

@export var item_id: String  = "" ## 物品ID
@export_multiline var message: String = "" ## 物品信息


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal completed

func _ready() -> void:
	animation_player.play("hover")


func trigger() -> void:
	_collect()
	_update_message()
	completed.emit()
	UIManager.item_collection_screen.update(sprite_2d.texture, message)
	UIManager.item_collection_screen.opening = true
	queue_free()

# 获取的效果
func _collect() -> void:
	if item_id != "" and Status.player_status.collection.has(item_id):
		Status.player_status.collection[item_id] = true

# 更新信息，状态变化或语言变化时应调用
func _update_message() -> void:
	pass

func complete() -> void:
	queue_free()
