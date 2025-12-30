@tool
extends Npc

const MILK_1_KEY: String = "BUY_MILK_1"
const MILK_10_KEY: String = "BUY_MILK_10"

var milk_unit_price: int = 5

@onready var shop_dialog: DialogContent = $Dialog/Shop


func _ready() -> void:
	super ()
	milk_unit_price = Util.get_max_health(
		Status.player_status.number_collection.get("health_chip", 0))
	_handle_text("language")
	Config.config_changed.connect(_handle_text)

func _handle_text(config_name: StringName) -> void:
	if config_name != "language":
		return
	var milk_one_text: String = tr("BUY_MILK_1") % milk_unit_price
	shop_dialog.get_target(MILK_1_KEY).title = milk_one_text
	var new_milk_10_text: String = tr("BUY_MILK_10") % (milk_unit_price * 10)
	shop_dialog.get_target(MILK_10_KEY).title = new_milk_10_text

func _on_dialog_changed() -> void:
	var player_status: CharacterStatus = Game.get_player().status
	shop_dialog.get_target(MILK_1_KEY).disabled = false if player_status.money >= milk_unit_price else true
	shop_dialog.get_target(MILK_10_KEY).disabled = false if player_status.money >= milk_unit_price * 10 else true


func _on_milk_1_started() -> void:
	var player_status: CharacterStatus = Game.get_player().status
	if player_status.potion < player_status.max_potion:
		player_status.potion += 1
	else:
		player_status.potion_store += 1
	player_status.money -= milk_unit_price
	Status.player_status.potion_store = player_status.potion_store


func _on_milk_10_started() -> void:
	var player_status: CharacterStatus = Game.get_player().status
	var lack_potion: int = player_status.max_potion - player_status.potion
	if lack_potion >= 10:
		player_status.potion += 10
	else:
		player_status.potion += lack_potion
		player_status.potion_store += 10 - lack_potion
	player_status.money -= milk_unit_price * 10
	Status.player_status.potion_store = player_status.potion_store
