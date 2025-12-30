extends Action

@export var top: bool = false
@export var mid: bool = false
@export var low: bool = false
@export var attack_speed: float = 180

var top_height: float = 128
var mid_height: float = 152
var low_height: float = 176

func enter() -> void:
	super ()
	if top:
		_shoot(top_height)
	if mid:
		_shoot(mid_height)
	if low:
		_shoot(low_height)

func _shoot(height: float) -> void:
	var bullet: CharacterBullet = Game.get_object("ice_bullet")
	if bullet == null:
		return
	SoundManager.play_sfx("IceShootBullet")
	bullet.spawn(
		Vector2(character.shoot_point.global_position.x, height),
		Vector2(character.direction * attack_speed, 0))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
