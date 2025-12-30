extends StaticBody2D

const FOREST_KEY: String = "SCENE_FOREST"
const DESERT_KEY: String = "SCENE_DESERT"
const SNOWFIELD_KEY: String = "SCENE_SNOWFIELD"
const SHIP_KEY: String = "SCENE_SHIP"
const CAVE_KEY: String = "SCENE_CAVE"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialog: Node2D = $Dialog
@onready var transport: DialogContent = $Dialog/Transport
@onready var forest: DialogContent = $Dialog/Transport/Forest
@onready var desert: DialogContent = $Dialog/Transport/Desert
@onready var snowfield: DialogContent = $Dialog/Transport/Snowfield
@onready var ship: DialogContent = $Dialog/Transport/Ship
@onready var cave: DialogContent = $Dialog/Transport/Cave

func _ready() -> void:
	animation_player.play("idle")
	
func trigger() -> void:
	# 玩家钱不到2c时，无法使用
	if Game.get_player().status.money < 2:
		for tar: DialogContent.Target in transport.handled_target:
			tar.disabled = true
	else:
		var explore: Dictionary[int, Constant.ExploreStatus] = Status.scene_status.scene_explore
		var index: int = Game.get_game_scene().get_scene_index()
		transport.get_target(FOREST_KEY).disabled = (explore[7] == Constant.ExploreStatus.UNKNOWN
			or index == 7)
		transport.get_target(DESERT_KEY).disabled = (explore[90] == Constant.ExploreStatus.UNKNOWN
			or index == 90)
		transport.get_target(SNOWFIELD_KEY).disabled = (explore[70] == Constant.ExploreStatus.UNKNOWN
			or index == 70)
		transport.get_target(SHIP_KEY).disabled = (explore[172] == Constant.ExploreStatus.UNKNOWN
			or index == 172)
		transport.get_target(CAVE_KEY).disabled = (explore[200] == Constant.ExploreStatus.UNKNOWN
			or index == 200)
	dialog.disabled = false

func _on_forest_started() -> void:
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	Game.get_player().status.money -= 2
	Game.get_game_scene().to_status()
	Game.teleport_switch_game_scene(7)


func _on_desert_started() -> void:
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	Game.get_player().status.money -= 2
	Game.get_game_scene().to_status()
	Game.teleport_switch_game_scene(90)


func _on_snowfield_started() -> void:
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	Game.get_player().status.money -= 2
	Game.get_game_scene().to_status()
	Game.teleport_switch_game_scene(70)


func _on_ship_started() -> void:
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	Game.get_player().status.money -= 2
	Game.get_game_scene().to_status()
	Game.teleport_switch_game_scene(172)


func _on_cave_started() -> void:
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	Game.get_player().status.money -= 2
	Game.get_game_scene().to_status()
	Game.teleport_switch_game_scene(200)
