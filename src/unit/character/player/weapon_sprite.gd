extends Sprite2D

const WOOD: CompressedTexture2D = preload("res://asset/texture/unit/player/stick/wood.webp")
const PLASTIC: CompressedTexture2D = preload("res://asset/texture/unit/player/stick/plastic.webp")
const CERAMIC: CompressedTexture2D = preload("res://asset/texture/unit/player/stick/ceramic.webp")
const METAL: CompressedTexture2D = preload("res://asset/texture/unit/player/stick/metal.webp")
const TITANIUM: CompressedTexture2D = preload("res://asset/texture/unit/player/stick/titanium.webp")
func _ready() -> void:
	from_status(Status.player_status)

func from_status(status: Status.PlayerStatus) -> void:
	update(status.number_collection["weapon_level"])

func update(level: int) -> void:
	match level:
		1:
			texture = WOOD
		2:
			texture = PLASTIC
		3:
			texture = CERAMIC
		4:
			texture = METAL
		5:
			texture = TITANIUM
		_:
			texture = WOOD
