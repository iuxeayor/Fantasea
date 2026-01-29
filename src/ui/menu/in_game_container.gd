extends MenuContainer

func _on_setting_button_focus_entered() -> void:
	change_message("IN_SETTING_DESC")

func _on_load_button_focus_entered() -> void:
	change_message("IN_LOAD_DESC")

func _on_back_title_button_focus_entered() -> void:
	change_message("IN_TITLE_DESC")

func _on_exit_button_focus_entered() -> void:
	change_message("IN_EXIT_DESC")

func _on_setting_button_pressed() -> void:
	change_menu(Constant.GameMenu.SETTING)

func _on_load_button_pressed() -> void:
	change_menu(Constant.GameMenu.LOAD_SAVE)

func _on_back_title_button_pressed() -> void:
	# 暂停游戏
	get_tree().paused = true
	UIManager.menu_screen.opening = false
	get_tree().paused = true # 关闭菜单会自动解除暂停，重新暂停
	# 淡入
	await UIManager.special_effect.fade_in(0.5)
	UIManager.status_panel.hide()
	get_tree().change_scene_to_file("res://src/ui/title_screen.tscn")
	await get_tree().tree_changed
	# 淡出
	await UIManager.special_effect.fade_out(0.5)
	get_tree().paused = false


func _on_exit_pressed() -> void:
	if Util.is_web_platform():
		JavaScriptBridge.eval("location.reload()")
	else:
		get_tree().quit()
