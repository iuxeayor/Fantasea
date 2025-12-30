@tool
extends Npc

const BANG_CARD: CompressedTexture2D = preload("res://asset/texture/unit/item/bang_card.webp")
const CHICKEN_SANDWICH: CompressedTexture2D = preload("res://asset/texture/unit/item/chicken_sandwich.webp")

enum StoryStage {
	START,
	END,
}

@export var story_stage: StoryStage = StoryStage.START

@onready var info_dialog: DialogContent = $Dialog/Info
@onready var paid_dialog: DialogContent = $Dialog/Info/Paid
@onready var bang_dialog: DialogContent = $Dialog/Bang

var price: int = 160

func _ready() -> void:
	super ()
	match story_stage:
		StoryStage.START:
			dialog.root_dialog = info_dialog
			if Status.player_status.collection.get("bang_card", false):
				dialog.root_dialog = paid_dialog
			if Status.scene_status.scene_explore[174] == Constant.ExploreStatus.COMPLETE:
				queue_free()
				return
		StoryStage.END:
			dialog.hide_disabled = true
			dialog.root_dialog = bang_dialog
			if (not (Status.has_collection("bang_card") # 岛屿
				and Status.has_collection("honey") # 荒漠
				and Status.has_collection("frozen_apple") # 雪原
				and Status.has_collection("magnet") # 森林
				and Status.has_collection("silk_tofu")) # 洞穴
				or Status.has_collection("chicken_sandwich")): # 已经获得
				bang_dialog.get_target("BURGER_FINAL").disabled = true
	

func _on_paid_ended() -> void:
	# 已经有卡不触发
	if Status.player_status.collection.get("bang_card", false):
		return
	Status.player_status.collection["bang_card"] = true
	UIManager.item_collection_screen.update(BANG_CARD, "ITEM_BANG_CARD")
	UIManager.item_collection_screen.opening = true
	dialog.root_dialog = paid_dialog

func _on_dialog_changed() -> void:
	info_dialog.get_target("BURGER_PAID").disabled = Game.get_player().status.money < price

func _on_paid_started() -> void:
	# 已经有卡不触发
	if Status.player_status.collection.get("bang_card", false):
		return
	Game.get_player().status.money -= price
	dialog.root_dialog = paid_dialog


func _on_final_ended() -> void:
	Status.player_status.collection["chicken_sandwich"] = true
	UIManager.item_collection_screen.update(CHICKEN_SANDWICH, "ITEM_CHICKEN_SANDWICH")
	UIManager.item_collection_screen.opening = true
	bang_dialog.get_target("BURGER_FINAL").disabled = true
