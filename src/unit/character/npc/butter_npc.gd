@tool
extends Npc

enum StoryStage {
	MEET,
	NORMAL,
	BATTLE,
	RELAX,
	SHIP
}

@export var story_stage: StoryStage = StoryStage.RELAX

@onready var meet_dialog: DialogContent = $Dialog/Meet
@onready var normal_dialog: DialogContent = $Dialog/Normal
@onready var break_dialog: DialogContent = $Dialog/Break
@onready var battle_dialog: DialogContent = $Dialog/Battle
@onready var defeat_dialog: DialogContent = $Dialog/Defeat
@onready var end_dialog: DialogContent = $Dialog/End
@onready var relax_dialog: DialogContent = $Dialog/Relax
@onready var ship_dialog: DialogContent = $Dialog/Ship

func _ready() -> void:
	super()
	match story_stage:
		StoryStage.MEET:
			dialog.root_dialog = meet_dialog
			if Status.has_collection("bang_card"): ## 有卡则不需要引导
				queue_free()
		StoryStage.NORMAL:
			dialog.root_dialog = normal_dialog
		StoryStage.BATTLE:
			dialog.root_dialog = battle_dialog
		StoryStage.RELAX:
			dialog.root_dialog = relax_dialog
			if Status.scene_status.scene_explore[92] != Constant.ExploreStatus.UNKNOWN:
				queue_free()
		StoryStage.SHIP:
			dialog.root_dialog = ship_dialog

func _on_meet_ended() -> void:
	updated.emit("meet")

func _on_break_ended() -> void:
	updated.emit("break")

func _on_combat_ended() -> void:
	updated.emit("combat")

func _on_defeat_ended() -> void:
	updated.emit("defeat")

func _on_end_ended() -> void:
	updated.emit("end")
