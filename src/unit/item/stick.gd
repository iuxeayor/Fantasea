extends "res://src/unit/item/item.gd"

var wood: Texture2D = preload("res://asset/texture/unit/item/wood_stick.webp")
var plastic: Texture2D = preload("res://asset/texture/unit/item/plastic_stick.webp")
var ceramic: Texture2D = preload("res://asset/texture/unit/item/ceramic_stick.webp")
var metal: Texture2D = preload("res://asset/texture/unit/item/metal_stick.webp")
var titanium: Texture2D = preload("res://asset/texture/unit/item/titanium_stick.webp")

func _ready() -> void:
	super ()
	match Status.player_status.number_collection.get("weapon_level", 0):
		0:
			sprite_2d.texture = wood
		1:
			sprite_2d.texture = plastic
		2:
			sprite_2d.texture = ceramic
		3:
			sprite_2d.texture = metal
		4:
			sprite_2d.texture = titanium
		_:
			sprite_2d.texture = wood
	

func _update_message() -> void:
	var control_message: String = InputManager.action_to_text("attack")
	match Status.player_status.number_collection.get("weapon_level", 0):
		1:
			message = tr("ITEM_WOOD_STICK") % control_message
		2:
			message = tr("ITEM_PLASTIC_STICK") % control_message
		3:
			message = tr("ITEM_CERAMIC_STICK") % control_message
		4:
			message = tr("ITEM_METAL_STICK") % control_message
		5:
			message = tr("ITEM_TITANIUM_STICK") % control_message
		_:
			message = tr("ITEM_WOOD_STICK") % control_message

func _collect() -> void:
	Status.player_status.number_collection["weapon_level"] += 1
	var player: Player = Game.get_player()
	var level: int = Status.player_status.number_collection.get("weapon_level", 0)
	player.status.attack = Util.get_attack_power(level)
	player.weapon_sprite.update(level)
	player.hit_wall_particles.update(level)
