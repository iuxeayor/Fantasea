extends MenuContainer

@onready var path_button: Button = $ContentContainer/PathButton
@onready var save_button_0: SaveButton = $ContentContainer/GridContainer/SaveButton0
@onready var save_button_1: SaveButton = $ContentContainer/GridContainer/SaveButton1
@onready var save_button_2: SaveButton = $ContentContainer/GridContainer/SaveButton2
@onready var save_button_3: SaveButton = $ContentContainer/GridContainer/SaveButton3
@onready var save_button_4: SaveButton = $ContentContainer/GridContainer/SaveButton4

func refresh() -> void:
	if Util.is_web_platform() or Util.is_mobile_platform():
		path_button.hide()

func _on_save_button_0_pressed() -> void:
	UIManager.menu_screen.opening = false
	Game.load_game("save0")

func _on_save_button_1_pressed() -> void:
	UIManager.menu_screen.opening = false
	Game.load_game("save1")

func _on_save_button_2_pressed() -> void:
	UIManager.menu_screen.opening = false
	Game.load_game("save2")

func _on_save_button_3_pressed() -> void:
	UIManager.menu_screen.opening = false
	Game.load_game("save3")

func _on_save_button_4_pressed() -> void:
	UIManager.menu_screen.opening = false
	Game.load_game("save4")

func _on_save_button_0_focus_entered() -> void:
	change_message(save_button_0.menu_message)

func _on_save_button_1_focus_entered() -> void:
	change_message(save_button_1.menu_message)

func _on_save_button_2_focus_entered() -> void:
	change_message(save_button_2.menu_message)

func _on_save_button_3_focus_entered() -> void:
	change_message(save_button_3.menu_message)

func _on_save_button_4_focus_entered() -> void:
	change_message(save_button_4.menu_message)


func _on_button_focus_entered() -> void:
	change_message("SAVE_PATH_DESC")

func _on_path_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://save/"))
