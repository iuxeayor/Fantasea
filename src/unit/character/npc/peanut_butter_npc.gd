@tool
extends Npc

@onready var info_dialog: DialogContent = $Dialog/Sleep/Info
@onready var defeated_dialog: DialogContent = $Dialog/Defeated
@onready var ask_leave_dialog: DialogContent = $Dialog/AskLeave
@onready var normal_dialog: DialogContent = $Dialog/Normal

func _on_info_started() -> void:
	animation_player.play("awake")
	dialog.root_dialog = info_dialog


func _on_fight_started() -> void:
	dialog.disabled = true
	updated.emit("fight")
	animation_player.play("ready")
	await animation_player.animation_finished
	dialog.root_dialog = defeated_dialog

func _on_defeated_ended() -> void:
	dialog.root_dialog = ask_leave_dialog
	updated.emit("defeated")
