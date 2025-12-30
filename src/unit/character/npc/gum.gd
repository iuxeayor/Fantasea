@tool
extends Npc

enum StoryState {
	FIRST,
	TOP,
	BOSS,
}

@export var story: StoryState = StoryState.FIRST

@onready var first_dialog: DialogContent = $Dialog/First
@onready var top_dialog: DialogContent = $Dialog/Top
@onready var boss_dialog: DialogContent = $Dialog/Boss

func _ready() -> void:
	match story:
		StoryState.FIRST:
			dialog.root_dialog = first_dialog
			# 场景192未探索或场景167已完成则不出现
			if (Status.scene_status.scene_explore[192] != Constant.ExploreStatus.UNKNOWN
				or Status.scene_status.scene_explore[167] == Constant.ExploreStatus.COMPLETE):
				queue_free()
				return
		StoryState.TOP:
			dialog.root_dialog = top_dialog
			# 场景192或167已完成则不出现
			if (Status.scene_status.scene_explore[192] == Constant.ExploreStatus.COMPLETE
				or Status.scene_status.scene_explore[167] == Constant.ExploreStatus.COMPLETE):
				queue_free()
		StoryState.BOSS:
			# 场景192未探索或167已完成则不出现
			dialog.root_dialog = boss_dialog
			if (Status.scene_status.scene_explore[192] == Constant.ExploreStatus.UNKNOWN
				or Status.scene_status.scene_explore[167] == Constant.ExploreStatus.COMPLETE):
				queue_free()
