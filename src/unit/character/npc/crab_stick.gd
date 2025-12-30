extends Npc

enum StoryLocation {
	WATERMELON,
	LEMON,
	MUSHROOM,
	BIG_MUSHROOM,
}

@export var story_location: StoryLocation = StoryLocation.WATERMELON

@onready var watermelon_dialog: DialogContent = $Dialog/Watermelon
@onready var lemon_dialog: DialogContent = $Dialog/Lemon
@onready var mushroom_dialog: DialogContent = $Dialog/Mushroom
@onready var big_mushroom_dialog: DialogContent = $Dialog/BigMushroom
@onready var boss_dialog: DialogContent = $Dialog/Boss

func _ready() -> void:
	super()
	match story_location:
		StoryLocation.WATERMELON:
			if Status.scene_status.scene_explore[53] == Constant.ExploreStatus.COMPLETE:
				queue_free()
				return
			dialog.root_dialog = watermelon_dialog
		StoryLocation.LEMON:
			if (Status.scene_status.scene_explore[159] != Constant.ExploreStatus.UNKNOWN
				or Status.has_collection("lemon_slice")):
				queue_free()
				return
			dialog.root_dialog = lemon_dialog
		StoryLocation.MUSHROOM:
			if Status.scene_status.scene_explore[165] != Constant.ExploreStatus.UNKNOWN:
				queue_free()
				return
			dialog.root_dialog = mushroom_dialog
		StoryLocation.BIG_MUSHROOM:
			dialog.root_dialog = big_mushroom_dialog
