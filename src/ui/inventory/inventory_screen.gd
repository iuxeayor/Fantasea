extends Control

enum Page {
	ITEM,
	MAP
}

var opening: bool = false:
	set(v):
		opening = v
		if opening:
			get_tree().paused = true
			if Game.get_player() != null:
				item_container.update(Status.player_status)
			current_page_index = current_page_index
			show()
		else:
			hide()
			get_tree().paused = false

var pages: Array[Page] = [Page.ITEM, Page.MAP]
var current_page_index: int = 0:
	set(v):
		current_page_index = clampi(v, 0, pages.size() - 1)
		if is_node_ready():
			_switch_page(pages[current_page_index])

@onready var item_button: Button = $PanelContainer/VBoxContainer/TopContainer/ItemButton
@onready var item_container: HBoxContainer = $PanelContainer/VBoxContainer/ContentContainer/ItemContainer
@onready var map_button: Button = $PanelContainer/VBoxContainer/TopContainer/MapButton
@onready var map_container: Control = $PanelContainer/VBoxContainer/ContentContainer/MapContainer
@onready var return_button: Button = $PanelContainer/VBoxContainer/TopContainer/ReturnButton
@onready var left_separator: VSeparator = $PanelContainer/VBoxContainer/TopContainer/LeftSeparator
@onready var right_separator: VSeparator = $PanelContainer/VBoxContainer/TopContainer/RightSeparator
@onready var interact_button: Button = $PanelContainer/VBoxContainer/TopContainer/InteractButton


func _ready() -> void:
	current_page_index = 0
	return_button.visible = Util.is_touchscreen_platform()
	left_separator.visible = Util.is_touchscreen_platform()
	right_separator.visible = not Util.is_touchscreen_platform()
	interact_button.visible = not Util.is_touchscreen_platform()

func _unhandled_input(event: InputEvent) -> void:
	if opening:
		if ((event.is_action_pressed("inventory")
			or event.is_action_pressed("ui_cancel"))):
			opening = false
			get_viewport().set_input_as_handled()
		if event.is_action_pressed("interact"):
			current_page_index = (current_page_index + 1) % pages.size()
		
func _switch_page(page: Page) -> void:
	match page:
		Page.ITEM:
			item_container.opening = true
			item_button.disabled = true
			map_container.opening = false
			map_button.disabled = false
		Page.MAP:
			item_container.opening = false
			item_button.disabled = false
			map_container.opening = true
			map_button.disabled = true
	SoundManager.play_sfx("MenuFocus")

func reset() -> void:
	item_container.update(Status.PlayerStatus.new())
	map_container.mini_map.update(Status.SceneStatus.new().scene_explore)


func _on_item_button_pressed() -> void:
	current_page_index = pages.find(Page.ITEM)

func _on_map_button_pressed() -> void:
	current_page_index = pages.find(Page.MAP)

func _on_return_button_pressed() -> void:
	opening = false
