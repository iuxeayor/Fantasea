extends MenuContainer

@onready var save_button_0: SaveButton = $ContentContainer/GridContainer/SaveButton0
@onready var save_button_1: SaveButton = $ContentContainer/GridContainer/SaveButton1
@onready var save_button_2: SaveButton = $ContentContainer/GridContainer/SaveButton2
@onready var save_button_3: SaveButton = $ContentContainer/GridContainer/SaveButton3
@onready var save_button_4: SaveButton = $ContentContainer/GridContainer/SaveButton4
	
func refresh() -> void:
	# 启用所有存档按钮
	save_button_0.disabled = false
	save_button_1.disabled = false
	save_button_2.disabled = false
	save_button_3.disabled = false
	save_button_4.disabled = false

func _on_save_button_focus_entered() -> void:
	change_message("SAVE_NEW_DESC")

func _on_save_button_pressed() -> void:
	UIManager.menu_screen.opening = false
	_backup_save()
	Game.start_game()

func _backup_save() -> void:
	# 遍历存档目录
	var dir: DirAccess = DirAccess.open(Game.SAVE_PATH_DIR)
	if dir != null:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if (not dir.current_is_dir()
				and file_name.begins_with("save")
				and file_name.ends_with(".sav")):
				var idx: String = file_name.get_slice("save", 1).get_slice(".", 0)
				if idx.is_valid_int():
					DirAccess.copy_absolute(
						"%s/%s" % [Game.SAVE_PATH_DIR, file_name],
						"%s/%s" % [Game.SAVE_BACKUP_PATH_DIR, file_name])
			file_name = dir.get_next()
