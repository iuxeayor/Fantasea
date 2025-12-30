extends ParticleQueue

@export var wood_color: Color = Color.BLACK
@export var plastic_color: Color = Color.BLACK
@export var ceramic_color: Color = Color.BLACK
@export var metal_color: Color = Color.BLACK
@export var titanium_color: Color = Color.BLACK

var used_color: Color = wood_color

func _ready() -> void:
	super ()
	from_status(Status.player_status)

func from_status(status: Status.PlayerStatus) -> void:
	update(status.number_collection["weapon_level"])

func update(level: int) -> void:
	match level:
		1:
			used_color = wood_color
		2:
			used_color = plastic_color
		3:
			used_color = ceramic_color
		4:
			used_color = metal_color
		5:
			used_color = titanium_color
		6:
			used_color = wood_color
		_:
			used_color = wood_color
