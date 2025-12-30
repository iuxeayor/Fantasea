extends Action

const WIDTH: float = 40
const DUO_OFFSET: float = WIDTH / 2

@export var duo: bool = false ## 是否为泛狙
@export var aim_time: float = 1

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	# 以目标为中心散开瞄准，为狙时中心瞄准目标，为泛狙时瞄准目标两侧
	var target_x: float = Game.get_player().global_position.x
	var land_y: float = Game.get_game_scene().GROUND_Y - 8
	for i in range(-3, 3):
		if duo:
			Game.get_game_scene().bullet_aim(
				character.shoot_point.global_position, 
				Vector2(target_x + i * WIDTH + DUO_OFFSET, land_y))
		else:
			Game.get_game_scene().bullet_aim(
				character.shoot_point.global_position, 
				Vector2(target_x + i * WIDTH, land_y))
	timer.start(aim_time)

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
