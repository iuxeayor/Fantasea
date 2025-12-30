extends Action

## 面对或背对玩家
@export var invert: bool = false

func enter() -> void:
	super ()
	var player: Player = Game.get_player()
	if player.global_position.x < character.global_position.x:
		character.direction = Constant.Direction.LEFT if not invert else Constant.Direction.RIGHT
	elif player.global_position.x > character.global_position.x:
		character.direction = Constant.Direction.RIGHT if not invert else Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
