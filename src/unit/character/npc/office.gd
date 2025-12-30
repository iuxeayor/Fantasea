@tool
extends Npc

@onready var stable_dialog: DialogContent = $Dialog/Stable
@onready var free_dialog: DialogContent = $Dialog/Free

enum StoryType {
	STABLE,
	FREE
}

@export var story_type: StoryType = StoryType.STABLE

func _ready() -> void:
	super()
	match story_type:
		StoryType.STABLE:
			dialog.root_dialog = stable_dialog
		StoryType.FREE:
			dialog.root_dialog = free_dialog
