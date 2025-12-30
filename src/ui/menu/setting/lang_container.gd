extends MenuContainer

@onready var lang_option: OptionButton = $ContentContainer/GridContainer/LangOption

func refresh() -> void:
	match TranslationServer.get_locale():
		"en":
			lang_option.selected = 0
		"zh_CN":
			lang_option.selected = 1
		"zh_HK":
			lang_option.selected = 2
		_: # 默认英语
			lang_option.selected = 0


func _on_lang_option_item_selected(index: int) -> void:
	match index:
		0:
			Config.set_language("en")
		1:
			Config.set_language("zh_CN")
		2:
			Config.set_language("zh_HK")


func _on_lang_option_focus_entered() -> void:
	change_message("修改语言\nChange Language\n修改語言")
