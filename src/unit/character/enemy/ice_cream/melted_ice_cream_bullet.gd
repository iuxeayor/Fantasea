extends CharacterBullet

# 玩家在无敌情况也可以踩掉
func _on_player_checker_body_entered(body: Node2D) -> void:
	if body is Player:
		dead()
