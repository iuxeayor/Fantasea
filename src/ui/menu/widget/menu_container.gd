extends VBoxContainer
class_name MenuContainer
  
signal message_changed(description: String)
signal menu_change_to(target: Constant.GameMenu)

var opening: bool = false:
	set(v):
		opening = v
		if opening:
			show()
			refresh()
			if first_focus != null:
				first_focus.grab_focus.call_deferred()
		else:
			hide()
			
@export var first_focus: Control = null
@export var menu_id: Constant.GameMenu = Constant.GameMenu.NONE
@export var title: String = ""

func _ready() -> void:
	refresh()

func change_message(msg: String) -> void:
	message_changed.emit(tr(msg))

func change_menu(target: Constant.GameMenu) -> void:
	menu_change_to.emit(target)

func refresh() -> void:
	pass


func _on_focus_entered() -> void:
	if first_focus != null:
		first_focus.grab_focus.call_deferred()
