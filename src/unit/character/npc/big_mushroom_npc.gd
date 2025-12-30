@tool
extends Npc



func _on_player_jump_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if body.velocity.y <= 0:
		return
	Game.get_player().velocity.y = -580
	SoundManager.play_sfx("BigMushroomBounce")
	animation_play("bounce")
