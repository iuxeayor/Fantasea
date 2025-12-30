@tool
extends Npc

@onready var start_dialog: DialogContent = $Dialog/Start
@onready var busy_dialog: DialogContent = $Dialog/Busy

func _ready() -> void:
	if not Status.scene_status.story.get("main_start", false):
		# 未完成开局剧情，则显示开局对话
		dialog.root_dialog = start_dialog
	else:
		if not Status.scene_status.story.get("main_sleep", false):
			# 未离家，使用忙碌对话
			dialog.root_dialog = busy_dialog
	animation_player.play("write")

func _on_info_triggered() -> void:
	animation_player.play("idle")

func _on_info_ended() -> void:
	animation_player.play("write")


func _on_reply_ended() -> void:
	updated.emit("start")
