extends Action

@export var min_distance: float = 0
@export var max_distance: float = 96

@onready var min_distance_x: float = min_distance + 16
@onready var max_distance_x: float = max_distance + 16

var min_y_speed: float = 400
var max_y_speed: float = 500
var min_bullet_number: int = 15
var max_bullet_number: int = 25


func exit() -> void:
	super ()
	for i in range(randf_range(min_bullet_number, max_bullet_number)):
		var bullet: CharacterBullet = Game.get_object("small_peanut_butter_bullet")
		if bullet == null:
			return
		var velocity_y: float = - randf_range(min_y_speed, max_y_speed)
		var velocity_x: float = Util.calculate_x_velocity_parabola(character.throw_point.global_position,
			Vector2(character.throw_point.global_position.x
				+ character.direction
				* randf_range(min_distance_x, max_distance_x),
				Game.get_game_scene().land_y),
			velocity_y,
			800)
		bullet.spawn(character.throw_point.global_position, Vector2(velocity_x, velocity_y))
	var left_x: float = character.throw_point.global_position.x + character.direction * min_distance_x
	var right_x: float = character.throw_point.global_position.x + character.direction * max_distance_x
	if left_x > right_x:
		var temp: float = left_x
		left_x = right_x
		right_x = temp
	left_x = max(left_x, Game.get_game_scene().left_edge)
	right_x = min(right_x, Game.get_game_scene().right_edge)
	Game.get_game_scene().show_warning(left_x, right_x)

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
