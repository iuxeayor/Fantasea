extends Node

const MENU_THEME_FOREST: Theme = preload("res://src/asset/theme/menu_theme_forest.tres")
const MENU_THEME_ISLAND: Theme = preload("res://src/asset/theme/menu_theme_island.tres")
const MENU_THEME_SNOWFIELD: Theme = preload("res://src/asset/theme/menu_theme_snowfield.tres")
const MENU_THEME_DESERT: Theme = preload("res://src/asset/theme/menu_theme_desert.tres")
const MENU_THEME_SHIP: Theme = preload("res://src/asset/theme/menu_theme_ship.tres")
# 正在focus的控件，用于离开菜单时恢复focus
var focusing: Control = null

@onready var status_panel: Control = $Hud/StatusPanel
@onready var touchscreen: Control = $Hud/Touchscreen
@onready var menu: Control = $Menu/Menu
@onready var inventory_screen: Control = $Menu/Menu/InventoryScreen
@onready var menu_screen: MenuScreen = $Menu/Menu/MenuScreen
@onready var item_collection_screen: Control = $Menu/Menu/ItemCollectionScreen
@onready var special_effect: Node = $SpecialEffect
@onready var touchscreen_editor: ColorRect = $Menu/Menu/TouchscreenEditor

func _ready() -> void:
	status_panel.hide()
	inventory_screen.hide()
	menu_screen.hide()
	item_collection_screen.hide()
	touchscreen_editor.hide()
	
func resume_focus() -> void:
	if focusing != null:
		focusing.grab_focus.call_deferred()

func get_scene_theme(scene_env: Constant.SceneEnvironment) -> Theme:
	match scene_env:
		Constant.SceneEnvironment.FOREST:
			return MENU_THEME_FOREST
		Constant.SceneEnvironment.ISLAND:
			return MENU_THEME_ISLAND
		Constant.SceneEnvironment.SNOWFIELD:
			return MENU_THEME_SNOWFIELD
		Constant.SceneEnvironment.DESERT:
			return MENU_THEME_DESERT
		Constant.SceneEnvironment.SHIP:
			return MENU_THEME_SHIP
		_:
			return MENU_THEME_ISLAND

func change_theme_by_scene(scene_env: Constant.SceneEnvironment) -> void:
	# 切换主题
	menu.theme = get_scene_theme(scene_env)
